# https://gist.github.com/jmatsushita/5c50ef14b4b96cb24ae5268dab613050
# https://github.com/malob/nixpkgs/blob/master/flake.nix

{
  description = "Jon Carl's darwin setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-23.05-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs = { self, darwin, nixpkgs, home-manager, ...}@inputs:
  let
    inherit (darwin.lib) darwinSystem;
    currentSystem = import ./current_system.nix;
  in
  {
    overlays = {
      home-manager.programs.zsh.sessionVariables = _: prev: {
        prev.extend.TESTING_OVERLAYS = "joncarl1";
      };
    };

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
        ];
      };
    };
  };
}
