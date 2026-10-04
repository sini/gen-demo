# `redeclared-many-modules` — C186, den-hoag-f010k. One option `weave` is declared, typed, in eight
# modules with distinct files: it reads its value, and its shadow provenance `overridden` names
# `decl-0` … `decl-6` in authored order. An option `weft` whose declared type is a `_module.args`
# argument, declared in three modules, is admitted, as the same declaration made once always was:
# gen-merge's declaration guard decides each declaring module's key set and never merges the
# redeclared descriptor, so which declarations are admitted does not depend on how many modules make
# them. It used to refuse the redeclared shape with the stratification text.
{
  asserts,
  genMerge,
}:
let
  mk = genMerge.mkOption;
  T = genMerge.types;
  n = 8;
  many = genMerge.evalModuleTree { } (
    builtins.genList (i: {
      _file = "decl-${toString i}";
      options.weave = mk {
        type = T.str;
        description = "declaration ${toString i}";
      };
    }) n
    ++ [ { config.weave = "twill"; } ]
  );
  argTyped =
    builtins.tryEval
      (genMerge.evalModuleTree { } (
        builtins.genList (_: { ty, ... }: { options.weft = mk { type = ty; }; }) 3
        ++ [
          {
            config._module.args.ty = T.str;
            config.weft = "linen";
          }
        ]
      )).config.weft;
in
{
  construct = [ "C186" ];
  check = asserts (
    many.config.weave == "twill"
    &&
      map (o: o.file) many.options.weave.overridden == builtins.genList (i: "decl-${toString i}") (n - 1)
    &&
      argTyped == {
        success = true;
        value = "linen";
      }
  );
}
