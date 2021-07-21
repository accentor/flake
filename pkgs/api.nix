{ stdenv, fetchFromGitHub }: stdenv.mkDerivation rec {
  pname = "accentor-api";
  version = "0.11.1";

  src = fetchFromGitHub {
    owner = "accentor";
    repo = "api";
    rev = "v${version}";
    sha256 = "sha256-uOVgwbs0DeHr+D/ihwjL4zMUDUrHlEV1HxCy/5jlJj0=";
  };

  installPhase = ''
    mkdir $out
    cp -r * $out
  '';
}
