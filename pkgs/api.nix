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
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "accentor";
    repo = "api";
    rev = "v${version}";
    sha256 = "bgn5ByLN+yVln711O62hcLYH+RK1ky+NdvyJdIfFLUc=";
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
