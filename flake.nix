{
  description = "A modern music server focusing on metadata";
  inputs = {
    api = {
      url = "github:accentor/api/v0.23.0";
      inputs = {
        devshell.follows = "devshell";
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };
    web = {
      url = "github:accentor/web/v0.34.0";
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
          accentor-web = web.packages.${system}.default;
        };
        devShell = let pkgs = import nixpkgs { inherit system; overlays = [ devshell.overlays.default ]; }; in
          pkgs.devshell.mkShell {
            name = "Accentor flake";
            packages = [ pkgs.nixpkgs-fmt ];
          };
      }) // rec {
      nixosModules = rec {
        accentor = import ./default.nix;
        default = accentor;
      };
      overlays.default = (self: super: {
        accentor-api = api.packages.${self.system}.default;
        accentor-web = web.packages.${self.system}.default;
      });
    };
}
