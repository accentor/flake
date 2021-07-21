{ ruby_3_0, bundlerEnv }:
bundlerEnv rec {
    name = "accentor-api-env";
    ruby = ruby_3_0;
    gemfile = ./Gemfile;
    lockfile = ./Gemfile.lock;
    gemset = ./gemset.nix;
    groups = [ "default" "development" "test" "production" ];
}
