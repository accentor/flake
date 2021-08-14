{ mkYarnPackage
, fetchFromGitHub
, packageJSON ? ./package.json
, yarnLock ? ./yarn.lock
, yarnNix ? ./yarn.nix
,
}:

mkYarnPackage rec {
  pname = "accentor-web";
  version = "0.24.1";

  src = fetchFromGitHub {
    owner = "accentor";
    repo = "web";
    rev = "v${version}";
    sha256 = "XI+ye9KEVDNCOxHw7oRi3ea8xJQ676KJpuJgR3onwMg=";
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
