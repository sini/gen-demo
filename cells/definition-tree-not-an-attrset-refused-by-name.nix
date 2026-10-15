# `definition-tree-not-an-attrset-refused-by-name` — den-hoag-410ri. A module whose `config` is a
# property over a value that is not an attrset (`mkIf true true`, nixpkgs modules.sh
# `test-push-down-non-attrs.nix`), and a declared option group defined as a plain value, are refused
# by name, catchable, as nixpkgs' `evalModules` refuses both. gen-merge used to abort uncatchably
# (`expected a set but found a Boolean`), which no `tryEval` here could contain. The twin defining
# the group's option through the same property reads as nixpkgs reads it, so a door refusing every
# property-wrapped `config` cannot pass.
{
  asserts,
  genMerge,
  lib,
}:
let
  loom = L: def: [
    { options.heddle.warp = L.mkOption { default = 1; }; }
    { config = def L; }
  ];
  attempt = r: builtins.tryEval (builtins.deepSeq r.config.heddle r.config.heddle);
  gen = def: attempt (genMerge.evalModuleTree { } (loom genMerge def));
  ref = def: attempt (lib.evalModules { modules = loom lib def; });
  refusedBoth = def: !(gen def).success && !(ref def).success;
  rootIf = L: L.mkIf true true;
  groupValue = _: { heddle = 5; };
  twin = L: L.mkIf true { heddle.warp = 2; };
in
{
  construct = [ "a-definition-where-a-tree-of-definitions-belongs-is-refused-by-name" ];
  check = asserts (
    refusedBoth rootIf
    && refusedBoth groupValue
    && (ref twin).value == { warp = 2; }
    && (gen twin).value == (ref twin).value
  );
}
