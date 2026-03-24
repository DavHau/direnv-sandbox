{ wrappers }:
{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.programs.direnv.sandbox;
  direnv-cfg = config.programs.direnv;
  pkg = cfg.package;
  sandboxLib = import ./sandbox-lib.nix {
    inherit wrappers lib pkgs cfg;
  };
in
{
  options.programs.direnv.sandbox = import ./options.nix {
    inherit lib pkgs;
    inherit (sandboxLib) sboxDirenvWrapped;
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.sbox.enable {
      home.packages = [ pkgs.bubblewrap sandboxLib.sboxWrapped ];
    })

    (lib.mkIf (direnv-cfg.enable && cfg.enable) {
      home.packages = [ pkg ];

      # Disable direnv's own shell integration — we replace it with sandbox-aware hooks.
      programs.direnv = {
        enableBashIntegration = lib.mkForce false;
        enableZshIntegration = lib.mkForce false;
        enableFishIntegration = lib.mkForce false;
      };

      programs.bash.initExtra = ''
        DIRENV_SANDBOX_CMD=("${lib.getExe cfg.sandboxCommand}")
        DIRENV_SANDBOX_DIRENV_BIN="${lib.getExe direnv-cfg.package}"
        source "${pkg}/share/direnv-sandbox/direnv-sandbox.bash"
      '';

      programs.zsh.initContent = ''
        DIRENV_SANDBOX_CMD=("${lib.getExe cfg.sandboxCommand}")
        DIRENV_SANDBOX_DIRENV_BIN="${lib.getExe direnv-cfg.package}"
        source "${pkg}/share/direnv-sandbox/direnv-sandbox.zsh"
      '';

      # Fish: the direnv package ships share/fish/vendor_conf.d/direnv.fish
      # which auto-hooks direnv regardless of enableFishIntegration. Since
      # vendor_conf.d is sourced before interactiveShellInit, we erase its
      # functions here and replace them with our sandbox-aware hook.
      programs.fish.interactiveShellInit = ''
        functions --erase __direnv_export_eval 2>/dev/null
        functions --erase __direnv_cd_hook 2>/dev/null
        set -gx DIRENV_SANDBOX_CMD "${lib.getExe cfg.sandboxCommand}"
        set -gx DIRENV_SANDBOX_DIRENV_BIN "${lib.getExe direnv-cfg.package}"
        source "${pkg}/share/direnv-sandbox/direnv-sandbox.fish"
      '';
    })
  ];
}
