# Accentor NixOS flake

NixOS module for the [Accentor](https://github.com/accentor/) music server.

## Usage

If you have your system set up with flakes, you can add the Accentor as a
service to your system flake:

```nix
{
  # add this module as an input
  inputs.accentor.url = "github:rien/accentor-nix/main";

  outputs = { self, nixpkgs, accentor }: {
    # change `yourhostname` to your actual hostname
    nixosConfigurations.yourhostname = nixpkgs.lib.nixosSystem {
      # change to your system:
      system = "x86_64-linux";
      modules = [
        # Accentor music server
        accentor.nixosModules.accentor

        # your configuration
        ./configuration.nix
      ];
    };
  };
}
```

Next, you can enable this service as if it is a normal NixOS service:

```nix
{
  services.accentor = {
    enable = true;
    hostname = "accentor.example.com";
    workers = 8;
    environmentFile = "/var/lib/accentor/secret.env";
  };
}
```
