{ stdenv
, fetchFromGitHub
, ruby_3_1
, bundlerEnv
, gemfile ? ./Gemfile
, lockfile ? ./Gemfile.lock
, gemset ? ./gemset.nix
,
}:

stdenv.mkDerivation rec {
  pname = "accentor-api";
  version = "0.17.0";

  src = fetchFromGitHub {
    owner = "accentor";
    repo = "api";
    rev = "v${version}";
    sha256 = "r4HxPlg6DCYDhzC8hCpx3UaAG5/8P5JTHRd/C5X1924=";
  };

  installPhase = ''
    mkdir $out
    cp -r * $out
  '';

  passthru.env = bundlerEnv rec {
    name = "accentor-api-env";
    ruby = ruby_3_1;
    inherit gemfile lockfile gemset;
    groups = [ "default" "development" "test" "production" ];
  };
}
