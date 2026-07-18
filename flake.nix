# https://gist.github.com/jmatsushita/5c50ef14b4b96cb24ae5268dab613050
# https://github.com/malob/nixpkgs/blob/master/flake.nix
{
  description = "Jon Carl's cross-platform dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";
    darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    colmena.url = "github:zhaofengli/colmena";

    quickshell.url = "git+https://git.outfoxxed.me/outfoxxed/quickshell?rev=dacfa9de829ac7cb173825f593236bf2c21f637e";
    quickshell.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "github:hyprwm/Hyprland/v0.54.3";
  };

  outputs = {
    self,
    darwin,
    nixpkgs,
    home-manager,
    agenix,
    colmena,
    quickshell,
    hyprland,
    ...
  } @ inputs: let
    inherit (darwin.lib) darwinSystem;
    inherit (nixpkgs.lib) nixosSystem;

    mkConfigurations = {currentSystem ? import ./current_system.nix}: let
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

        pkgsSrc =
          if platform == "darwin"
          then inputs.nixpkgs-darwin
          else inputs.nixpkgs;
        pkgs = import pkgsSrc {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            self.overlays.default
            (import ./modules/platforms/${platform}/overlay.nix)
          ];
        };

        # Common configuration shared between platforms
        commonConfig = {
          inherit system;
          inherit pkgs;

          specialArgs = {inherit username hyprland currentSystem;};
          modules = [
            ./hosts/${hostname}
            ./modules/platforms/${platform}
            currentSystem.configuration
            (
              if platform == "darwin"
              then home-manager.darwinModules.home-manager
              else home-manager.nixosModules.home-manager
            )
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                extraSpecialArgs = {inherit colmena quickshell hyprland username currentSystem;};
                users.${username} = import ./home.nix;
                sharedModules = [agenix.homeManagerModules.age];
              };
              environment.systemPackages = [agenix.packages.${system}.default];
            }
          ];
        };
      in {
        name = hostname;
        value =
          if platform == "darwin"
          then darwinSystem commonConfig
          else nixosSystem commonConfig;
      };

      # Separate by platform
      darwinHosts = nixpkgs.lib.filterAttrs (_: config: config.platform == "darwin") hosts;
      nixosHosts = nixpkgs.lib.filterAttrs (_: config: config.platform == "nixos") hosts;
    in {
      darwinConfigurations = nixpkgs.lib.mapAttrs' mkHost darwinHosts;
      nixosConfigurations = nixpkgs.lib.mapAttrs' mkHost nixosHosts;
    };
  in
    (mkConfigurations {})
    // {
      lib.mkConfigurations = mkConfigurations;

      overlays.default = final: prev: {
        claude-code = prev.callPackage (self + "/packages/claude-code/package.nix") {};
        opencode = prev.callPackage (self + "/packages/opencode") {};
        opencode-dcp = prev.callPackage (self + "/packages/opencode-dcp") {};
        rtk = prev.callPackage (self + "/packages/rtk") {};
        direnv = prev.direnv.overrideAttrs (oldAttrs: {
          doCheck = false;
        });
        # nix-2.31 functional tests fail on macOS (nixpkgs 25.11 issue);
        # override in the overlay so all dependents (niv, nixd, etc.) use the patched version
        nix = prev.nix.overrideAttrs (_: {doCheck = false;});
      };
    };
}
