# https://gist.github.com/jmatsushita/5c50ef14b4b96cb24ae5268dab613050
# https://github.com/malob/nixpkgs/blob/master/flake.nix

{
  description = "Jon Carl's darwin setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-24.11-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    agenix.url = "github:ryantm/agenix";
  };

  outputs = { self, darwin, nixpkgs, home-manager, agenix, ...}@inputs:
  let
    inherit (darwin.lib) darwinSystem;
    currentSystem = import ./current_system.nix;
  in
  {
    darwinConfigurations = rec {
      joncarl-macbook = darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${currentSystem.username} = import ./home.nix;
          }
          agenix.nixosModules.default
          {
            environment.systemPackages = [ agenix.packages.aarch64-darwin.default ];
          }
        ];
      };
    };

    nixpkgs.overlays = [
      (self: super: {
        git = super.git.override {
          osxkeychainSupport = false;
        };
      })
    ];
  };
}
