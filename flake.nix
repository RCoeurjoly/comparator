{
  description = "poetry2nix bundle";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    poetry2nix = {
      url = "github:RCoeurjoly/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    bundlers = {
      url = "github:NixOS/bundlers";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix, bundlers }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; overlays = [ self.overlay ]; };

      customOverrides = self: super: {
        # Overrides go here
        idna = super.idna.overridePythonAttrs (
          old: {
            buildInputs = (old.buildInputs or [ ]) ++ [ self.flit-core ];
          }
        );
        wildq = super.wildq.overridePythonAttrs (
          old: {
            buildInputs = (old.buildInputs or [ ]) ++ [ self.poetry ];
          }
        );

      };
      my-name = "my-script";
      my-script = (pkgs.writeScriptBin my-name (builtins.readFile ./simple-script.sh)).overrideAttrs(old: {
        buildCommand = "${old.buildCommand}\n patchShebangs $out";
      });
      packageName = "BME";
    in {

      # Nixpkgs overlay providing the application
      overlay = nixpkgs.lib.composeManyExtensions [
        poetry2nix.overlay
        (final: prev: {
          # The application
          myapp = prev.poetry2nix.mkPoetryApplication {
            projectDir = ./.;
            overrides =
              [ prev.poetry2nix.defaultPoetryOverrides customOverrides ];
          };

          myAppEnv = pkgs.poetry2nix.mkPoetryEnv {
            projectDir = ./.;
            editablePackageSources = {
              my-app = ./src;
            };
            overrides =
              [ pkgs.poetry2nix.defaultPoetryOverrides customOverrides ];
          };

        })
      ];
      packages.x86_64-linux.my-script = pkgs.symlinkJoin {
        name = my-name;
        paths = [ my-script self.packages.x86_64-linux.default ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
                  wrapProgram $out/bin/${my-name} --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.coreutils self.packages.x86_64-linux.default ]}
          '';
      };
      packages.x86_64-linux.default = pkgs.myapp;
      devShells.x86_64-linux.default = pkgs.myAppEnv.env.overrideAttrs (oldAttrs: {
        buildInputs = with pkgs; [ poetry pkgs.geckodriver ];
      });
      apps.x86_64-linux.default = { type = "app"; program = "${self.packages.x86_64-linux.default}/bin/bme"; };
      packages.x86_64-linux.bme_rpm = bundlers.bundlers.x86_64-linux.toRPM self.packages.x86_64-linux.default;
    };
}
