{
  description = "A modern music server focusing on metadata";
  outputs = { self, nixpkgs }: {
    nixosModule = import ./default.nix;
  };
}
