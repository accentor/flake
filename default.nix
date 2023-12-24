{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.accentor;
  api = cfg.apiPackage;
  gems = api.env;
  web = cfg.webPackage;
  env = {
    BOOTSNAP_READONLY = "TRUE";
    DATABASE_URL = "postgresql://%2Frun%2Fpostgresql/accentor";
    FFMPEG_LOG_LOCATION = "/var/log/accentor/ffmpeg.log";
    FFMPEG_VERSION_LOCATION = "${cfg.home}/ffmpeg.version";
    PIDFILE = "/run/accentor/server.pid";
    STATEPATH = "/run/accentor/server.state";
    SOCKETFILE = "unix:///run/accentor/server.socket";
    RACK_ENV = "production";
    RAILS_ENV = "production";
    RAILS_LOG_TO_STDOUT = "yes";
    RAILS_STORAGE_PATH = "${cfg.home}/storage";
    RAILS_TRANSCODE_CACHE = "/var/tmp/accentor/transcode_cache";
    RUBY_ENABLE_YJIT = "1";
  };
  exports = concatStringsSep
    "\n"
    (mapAttrsToList (name: value: "export ${name}=\"${value}\"") env);
  console = pkgs.writeShellScriptBin "accentor-console" ''
    set -ex
    ${exports}
    export $(cat ${cfg.environmentFile} | xargs)
    cd ${api}
    ${gems}/bin/bundle exec rails c
  '';
in
{
  options.services.accentor = {
    enable = mkEnableOption ''Accentor music server.

      Accentor provides an API through a Ruby on Rails application which can be
      accessed using the Web UI.
    '';

    home = mkOption {
      description = "The directory where Accentor will run.";
      default = "/var/lib/accentor";
      type = types.path;
    };

    hostname = mkOption {
      description = ''
        The virtual hostname on which nginx will host the API and Web UI.
      '';
      example = "accentor.example.com";
      type = types.str;
    };

    workers = mkOption {
      description = ''
        A list of background workers with the queues they should use. Each element in the list will spawn a worker with the queues passed.

        The available options for queues are:
        * `*` (All queues)
        * within_30_seconds
        * within_5_minutes
        * within_30_minutes
        * whenever
        Queues can be configured in different ways. Please check the good job docs for the possibilities: https://github.com/bensheldon/good_job#optimize-queues-threads-and-processes
      '';
      default = [ "+within_30_seconds,within_5_minutes,within_30_minutes,whenever" ];
      example = [ "within_30_seconds" "within_5_minutes:5;within_30_minutes:2;whenever:2" "+within_30_seconds,within_5_minutes,within_30_minutes,whenever" ];
      type = types.listOf types.str;
    };

    environmentFile = mkOption {
      description = ''
        Path to a file containing secret environment variables that should be
        passed to Accentor. Currently this has to contain the SECRET_KEY_BASE
        environment variable which can be generated using rails secret.
      '';
      example = "/run/secrets/accentor";
      type = types.str;
    };

    rescanTimer = {
      enable = mkEnableOption "automatic rescanning of all locations";
      dates = mkOption {
        type = types.str;
        default = "04:44";
        description = ''
          Specification (in the format described by
          <citerefentry><refentrytitle>systemd.time</refentrytitle>
          <manvolnum>7</manvolnum></citerefentry>) of the time at
          which the rescan will be started.
        '';
      };
    };

    nginx = mkOption {
      default = {
        forceSSL = true;
        enableACME = true;
      };
      example = {
        serverAliases = [
          "music.\${config.networking.domain}"
        ];
      };
      description = ''
        With this option, you can customize an nginx virtualHost which already
        has sensible defaults for Accentor. Set this to {} to just enable the
        virtualHost if you don't need any customization. If this is set to
        null (the default), no nginx virtualHost will be configured.
      '';
    };

    apiPackage = mkOption {
      description = "Accentor API package to use";
      default = pkgs.accentor-api;
      defaultText = "pkgs.accentor-api";
      type = types.package;
    };

    webPackage = mkOption {
      description = "Accentor web package to use";
      default = pkgs.accentor-web;
      defaultText = "pkgs.accentor-web";
      type = types.package;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ console ];

    services.postgresql = {
      ensureUsers = [{
        name = "accentor";
        ensureDBOwnership = true;
      }];
      ensureDatabases = [ "accentor" ];
    };

    systemd.tmpfiles.rules = [
      "d /run/accentor 0755 accentor accentor -"
      "d /var/log/accentor 0755 accentor accentor -"
      "d /var/tmp/accentor/transcode_cache 0755 accentor accentor -"
      "d /var/tmp/accentor/bootsnap 0755 accentor accentor -"
      "d ${cfg.home}/storage 0755 accentor accentor -"
    ];

    systemd.services = {
      accentor-api = {
        after = [ "network.target" "postgresql.service" ];
        requires = [ "postgresql.service" "accentor-api.socket" ];
        wantedBy = [ "multi-user.target" ];
        environment = env;
        path = [ pkgs.ffmpeg gems gems.wrappedRuby ];
        serviceConfig = {
          EnvironmentFile = cfg.environmentFile;
          Type = "simple";
          User = "accentor";
          Group = "accentor";
          Restart = "on-failure";
          WorkingDirectory = api;
          ExecStartPre = [
            "${gems}/bin/bundle exec rails db:migrate"
            "${gems}/bin/bundle exec rails ffmpeg:check_version"
          ];
          ExecStart = "${gems}/bin/puma -C ${api}/config/puma.rb";
        };
      };
    } // (builtins.foldl' (x: y: x // y) { } (lib.lists.imap0
      (index: value: {
        "accentor-worker-${toString (index)}" = {
          after = [ "network.target" "accentor-api.service" "postgresql.service" ];
          requires = [ "postgresql.service" ];
          wantedBy = [ "multi-user.target" ];
          environment = env // {
            GOOD_JOB_QUEUES = value;
          };
          path = [ pkgs.ffmpeg gems gems.wrappedRuby ];
          serviceConfig = {
            EnvironmentFile = cfg.environmentFile;
            Type = "simple";
            User = "accentor";
            Group = "accentor";
            Restart = "on-failure";
            WorkingDirectory = api;
            ExecStart = "${gems}/bin/bundle exec good_job start";
          };
        };
      })
      cfg.workers
    ))
    // lib.optionalAttrs cfg.rescanTimer.enable {
      accentor-rescan = {
        description = "Accentor rescan";
        restartIfChanged = false;
        unitConfig.X-StopOnRemoval = false;
        environment = env;
        path = [ gems gems.wrappedRuby ];
        serviceConfig = {
          EnvironmentFile = cfg.environmentFile;
          Type = "oneshot";
          User = "accentor";
          Group = "accentor";
          WorkingDirectory = api;
          ExecStart = "${gems}/bin/bundle exec rails rescan:start";
        };
        startAt = cfg.rescanTimer.dates;
      };
    };

    systemd.sockets = {
      accentor-api = {
        wantedBy = [ "sockets.target" ];
        wants = [ "accentor-api.service" ];
        listenStreams = [ "0.0.0.0:3000" "/run/accentor/server.socket" ];
        socketConfig = {
          Backlog = 1024;
          NoDelay = true;
          ReusePort = true;
        };
      };
    };

    users.users.accentor = {
      group = "accentor";
      home = cfg.home;
      createHome = true;
      uid = 314;
    };
    users.groups.accentor.gid = 314;

    services.nginx.upstreams = mkIf (cfg.nginx != null) {
      "accentor_api_server" = {
        servers = {
          "unix:///run/accentor/server.socket" = { };
        };
      };
    };

    services.nginx.virtualHosts = mkIf (cfg.nginx != null) {
      "${cfg.hostname}" = mkMerge [
        cfg.nginx
        {
          root = web;
          locations = {
            "/api" = {
              proxyPass = "http://accentor_api_server";
              extraConfig = ''
                proxy_set_header X-Forwarded-Ssl on;
                client_max_body_size 40M;
              '';
            };
            "/rails" = {
              proxyPass = "http://accentor_api_server";
              extraConfig = ''
                proxy_set_header X-Forwarded-Ssl on;
              '';
            };
            "/".extraConfig = ''
              autoindex on;
              try_files $uri $uri/ /index.html =404;
            '';
          };
        }
      ];
    };
  };
}
