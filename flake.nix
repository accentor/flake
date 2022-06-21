{
  description = "A modern music server focusing on metadata";
  inputs = {
    api = {
      url = "github:accentor/api/v0.17.3";
      inputs = {
        devshell.follows = "devshell";
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };
    web = {
      url = "github:accentor/web/v0.30.1";
      inputs = {
        devshell.follows = "devshell";
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };
    devshell = {
      url = "github:numtide/devshell";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = { self, api, web, devshell, flake-utils, nixpkgs }:
    flake-utils.lib.eachDefaultSystem
      (system: {
        packages = {
          accentor-api = api.packages.${system}.default;
          accentor-web = web.defaultPackage.${system};
        };
        devShell = let pkgs = import nixpkgs { inherit system; overlays = [ devshell.overlay ]; }; in
          pkgs.devshell.mkShell {
            name = "Accentor flake";
            packages = [ pkgs.nixpkgs-fmt ];
          };
      }) // rec {
      nixosModules.accentor = import ./default.nix;
      nixosModule = nixosModules.accentor;
      overlay = (self: super: {
        accentor-api = api.defaultPackage.${self.system};
        accentor-web = web.defaultPackage.${self.system};
      });
    };
}
