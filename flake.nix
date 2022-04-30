{
  description = "A modern music server focusing on metadata";
  inputs = {
    api = {
      url = "github:accentor/api/v0.17.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    web = {
      url = "github:accentor/web/v0.30.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs, api, web }:
    rec {
      packages.x86_64-linux = {
        accentor-api = api.defaultPackage.x86_64-linux;
        accentor-web = web.defaultPackage.x86_64-linux;
      };
      nixosModules.accentor = import ./default.nix;
      nixosModule = nixosModules.accentor;
      overlay = (self: super: {
        accentor-api = api.defaultPackage.${self.system};
        accentor-web = web.defaultPackage.${self.system};
      });
    };
}
