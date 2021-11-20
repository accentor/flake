{ mkYarnPackage
, fetchFromGitHub
, packageJSON ? ./package.json
, yarnLock ? ./yarn.lock
, yarnNix ? ./yarn.nix
,
}:

mkYarnPackage rec {
  pname = "accentor-web";
  version = "0.27.0";

  src = fetchFromGitHub {
    owner = "accentor";
    repo = "web";
    rev = "v${version}";
    sha256 = "8cS0O74WFkp5WV96MuS1d5SAfnHtWgajpJUUHtT2yJ8=";
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
