{ nixosModule, shell ? "bash" }:
{ lib, testers, bash, zsh, fish, ... }:
let
  common = import ./vm-common.nix {
    inherit lib testers bash zsh fish shell;
    name = "direnv-sandbox";
    nodeConfig = nodeConfig;
  };
  nodeConfig =
    { pkgs, ... }:
    {
      imports = [ nixosModule ];

      networking.useDHCP = false;

      users.users.alice = {
        isNormalUser = true;
        password = "foobar";
        shell = common.shellPkgs.${shell};
      };

      programs.zsh.enable = shell == "zsh";
      programs.fish.enable = shell == "fish";

      programs.direnv = {
        enable = true;
        sandbox = {
          enable = true;
          bind = {
            "$HOME/.cache" = {};
          };
        };
      };

      system.activationScripts.createProject =
        common.mkProjectActivationScript { zshrcWorkaround = true; };
    };
in
common.test
