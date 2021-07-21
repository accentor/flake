{
  description = "A modern music server focusing on metadata";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  outputs = { self, nixpkgs }:
  let
    call = system: package:
      nixpkgs.legacyPackages.${system}.callPackage package {};
    makePackages = system: {
      accentor-api = call system ./pkgs/api.nix;
      accentor-api-env = call system ./pkgs/api-env.nix;
      accentor-web = call system ./pkgs/web.nix;
    };
  in rec {
    packages."x86_64-linux" = makePackages "x86_64-linux";

    nixosModules.accentor = import ./default.nix;
    nixosModule = nixosModules.accentor;
  };
}
