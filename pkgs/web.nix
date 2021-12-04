{ mkYarnPackage
, fetchFromGitHub
, packageJSON ? ./package.json
, yarnLock ? ./yarn.lock
, yarnNix ? ./yarn.nix
,
}:

mkYarnPackage rec {
  pname = "accentor-web";
  version = "0.29.0";

  src = fetchFromGitHub {
    owner = "accentor";
    repo = "web";
    rev = "v${version}";
    sha256 = "wd53oF0Owh7j+5SBR6YoRg2Q6jgDbHEEZhk9aNsb25s=";
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
