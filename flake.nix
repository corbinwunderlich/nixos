{
  description = "A NixOS configuration for my personal computers";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";

    nvidia-vgpu.url = "github:mrzenc/vgpu4nixos";

    sops-nix.url = "github:Mic92/sops-nix";

    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";

    split-monitor-workspaces = {
      url = "github:Duckonaut/split-monitor-workspaces";
      inputs.hyprland.follows = "hyprland";
    };

    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprlock = {
      url = "github:hyprwm/hyprlock";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ags.url = "github:Aylur/ags/v1";

    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    nixvim.url = "github:CorbinWunderlich/neovim";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    nixpkgs,
    nixpkgs-stable,
    home-manager,
    sops-nix,
    nvidia-vgpu,
    nixos-hardware,
    ...
  }: {
    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          machine = "desktop";
        };

        system = "x86_64-linux";

        modules = [
          ./desktop/configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = {
              inherit inputs;
              machine = "desktop";
            };
            home-manager.useGlobalPkgs = true;
            home-manager.users.corbin = import ./users/corbin/desktop/home.nix;
          }
        ];
      };

      nixvm = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          machine = "vm";
        };

        system = "x86_64-linux";

        modules = [
          ./nixvm/configuration.nix

          nvidia-vgpu.nixosModules.guest

          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = {
              inherit inputs;
              machine = "vm";
            };
            home-manager.useGlobalPkgs = true;
            home-manager.users.corbin = import ./users/corbin/nixvm/home.nix;
          }
        ];
      };

      nixpad = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          machine = "laptop";
        };

        system = "x86_64-linux";

        modules = [
          ./nixpad/configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = {
              inherit inputs;
              machine = "laptop";
            };
            home-manager.useGlobalPkgs = true;
            home-manager.users.corbin = import ./users/corbin/nixpad/home.nix;
          }

          nixos-hardware.nixosModules.lenovo-thinkpad-t14
        ];
      };
    };
  };
}
