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
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "accentor";
    repo = "api";
    rev = "v${version}";
    sha256 = "j2dvkff7mIQZaQAepKL12Z3yTr3HmWXRujhj/Aa23Y0=";
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
