# Shared derivations and helpers used by both the NixOS and Home Manager modules.
# Returns: { sboxBase, sboxDirenv, sboxWrapped, sboxDirenvWrapped, sboxArgs }
{ wrappers, lib, pkgs, cfg }:
let
  sboxPackageArgs = {
    inherit (cfg) packages shellHook;
    env = cfg.environment;
  };

  # Build the sbox package with module-configured overrides.
  sboxBase = pkgs.callPackage ./sbox.nix sboxPackageArgs;

  # sbox with direnv-specific bind mounts:
  #  - direnv allow/deny database (read-only)
  #  - exit-dir file for CWD sync between inner and outer shell
  sboxDirenv = pkgs.callPackage ./sbox.nix (sboxPackageArgs // {
    bubblewrapArgs = [
      "--ro-bind-try" "$HOME/.local/share/direnv" "$HOME/.local/share/direnv"
      "--ro-bind-try" "$HOME/.local/share/direnv-sandbox" "$HOME/.local/share/direnv-sandbox"
      "--bind" "$_DIRENV_SANDBOX_EXIT_DIR_FILE" "$_DIRENV_SANDBOX_EXIT_DIR_FILE"
    ];
  });

  bindMountArgs = flag: mounts:
    lib.concatMap (src:
      let dst = mounts.${src}.to;
      in [ flag src dst ]
    ) (builtins.attrNames mounts);

  sboxArgs =
    (bindMountArgs "--bind-try" cfg.bind)
    ++ (bindMountArgs "--ro-bind-try" cfg.bindReadOnly)
    ++ (lib.concatMap (p: [ "--allow-port" (toString p) ]) cfg.allowedTCPPorts)
    ++ (lib.concatMap (p: [ "--expose-port" (toString p) ]) cfg.exposedTCPPorts)
    ++ (lib.optionals cfg.hostNetwork [ "--network" "host" ])
    ++ (lib.optionals (cfg.allowParent != "off") [ "--allow-parent" cfg.allowParent ])
    ++ (lib.optionals cfg.allowAudio [ "--audio" ])
    ++ (lib.optionals (!cfg.shareKnownHosts) [ "--no-known-hosts" ])
    ++ (lib.optionals (cfg.shareHistory != "host") [ "--history" cfg.shareHistory ])
    ++ (lib.concatMap (p: [ "--persist" p ]) cfg.persist);

  # Standalone wrapper: bakes in module-configured args for manual use.
  sboxWrapped = wrappers.lib.wrapPackage {
    inherit pkgs;
    package = sboxBase;
    args = sboxArgs;
  };

  # Direnv wrapper: same args, but includes direnv-specific bind mounts.
  sboxDirenvWrapped = wrappers.lib.wrapPackage {
    inherit pkgs;
    package = sboxDirenv;
    args = sboxArgs;
  };
in
{
  inherit sboxBase sboxDirenv sboxWrapped sboxDirenvWrapped sboxArgs;
}
