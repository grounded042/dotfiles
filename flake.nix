# https://gist.github.com/jmatsushita/5c50ef14b4b96cb24ae5268dab613050
# https://github.com/malob/nixpkgs/blob/master/flake.nix
{
  description = "Jon Carl's cross-platform dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-25.05-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    darwin.url = "github:nix-darwin/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

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
    inherit (nixpkgs.lib) nixosSystem;
    currentSystem = import ./current_system.nix;
    username = 
      if currentSystem ? username && currentSystem.username != null && currentSystem.username != ""
      then currentSystem.username
      else throw "Username not configured or empty in current_system.nix";
    
    # Host definitions
    hosts = {
      "pollux" = {
        platform = "nixos";
        system = "x86_64-linux";
      };
      "joncarl-macbook" = {
        platform = "darwin";
        system = "aarch64-darwin";
      };
    };
    
    # Helper to create configurations based on platform
    mkHost = hostname: hostConfig: let
      system = hostConfig.system;
      platform = hostConfig.platform;
      
      # Common configuration shared between platforms
      commonConfig = {
        inherit system;
        specialArgs = {inherit username;};
        modules = [
          ./hosts/${hostname}
          ./modules/platforms/${platform}
          currentSystem.configuration
          (if platform == "darwin" then home-manager.darwinModules.home-manager else home-manager.nixosModules.home-manager)
          {
            nixpkgs.overlays = [ 
              self.overlays.default
              (import ./modules/platforms/${platform}/overlay.nix) 
            ];
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              extraSpecialArgs = {inherit colmena username;};
              users.${username} = import ./home.nix;
              sharedModules = [agenix.homeManagerModules.age];
            };
            environment.systemPackages = [agenix.packages.${system}.default];
          }
        ];
      };
    in {
      name = hostname;
      value = if platform == "darwin" then darwinSystem commonConfig else nixosSystem commonConfig;
    };

    # Separate by platform
    darwinHosts = nixpkgs.lib.filterAttrs (_: config: config.platform == "darwin") hosts;
    nixosHosts = nixpkgs.lib.filterAttrs (_: config: config.platform == "nixos") hosts;
  in {
    darwinConfigurations = nixpkgs.lib.mapAttrs' mkHost darwinHosts;
    nixosConfigurations = nixpkgs.lib.mapAttrs' mkHost nixosHosts;

    overlays.default = final: prev: let
      unstable = import inputs.nixpkgs-unstable {
        system = prev.system;
        config.allowUnfree = true;
      };
    in {
      git = prev.git.override {
        osxkeychainSupport = false;
      };
      claude-code = unstable.claude-code;
    };
  };
}
