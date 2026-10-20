# `a-nixpkgs-declaration-reading-config-is-served` — den-hoag-2tna3. A declaration in nixpkgs' grammar
# whose default is chosen by reading `config` while the declarations are folded (grav's
# `mkPackageOption`, kubernetes' `mkKubeConfigOptions`) is served as nixpkgs' `evalModules` serves it,
# in a module not declared gen grammar. The same declaration with a gen type keeps ADR-0033's stratum
# refusal: refused, catchably (its text is the refusals row of the same name). A declaration reading
# nothing is the control, so a door serving every declaration and one refusing every read both fail.
{
  asserts,
  genMerge,
  lib,
}:
let
  attempt = r: builtins.tryEval (builtins.deepSeq r.config.bobbin r.config.bobbin);
  gen = mods: attempt (genMerge.evalModuleTree { specialArgs = { inherit lib; }; } mods);
  ref = mods: attempt (lib.evalModules { modules = mods; });
  loom = mk: ty: [
    {
      options.selvage = lib.mkOption {
        type = lib.types.str;
        default = "tabby";
      };
    }
    (
      { config, ... }:
      {
        options.bobbin =
          mk { type = ty; } // lib.optionalAttrs (config.selvage == "tabby") { default = "twill"; };
      }
    )
  ];
  plain = [
    {
      options.bobbin = lib.mkOption {
        type = lib.types.str;
        default = "twill";
      };
    }
  ];
in
{
  construct = [ "a-nixpkgs-declaration-reading-config-is-served-as-nixpkgs-does" ];
  check = asserts (
    (ref (loom lib.mkOption lib.types.str)).value == "twill"
    && gen (loom lib.mkOption lib.types.str) == ref (loom lib.mkOption lib.types.str)
    && !(gen (loom genMerge.mkOption genMerge.types.str)).success
    && gen plain == ref plain
  );
}
