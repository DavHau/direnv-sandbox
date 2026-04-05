{
  description = "This project has moved to github.com/DavHau/sbox";

  inputs = { };

  outputs = _:
    throw ''
      direnv-sandbox has moved to github.com/DavHau/sbox

      Update your flake input:
        sbox.url = "github:DavHau/sbox";

      Use the new module names:
        sbox.nixosModules.direnv-sandbox
        sbox.homeManagerModules.direnv-sandbox

      Move sandbox config from programs.direnv.sandbox to programs.sbox:
        programs.sbox = { bind."$HOME/.cache" = {}; ... };
        programs.direnv.sandbox.enable = true;
    '';
}
