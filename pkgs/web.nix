{ mkYarnPackage
, fetchFromGitHub
, packageJSON ? ./package.json
, yarnLock ? ./yarn.lock
, yarnNix ? ./yarn.nix
,
}:

mkYarnPackage rec {
  pname = "accentor-web";
  version = "0.28.1";

  src = fetchFromGitHub {
    owner = "accentor";
    repo = "web";
    rev = "v${version}";
    sha256 = "j3crpSMh9hGLNLnG9uBvYq4AkAug1fJ6k6xO8TcKPqA=";
  };

  inherit packageJSON yarnLock yarnNix;

  buildPhase = ''
    cp deps/accentor/postcss.config.js .
    yarn run build
  '';

  installPhase = ''
    cp -r deps/accentor/dist $out
    rm $out/**/*.map
  '';

  distPhase = "true";
}
