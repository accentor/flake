{ mkYarnPackage
, fetchFromGitHub
, packageJSON ? ./package.json
, yarnLock ? ./yarn.lock
, yarnNix ? ./yarn.nix
,
}:

mkYarnPackage rec {
  pname = "accentor-web";
  version = "0.26.0";

  src = fetchFromGitHub {
    owner = "accentor";
    repo = "web";
    rev = "v${version}";
    sha256 = "92jZuYp9osuSNgkPHeGgB+bhTETUpPbkwsi4adkrnkQ=";
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
