# Nilla module that adds a `checks` option.
#
# Structurally identical to nilla's built-in `packages` module — checks are
# just derivations built per-system, run by `nix flake check` or equivalent.
# See: https://github.com/nilla-nix/nilla/issues/31 (checks on the wishlist)
{ lib, config }:
let
  cfg = config.checks;

  builders = lib.attrs.mapToList
    (name: builder: builder // { inherit name; })
    config.builders;
in
{
  options.checks = lib.options.create {
    description = "The checks for this Nilla project.";
    default.value = { };
    type = lib.types.attrs.lazy (lib.types.submodules.portable {
      module = { config, name }:
        let
          check = {
            inherit name;
            inherit (config) systems builder settings;
            package = config.check;
          };

          matching = builtins.filter
            (builder: check.builder == builder.name)
            builders;

          first = builtins.head matching;

          builder =
            if builtins.length matching == 0 then
              null
            else if builtins.length matching > 1 then
              builtins.trace
                "[🍦 Nilla] ⚠️ Warning: Multiple builders found for check \"${name}\", using first available: \"${first.name}\""
                first
            else
              first;

          settings =
            if !(builtins.isNull builder) && builder.settings.type.check check.settings then
              check.settings
            else
              null;

          validity =
            if builtins.isNull builder then
              { message = "No builder found for check \"${name}\" with builder \"${check.builder}\"."; }
            else if builtins.isNull settings then
              { message = "Invalid settings for builder \"${builder.name}\"."; }
            else
              null;

          result =
            if builtins.isNull validity then
              builder.build check
            else
              { };
        in
        {
          options = {
            systems = lib.options.create {
              description = "The systems to run this check on.";
              type = lib.types.list.of lib.types.string;
            };

            builder = lib.options.create {
              description = "The builder to use for this check.";
              type = lib.types.string;
              default.value = "nixpkgs";
            };

            settings = lib.options.create {
              description = "Additional configuration for the builder.";
              type = builder.settings.type;
              default.value = builder.settings.default;
            };

            valid = lib.options.create {
              description = "Whether or not this check is valid.";
              type = lib.types.raw;
              internal = true;
              writable = false;
              default.value =
                if builtins.isNull validity then
                  { value = true; message = ""; }
                else
                  {
                    value = false;
                    message = validity.message or
                      "check \"${name}\" failed due to either invalid settings or an invalid builder.";
                  };
            };

            check = lib.options.create {
              description = "The check derivation function, called with nixpkgs packages per system.";
              type = lib.types.withCheck lib.types.raw (lib.types.function lib.types.derivation).check;
            };

            result = lib.options.create {
              description = "The built check derivation for each system.";
              type = lib.types.attrs.of lib.types.derivation;
              writable = false;
              default.value = result;
            };
          };
        };
    });
  };

  config = {
    assertions = lib.attrs.mapToList
      (name: check: {
        assertion = check.valid.value;
        message = check.valid.message;
      })
      cfg;
  };
}
