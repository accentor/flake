{ stdenv
, fetchFromGitHub
, ruby_3_0
, bundlerEnv
, gemfile ? ./Gemfile
, lockfile ? ./Gemfile.lock
, gemset ? ./gemset.nix
,
}:

stdenv.mkDerivation rec {
  pname = "accentor-api";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "accentor";
    repo = "api";
    rev = "v${version}";
    sha256 = "TNAim8tGY/+z0+E/4A3/4nVTj2ivdKP6kmRY3+W4fUc=";
  };

  installPhase = ''
    mkdir $out
    cp -r * $out
  '';

  passthru.env = bundlerEnv rec {
    name = "accentor-api-env";
    ruby = ruby_3_0;
    inherit gemfile lockfile gemset;
    groups = [ "default" "development" "test" "production" ];
  };
}
