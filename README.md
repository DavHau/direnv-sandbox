# direnv-sandbox has moved

This project has moved to **[DavHau/sbox](https://github.com/DavHau/sbox)**.

The direnv integration lives at [DavHau/sbox/direnv-sandbox](https://github.com/DavHau/sbox/tree/main/direnv-sandbox).

Please update your flake inputs:

```nix
# Before
direnv-sandbox.url = "github:DavHau/direnv-sandbox";

# After
sbox.url = "github:DavHau/sbox";
```

Use the new module names:

```nix
# NixOS
sbox.nixosModules.direnv-sandbox

# Home Manager
sbox.homeManagerModules.direnv-sandbox
```

And move your sandbox configuration from `programs.direnv.sandbox` to `programs.sbox`:

```nix
# Before
programs.direnv.sandbox = {
  enable = true;
  bind."$HOME/.cache" = {};
  network = "isolated";
};

# After
programs.sbox = {
  bind."$HOME/.cache" = {};
  network = "isolated";
};
programs.direnv.sandbox.enable = true;
```
