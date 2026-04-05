{
  description = "This project has moved to github.com/DavHau/sbox";

  inputs = { };

  outputs = _:
    throw ''
      direnv-sandbox has moved to github.com/DavHau/sbox

      Update your flake input:
        sbox.url = "github:DavHau/sbox";

      And use the new module names:
        sbox.nixosModules.direnv-sandbox
        sbox.homeManagerModules.direnv-sandbox
    '';
}
