# Flake compatibility wrapper. The actual project entry point is nilla.nix.
{
  description = "Bubblewrap sandboxing for direnv sessions";

  # All inputs are managed by nixtamal via nilla.nix — no flake inputs needed.
  inputs = { };

  outputs =
    { self }:
    (import ./nilla.nix).flakeOutputs;
}
