{
  description = "Development flake for accentor nixos modules";
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs: {
    devShells = builtins.mapAttrs (
      system: pkgs':
      let
        pkgs = pkgs'.extend inputs.devshell.overlays.default;
      in
      {
        flake = pkgs.devshell.mkShell {
          name = "Accentor flake";
          packages = [ pkgs.nixfmt ];
        };
        default = inputs.self.devShells.${system}.flake;
      }
    ) inputs.nixpkgs.legacyPackages;
  };
}
