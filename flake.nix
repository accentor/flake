{
  description = "A modern music server focusing on metadata";
  outputs = { self, nixpkgs }: rec {
    nixosModules.accentor = import ./default.nix;
    nixosModule = nixosModules.accentor;
  };
}
