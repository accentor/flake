{
  description = "A modern music server focusing on metadata";
  inputs = {
    api = {
      url = "github:accentor/api/v0.24.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    web = {
      url = "github:accentor/web/v0.35.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  outputs = inputs: {
    packages = builtins.mapAttrs (system: pkgs: {
      accentor-api = inputs.api.packages.${system}.default;
      accentor-web = inputs.web.packages.${system}.default;
    }) inputs.nixpkgs.legacyPackages;
    nixosModules = {
      accentor = import ./default.nix;
      default = inputs.self.nixosModules.accentor;
    };
    overlays.default = (
      self: super: {
        accentor-api = inputs.api.packages.${self.stdenv.hostPlatform.system}.default;
        accentor-web = inputs.web.packages.${self.stdenv.hostPlatform.system}.default;
      }
    );
  };
}
