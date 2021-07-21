{ mkYarnPackage, fetchFromGitHub }:

mkYarnPackage rec {

  pname = "accentor-web";
  version = "0.24.0";

  src = fetchFromGitHub {
    owner = "accentor";
    repo = "web";
    rev = "v${version}";
    sha256 = "sha256-zB5LppyzvLxeEjYrgjnT/DXiTPGVusFdQQdBAoo/sCU=";
  };

  packageJSON = ./package.json;
  yarnLock = ./yarn.lock;
  yarnNix = ./yarn.nix;

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
