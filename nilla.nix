let
  tamal = import ./nix/tamal { };
  nilla = import tamal.nilla;
in
nilla.create (
  { config }:
  let
    inherit (config.lib) systems;
    wrappers = config.inputs.wrappers.result;
  in
  {
    config = {
      lib.systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      inputs = {
        nixpkgs = {
          src = tamal.nixpkgs;
          loader = "nixpkgs";
          settings.systems = systems;
        };

        wrappers = {
          src = tamal.wrappers;
          loader = "legacy";
          settings.args = {
            pkgs = {
              lib = config.inputs.nixpkgs.result.lib;
            };
          };
        };

        home-manager = {
          src = tamal.home-manager;
          loader = "raw";
        };

        nilla-cli = {
          src = tamal.nilla-cli;
          loader = "nilla";
        };
      };

      packages = {
        sbox = {
          inherit systems;
          package = import ./sbox.nix;
        };

        direnv-sandbox = {
          inherit systems;
          package = import ./direnv-sandbox.nix;
        };
      };

      shells.default = {
        inherit systems;
        shell =
          {
            mkShell,
            bubblewrap,
            slirp4netns,
            system,
            ...
          }:
          let
            nilla-cli = config.inputs.nilla-cli.result.packages.nilla-cli.result.${system};
          in
          mkShell {
            packages = [
              bubblewrap
              slirp4netns
              nilla-cli
            ];
          };
      };

      modules.nixos = {
        default = import ./module.nix { inherit wrappers; };
        direnv-sandbox = import ./module.nix { inherit wrappers; };
      };

      modules.homeManager = {
        default = import ./hm-module.nix { inherit wrappers; };
        direnv-sandbox = import ./hm-module.nix { inherit wrappers; };
      };
    };
  }
)
