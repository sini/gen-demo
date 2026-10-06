# `path-type-admits-a-string-path` — C157, den-hoag-fyx6m. nixpkgs' `types.path` is `pathWith {
# absolute = true; }`: a string naming an absolute path, an interpolated store path and a `__toString`
# set are paths to it, the shapes `"${inputs.x}/file"` and a coercible value take. A gen-merge option
# of type `path` defined as each is served and reads what the same definition reads under nixpkgs,
# where gen-types' `path` refused every one with `builtins.isPath`. A relative string is refused on
# both engines, which is the control.
{
  asserts,
  genMerge,
  lib,
}:
let
  defs = {
    absolute = "/etc/hosts";
    interpolated = "${builtins.toFile "warp" ""}";
    coercible = {
      __toString = _: "/etc/hosts";
    };
  };
  relative = "etc/hosts";
  read =
    eval: mkOption: type: v:
    builtins.tryEval "${(eval {
      modules = [
        { options.beam = mkOption { inherit type; }; }
        { beam = v; }
      ];
    }).config.beam
    }";
  native = read (
    r: genMerge.evalModuleTree (removeAttrs r [ "modules" ]) r.modules
  ) genMerge.mkOption genMerge.types.path;
  nixpkgs = read lib.evalModules lib.mkOption lib.types.path;
in
{
  construct = [ "path-option-admits-a-string-path-as-nixpkgs-does" ];
  check = asserts (
    builtins.all (n: (nixpkgs defs.${n}).success && native defs.${n} == nixpkgs defs.${n}) (
      builtins.attrNames defs
    )
    && !(nixpkgs relative).success
    && !(native relative).success
  );
}
