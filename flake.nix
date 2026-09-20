{
  description = "A NixOS configuration for my personal computers";

  inputs = {
    systems.url = "github:nix-systems/default";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    xwayland-satellite = {
      url = "github:supreeeme/xwayland-satellite";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "";
      };
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim.url = "github:CorbinWunderlich/neovim";

    affinity-nix.url = "github:mrshmllow/affinity-nix";

    home-manager = {
      url = "github:nix-community/home-manager?ref=release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    _1password-shell-plugins = {
      url = "github:1Password/shell-plugins";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    systems,
    nixpkgs,
    home-manager,
    nix-flatpak,
    sops-nix,
    nixos-hardware,
    determinate,
    nix-index-database,
    self,
    ...
  }: let
    forEachSystem = nixpkgs.lib.genAttrs (import systems);
  in {
    formatter = forEachSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        config = self.checks.${system}.pre-commit-check.config;
        inherit (config) package configFile;
        script = ''
          ${pkgs.lib.getExe package} run --all-files --config ${configFile}
        '';
      in
        pkgs.writeShellScriptBin "pre-commit-run" script
    );

    checks = forEachSystem (system: {
      pre-commit-check = inputs.git-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          alejandra.enable = true;

          deadnix = {
            enable = true;
            settings = {
              edit = true;
            };
          };

          statix = {
            enable = true;
            settings = {
              format = "stderr";
            };
          };
        };
      };
    });

    devShells = forEachSystem (system: {
      default = let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        pkgs.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;

          buildInputs = with pkgs; [nh] ++ self.checks.${system}.pre-commit-check.enabledPackages;
        };
    });

    packages.x86_64-linux = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
      sw = pkgs.callPackage ./packages/sw.nix {};
      sw_swaybar = pkgs.callPackage ./packages/sw_swaybar.nix {
        inherit (self.packages.x86_64-linux) sw;
      };
    };

    nixosConfigurations = let
      commonModules = {
        configuration,
        home,
        machine,
      }: [
        configuration

        nix-flatpak.nixosModules.nix-flatpak

        determinate.nixosModules.default

        nix-index-database.nixosModules.default

        home-manager.nixosModules.home-manager
        {
          home-manager = {
            extraSpecialArgs = {inherit inputs machine;};

            useGlobalPkgs = true;
            users.corbin = import home;
            sharedModules = [sops-nix.homeManagerModules.sops];
          };
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

        modules = commonModules {
          configuration = ./nixvm/configuration.nix;
          home = ./users/corbin/nixvm/home.nix;
          machine = "vm";
        };
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
            nixos-hardware.nixosModules.lenovo-thinkpad-p14s-amd-gen6
          ];
      };
    };
  };
}
