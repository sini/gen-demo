# `minted-value-carried-through-anything` — C121. A value a gen constructor minted (a schema kind, a
# refined type) rides a `__mint` carrier, and gen-merge's `anything` carries a value whole when every
# definition carries one, where it used to rebuild the attrset and land the kind's sealed closures in
# fresh cells. Before that, `kindEq` on a kind carried through `anything`, `attrsOf anything` or
# `listOf anything` was refused on Nix and Determinate (a rebuilt closure equals only itself there)
# and true on Lix, and `typeEq` on a refined type carried through `anything` was false on Nix and
# Determinate and an uncatchable overflow on Lix. The controls are `raw`, which never rebuilds.
{
  asserts,
  genMerge,
  inputs,
}:
let
  schema = inputs.gen.lib.substrate.schema;
  T = genMerge.types;
  kindOf =
    decl:
    (genMerge.evalModuleTree { } [
      { options.schema = schema.mkSchemaOption { }; }
      { config.schema.bobbin = decl; }
    ]).config.schema.bobbin;
  carried =
    t: v:
    (genMerge.evalModuleTree { } [
      { options.v = genMerge.mkOption { type = t; }; }
      { config.v = v; }
    ]).config.v;
  k = kindOf {
    options.spool = genMerge.mkOption {
      type = T.int;
      default = 80;
    };
  };
  pos = T.refined T.int {
    check = v: v > 0;
    message = "positive";
  };
in
{
  construct = [ "minted-value-is-carried-whole-through-anything" ];
  check = asserts (
    schema.kindEq k (carried T.anything k)
    && schema.kindEq k (carried (T.attrsOf T.anything) { x = k; }).x
    && schema.kindEq k (builtins.head (carried (T.listOf T.anything) [ k ]))
    && T.typeEq pos (carried T.anything pos)
    # controls: `raw` is never rebuilt
    && schema.kindEq k (carried T.raw k)
    && T.typeEq pos (carried T.raw pos)
  );
}
