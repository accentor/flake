{
  description = "A modern music server focusing on metadata";
  outputs = { self }: rec {
    nixosModules.accentor = import ./default.nix;
    nixosModule = nixosModules.accentor;
  };
}
