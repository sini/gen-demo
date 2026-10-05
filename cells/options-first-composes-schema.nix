# `options-first-composes-schema` — C91, den-hoag-7gp66 P2 L4. The same law as
# `options-first-composes`, at gen-schema and gen-class. `described` is gen-schema's
# `mkInstanceRegistry` with its description stated once, then mapped over two kinds: each registry
# carries it, where the same door under `{ }` names the kind. `kinds` is `evalSchema { }` applied
# to its module list, the subject, last. `pinned` is gen-class's `mkClass` with its archetype stated
# once and its key supplied, then mapped over two member lists: each class takes `pewter`, where the
# same door under `{ }` takes the byte-order first member. Each door's contract is read AS DATA
# (`__contract`), and three refusals are caught at the options application: an unknown option, and
# the unmigrated one-record calls of `evalSchema` and `mkClass` (`modules`, `key` are no options).
{
  asserts,
  genSchema,
  genClass,
  genMerge,
}:
let
  spool = genMerge.mkOption {
    type = genMerge.types.str;
    default = "linen";
  };
  kinds = genSchema.evalSchema { } [
    {
      config.schema.bobbin.options.spool = spool;
      config.schema.thimble.options.spool = spool;
    }
  ];
  described = genSchema.mkInstanceRegistry { description = "the loom's spools"; };

  pinned = genClass.mkClass { archetype = "pewter"; } "plain";
  memberLists = [
    [
      "damask"
      "pewter"
    ]
    [
      "pewter"
      "faille"
    ]
  ];

  refuses = e: !(builtins.tryEval (builtins.seq e null)).success;
in
{
  construct = [ "C91" ];
  check = asserts (
    map (k: (described k).description) [
      kinds.bobbin
      kinds.thimble
    ] == [
      "the loom's spools"
      "the loom's spools"
    ]
    # control: the same door under `{ }` names the kind
    && (genSchema.mkInstanceRegistry { } kinds.bobbin).description == "bobbin instances"
    &&
      map (ms: (pinned ms).archetype) memberLists == [
        "pewter"
        "pewter"
      ]
    # control: `mkClass { }` takes the byte-order first member
    && (genClass.mkClass { } "plain" (builtins.head memberLists)).archetype == "damask"
    &&
      genSchema.evalSchema.__contract.optional == [
        "schemaOption"
        "specialArgs"
      ]
    && genClass.applyCoreFixed.__contract.optional == [ "engineArgs" ]
    && refuses (genSchema.mkInstanceRegistry { bobbin = 1; })
    && refuses (genSchema.evalSchema { modules = [ ]; })
    && refuses (
      genClass.mkClass {
        key = "plain";
        members = [ "pewter" ];
      }
    )
    # control: the same predicate admits a well-formed options application
    && !refuses (genSchema.evalSchema { })
  );
}
