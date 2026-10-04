# `aspect-declared-surface` — C86, den-hoag-shdvu (ruled arm A: delegate). An aspect's option type
# answers the nixpkgs sub-option protocol with the options an aspect actually carries, where it used
# to answer `{ }` exactly as a leaf does. Read two ways. The aspect container over the corpus's own
# cnf (`aspect-cnf.nix`) declares the corpus cnf's `nixos`/`welt`/`gusset` beside the base keys, and
# every key it declares is a key the composed `stitch` carries. And one aspect-level
# `schema.aspect` declaration moves BOTH planes together: `priority` appears in the value
# (`aspects.svc.priority = 50`) and in the declared option set, and is absent from both without it.
# Before, the value plane moved and the declaration plane read `[ ]` in both arms, which is what
# made the two arms look like a class boundary (den-hoag-aspects-suboptions-invisible-getsuboptions-915wt).
# `_freeformOptions` is set aside BY NAME: nixpkgs' `getSubOptions` on a freeform submodule carries it
# as a pseudo-key, not a declared option, and gen-merge publishes nixpkgs' answer
# (den-hoag-foreign-mount-parity-knhyg). Only that name: a declared `_x` option is still compared.
{
  asserts,
  config,
  genAspects,
  genMerge,
}:
let
  declared = t: builtins.attrNames (t.getSubOptions [ "aspects" ]);
  cnf = import ../aspect-cnf.nix;
  corpusDeclared = builtins.filter (k: k != "_freeformOptions") (
    declared (genAspects.aspectsRoot cnf)
  );

  schema = genAspects.mkAspectSchema cnf;
  tree =
    extra:
    genMerge.evalModuleTree { } (
      [
        { options.schema = schema.schemaOption; }
        (schema.mkAspectModule { })
        { config.aspects.svc = { }; }
      ]
      ++ extra
    );
  plain = tree [ ];
  withPriority = tree [
    {
      config.schema.aspect.options.priority = genMerge.mkOption {
        type = genMerge.types.int;
        default = 50;
      };
    }
  ];
in
{
  construct = [ "C86" ];
  check = asserts (
    builtins.all (k: builtins.elem k corpusDeclared) [
      "includes"
      "nixos"
      "welt"
      "gusset"
    ]
    && builtins.all (
      k: builtins.elem k (builtins.attrNames config.gen.composed.aspects.stitch)
    ) corpusDeclared
    && withPriority.config.aspects.svc.priority == 50
    && builtins.elem "priority" (declared withPriority.options.aspects.type)
    && !(plain.config.aspects.svc ? priority)
    && !(builtins.elem "priority" (declared plain.options.aspects.type))
  );
}
