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
            ...
          }:
          mkShell {
            packages = [
              bubblewrap
              slirp4netns
            ];
          };
      };

      modules.nixos = {
        default = import ./module.nix { inherit wrappers; };
        direnv-sandbox = import ./module.nix { inherit wrappers; };
      };
    };
  }
)
