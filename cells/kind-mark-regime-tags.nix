# `kind-mark-regime-tags` — C64, den-hoag-markof-partial-preimage-znfjq ((c+), ADR-0034). A kind's
# mark is minted over each field's REGIME TAG: a minted field type's digest, anything else the
# sealed marker. Two `selvage` kinds differing only in a refinement PREDICATE (a caller lambda,
# sealed; the message, inert content, held equal) mint one mark, and `kindEq` refuses the pair BY NAME rather than calling them one kind;
# two differing only in a MINTED field type (`int` against `str`) mint apart and `kindEq` decides
# them. Two differing only in a default are refused BY NAME at the default's `open.*` path (an
# option's other attributes enter the mark by path as sealed components, never forced:
# den-hoag-egei0), as are two separate constructions of one such declaration, while one
# such kind value is one kind with itself; two whose default, written in a
# function module pulled in through `require`, reads an instance's `name` are refused BY NAME at
# `modules`. A predicate built from a REGISTERED constructor (`between`) is a term, not a lambda: it is
# COMPARED by its declared subject and never minted, so two `selvage` kinds differing only in its
# bounds share a mark and `kindEq` decides them `false` with no refusal (den-hoag-6orb8 U1). Before (c+) every pair minted one mark and nothing
# refused. The refusal's wording is `refusals` row 82. A field typed by two constructions of one
# check-only `mkOptionType` whose `description` carries a back-edge is refused by name (den-hoag-6b5ia:
# the sealed type is compared closures-first; before, `==` walked the cyclic records until the
# evaluator overflowed), and one construction shared by both kinds is one kind.
{
  asserts,
  genAlgebra,
  genMerge,
  inputs,
}:
let
  schema = inputs.gen.lib.substrate.schema;
  T = genMerge.types;
  selvage =
    decl:
    (genMerge.evalModuleTree { } [
      { options.schema = schema.mkSchemaOption { }; }
      { config.schema.selvage = decl; }
    ]).config.schema.selvage;
  field = type: genMerge.mkOption { inherit type; };
  field' =
    default:
    genMerge.mkOption {
      type = T.int;
      inherit default;
    };
  # a predicate-only pair: two caller lambdas under ONE message (a message is inert content, in the mark)
  inRange = check: {
    inherit check;
    message = "must be in range";
  };
  ends = selvage { options.ends = field (schema.refined T.int (inRange (v: v > 0 && v < 65536))); };
  endsPositive = selvage { options.ends = field (schema.refined T.int (inRange (v: v > 0))); };
  # two stock refinements carry different messages, so they mint apart and are decided
  endsTcp = selvage { options.ends = field (schema.refined T.int schema.refinements.tcpPort); };
  endsPos = selvage { options.ends = field (schema.refined T.int schema.refinements.positive); };
  endsInt = selvage { options.ends = field T.int; };
  endsStr = selvage { options.ends = field T.str; };
  decides = e: (builtins.tryEval e).success;
  its = genAlgebra.mkIntensional inputs.gen.lib.substrate.identity.hashIdentity {
    revision = "r1";
    members.between = a: v: v >= a.lo && v <= a.hi;
  };
  between = lo: hi: {
    check = its "between" { inherit lo hi; };
    message = "must be between ${toString lo} and ${toString hi}";
  };
  endsWide = selvage { options.ends = field (schema.refined T.int (between 1 65535)); };
  endsLow = selvage { options.ends = field (schema.refined T.int (between 1 1023)); };
  # the same two terms under ONE message: only the registered construction differs
  rangeWide = selvage {
    options.ends = field (
      schema.refined T.int (
        inRange (
          its "between" {
            lo = 1;
            hi = 65535;
          }
        )
      )
    );
  };
  rangeLow = selvage {
    options.ends = field (
      schema.refined T.int (
        inRange (
          its "between" {
            lo = 1;
            hi = 1023;
          }
        )
      )
    );
  };
  # a default reading an instance's `name`, in a function module pulled in through `require`
  warp =
    word:
    selvage {
      require = [
        (
          { config, ... }:
          {
            options.ends = genMerge.mkOption {
              type = T.str;
              default = "${word}-${config.name}";
            };
          }
        )
      ];
    };
  # one construction of a check-only `mkOptionType` per call, its back-edge under `description`
  tension =
    _:
    let
      back = {
        self = back;
      };
    in
    T.mkOptionType {
      name = "tension";
      description = back;
      check = v: builtins.isInt v && v < 10;
    };
  tensionShared = tension null;
in
{
  construct = [ "kind-mark-over-per-field-regime-tags" ];
  check = asserts (
    # the sealed arm: one mark, and the comparison refuses rather than merging
    ends.__mint.minted == endsPositive.__mint.minted
    && !(decides (schema.kindEq ends endsPositive))
    # the minted arm: the field's digest separates the marks, and the comparison decides
    && endsInt.__mint.minted != endsStr.__mint.minted
    && !(schema.kindEq endsInt endsStr)
    && endsTcp.__mint.minted != endsPos.__mint.minted
    && !(schema.kindEq endsTcp endsPos)
    # the registered arm: a term is COMPARED, never minted (den-hoag-6orb8 U1) — a pair differing only
    # in the term shares a mark and is decided `false` by its declared subject, never refused; a pair
    # whose messages differ separates by mark
    && rangeWide.__mint.minted == rangeLow.__mint.minted
    && decides (schema.kindEq rangeWide rangeLow)
    && !(schema.kindEq rangeWide rangeLow)
    && endsWide.__mint.minted != endsLow.__mint.minted
    && !(schema.kindEq endsWide endsLow)
    # a default is open content, sealed at its path: 80 against 443 is refused, never one kind
    && !(decides (
      schema.kindEq (selvage { options.ends = field' 80; }) (selvage {
        options.ends = field' 443;
      })
    ))
    # two separate constructions of that one declaration are refused too: the default's subject
    # is equal only to itself, and the only remedy is a sealed-literal constructor that puts an
    # inert literal into the mark
    && !(decides (
      schema.kindEq (selvage { options.ends = field' 80; }) (selvage {
        options.ends = field' 80;
      })
    ))
    # and one such kind value is one kind with itself
    && (
      let
        k = selvage { options.ends = field' 80; };
      in
      schema.kindEq k k
    )
    # a function module under `require` is the sealed `modules` component: refused, never one kind
    && !(decides (schema.kindEq (warp "x") (warp "y")))
    # controls: a kind is one kind with itself, and a minted twin across evaluations is one kind
    && schema.kindEq ends ends
    && schema.kindEq endsInt (selvage {
      options.ends = field T.int;
    })
    # a field typed by two constructions of one check-only type is refused by name, and one
    # construction shared by both kinds is one kind
    && !(decides (
      schema.kindEq (selvage { options.ends = field (tension 1); }) (selvage {
        options.ends = field (tension 2);
      })
    ))
    && schema.kindEq (selvage { options.ends = field tensionShared; }) (selvage {
      options.ends = field tensionShared;
    })
  );
}
