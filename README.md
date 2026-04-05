# direnv-sandbox has moved

This project has moved to **[github.com/DavHau/sbox](https://github.com/DavHau/sbox)**.

The direnv integration lives at [github.com/DavHau/sbox/tree/main/direnv-sandbox](https://github.com/DavHau/sbox/tree/main/direnv-sandbox).

Please update your flake inputs:

```nix
# Before
direnv-sandbox.url = "github:DavHau/direnv-sandbox";

# After
sbox.url = "github:DavHau/sbox";
```

And use the new module names:

```nix
# NixOS
sbox.nixosModules.direnv-sandbox

# Home Manager
sbox.homeManagerModules.direnv-sandbox
```
