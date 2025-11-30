{
  description = "A NixOS configuration for my personal computers";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    nvidia-vgpu.url = "github:mrzenc/vgpu4nixos";

    sops-nix.url = "github:Mic92/sops-nix";

    xwayland-satellite.url = "github:supreeeme/xwayland-satellite";

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

    affinity-nix.url = "github:corbinwunderlich/affinity-nix";
    affinity-nix.inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=1925c603f17fc89f4c8f6bf6f631a802ad85d784";

    home-manager = {
      url = "github:nix-community/home-manager?ref=release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    _1password-shell-plugins.url = "github:1Password/shell-plugins";
  };

  outputs = inputs @ {
    nixpkgs,
    home-manager,
    nix-flatpak,
    sops-nix,
    nvidia-vgpu,
    nixos-hardware,
    ...
  }: {
    nixosConfigurations = let
      commonModules = {
        configuration,
        home,
        machine,
      }: [
        configuration

        nix-flatpak.nixosModules.nix-flatpak

        home-manager.nixosModules.home-manager
        {
          home-manager.extraSpecialArgs = {inherit inputs machine;};

          home-manager.useGlobalPkgs = true;
          home-manager.users.corbin = import home;
          home-manager.sharedModules = [sops-nix.homeManagerModules.sops];
        }
      ];
    in {
      desktop = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          machine = "desktop";
        };

        system = "x86_64-linux";

        modules =
          commonModules {
            configuration = ./desktop/configuration.nix;
            home = ./users/corbin/desktop/home.nix;
            machine = "desktop";
          }
          ++ (with nixos-hardware.nixosModules; [
            common-cpu-amd
            common-cpu-amd-pstate
            common-cpu-amd-raphael-igpu
            common-gpu-amd
            common-pc
            common-pc-ssd
            common-hidpi
          ]);
      };

      nixvm = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          machine = "vm";
        };

        system = "x86_64-linux";

        modules =
          commonModules {
            configuration = ./nixvm/configuration.nix;
            home = ./users/corbin/nixvm/home.nix;
            machine = "vm";
          }
          ++ [
            nvidia-vgpu.nixosModules.guest
          ];
      };

      nixpad = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          machine = "laptop";
        };

        system = "x86_64-linux";

        modules =
          commonModules {
            configuration = ./nixpad/configuration.nix;
            home = ./users/corbin/nixpad/home.nix;
            machine = "laptop";
          }
          ++ [
            nixos-hardware.nixosModules.lenovo-thinkpad-p14s-amd-gen5
          ];
      };
    };
  };
}
