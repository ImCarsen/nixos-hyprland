{
  description = "Carsen's NixOS Config";

  inputs = {
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
    nixpkgs.url = "github:nixos/nixpkgs";
    nur.url = "github:nix-community/NUR";

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    theme-toggler = {
      url = "github:redstonekasi/theme-toggler";
      flake = false;
    };

    web-greeter = {
      type = "git";
      url = "https://github.com/JezerM/web-greeter";
      submodules = true;
      flake = false;
    };
  };

  outputs = {
    self,
    fenix,
    nixpkgs,
    home-manager,
    nixos-wsl,
    hyprland,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;
    forSystems = lib.genAttrs lib.systems.flakeExposed;
  in {
    defaultPackage.x86_64-linux = fenix.packages.x86_64-linux.minimal.toolchain;
    nixosConfigurations = {
      nix = lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          ./sys/nix/configuration.nix
          home-manager.nixosModule
          hyprland.nixosModules.default
        ];
      };
      wsl = lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          ./sys/wsl.nix
          nixos-wsl.nixosModules.wsl
          home-manager.nixosModule
        ];
      };
    };
    devShells = forSystems (
      system: let
        pkgs = nixpkgs.legacyPackages."${system}";
      in {
        default = pkgs.mkShellNoCC {
          packages = with pkgs; [nvfetcher];
        };
      }
    );
  };
}
