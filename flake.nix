# https://gist.github.com/jmatsushita/5c50ef14b4b96cb24ae5268dab613050
# https://github.com/malob/nixpkgs/blob/master/flake.nix
{
  description = "Jon Carl's darwin setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-25.05-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    darwin.url = "github:nix-darwin/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    agenix.url = "github:ryantm/agenix";
    colmena.url = "github:zhaofengli/colmena";
  };

  outputs = {
    self,
    darwin,
    nixpkgs,
    home-manager,
    agenix,
    colmena,
    ...
  } @ inputs: let
    inherit (darwin.lib) darwinSystem;
    currentSystem = import ./current_system.nix;
    username = currentSystem.username;
  in {
    darwinConfigurations = rec {
      joncarl-macbook = darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {inherit username;};
        modules = [
          ./configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {inherit colmena username;};
              users.${username} = import ./home.nix;
              sharedModules = [agenix.homeManagerModules.age];
            };
            environment.systemPackages = [agenix.packages.aarch64-darwin.default];
          }
        ];
      };
    };

    nixpkgs.overlays = [
      (self: super: {
        git = super.git.override {
          osxkeychainSupport = false;
        };
        claude-code = inputs.nixpkgs-unstable.claude-code;
      })
    ];
  };
}
