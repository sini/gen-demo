# `derivation-in-instance-freeform-carried-whole` — den-hoag-z9m0f. A gen-schema instance of a non-strict kind
# keeps its undeclared keys in a freeform `attrsOf anything`, and gen-merge's `anything` reads a set with
# `outPath` or `__toString` as nixpkgs' `stringCoercibleSet` does: a package defined once is served WHOLE (its
# functions too), defined twice it is refused, and a derivation whose `outPath` throws still reads its names.
# Before, the freeform rebuilt the package key by key: `pkgs.hello` with its `override` functions stopped
# equalling itself (Nix and Determinate), two definitions were served as a union with `all` doubled, and the
# throwing `outPath` threw at the key set on all three evaluators.
{
  asserts,
  genMerge,
  genSchema,
  pkgs,
}:
let
  schema = genSchema.evalSchema { schemaOption = genSchema.mkSchemaOption { strict = false; }; } [
    { config.schema.host.options.name = genMerge.mkOption { type = genMerge.types.str; }; }
  ];
  pkgOf =
    defs:
    (genMerge.evalModuleTree { } (
      [
        { options.hosts = genSchema.mkInstanceRegistry { } schema.host; }
        { config.hosts.h.name = "h"; }
      ]
      ++ map (d: { config.hosts.h.pkg = d; }) defs
    )).config.hosts.h.pkg;
  ok = e: (builtins.tryEval (builtins.seq e true)).success;
  once = pkgOf [ pkgs.hello ];
  booby = pkgs.hello // {
    outPath = throw "derivation-in-instance-freeform-carried-whole: outPath forced";
  };
in
{
  construct = [ "derivation-in-instance-freeform-carried-whole" ];
  check = asserts (
    removeAttrs once [ "type" ] == removeAttrs pkgs.hello [ "type" ]
    && once.drvPath == pkgs.hello.drvPath
    && !ok (pkgOf [
      pkgs.hello
      pkgs.hello
    ])
    && builtins.attrNames (pkgOf [ booby ]) == builtins.attrNames booby
    && !ok (pkgOf [ booby ]).outPath
  );
}
