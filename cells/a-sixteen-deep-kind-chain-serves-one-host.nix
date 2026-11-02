# `a-sixteen-deep-kind-chain-serves-one-host` — den-hoag-f1iza. A 16-deep chain of plain kinds (`ply2` inherits
# `ply1`, … `ply16` inherits `ply15`, two `str` options each) and one host of the deepest kind: the host serves
# all 32 options their values in gen's engine, its identity reads, and `ancestorsForKind ply16` is the chain in
# order, nearest first (`ply15` … `ply1`). Each kind is evaluated over its own declarations and composed with its
# parent's published plane (the layered introspection), so the chain costs linear in its depth; the slope bound
# is gen-schema's `tests-process` depth cell (ratio s(32->64) / s(16->32) at most 1.30), not this cell.
{
  asserts,
  genMerge,
  genSchema,
  lib,
}:
let
  n = 16;
  plies = map (i: "ply${toString i}") (lib.range 1 n);
  optsOf =
    p: lib.genAttrs [ "${p}weft" "${p}warp" ] (_: genMerge.mkOption { type = genMerge.types.str; });
  schema =
    (genMerge.evalModuleTree { } [
      { options.schema = genSchema.mkSchemaOption { }; }
      (
        { config, ... }:
        {
          config.schema = lib.genAttrs plies (
            p:
            let
              i = lib.toInt (lib.removePrefix "ply" p);
            in
            {
              options = optsOf p;
            }
            // lib.optionalAttrs (i > 1) { inherits = [ config.schema."ply${toString (i - 1)}" ]; }
          );
        }
      )
    ]).config.schema;
  names = lib.concatMap (p: builtins.attrNames (optsOf p)) plies;
  host =
    (genMerge.evalModuleTree { } [
      { options.bolt = genMerge.mkOption { type = genSchema.mkInstanceType { } schema.ply16; }; }
      { config.bolt = lib.genAttrs names (o: "${o}-v"); }
    ]).config.bolt;
in
{
  construct = [ "a-sixteen-deep-kind-chain-serves-one-host" ];
  check = asserts (
    map (o: host.${o}) names == map (o: "${o}-v") names
    && builtins.isString host.id_hash
    && map (a: a.kind) (genSchema.ancestorsForKind schema.ply16) == lib.reverseList (lib.init plies)
  );
}
