# `kind-mark-regime-tags` — C64, den-hoag-markof-partial-preimage-znfjq ((c+), ADR-0034). A kind's
# mark is minted over each field's REGIME TAG: a minted field type's digest, anything else the
# sealed marker. Two `selvage` kinds differing only in a refinement PREDICATE (a caller lambda,
# sealed) mint one mark, and `kindEq` refuses the pair BY NAME rather than calling them one kind;
# two differing only in a MINTED field type (`int` against `str`) mint apart and `kindEq` decides
# them, as do two differing only in a default. A predicate built from a REGISTERED constructor (`between`, over the hub's mint) is a term,
# not a lambda: its field mints, so two `selvage` kinds differing only in its bounds mint apart and
# `kindEq` decides them with no refusal. Before (c+) every pair minted one mark and nothing
# refused. The refusal's wording is `refusals` row 82.
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
    (genMerge.evalModuleTree {
      modules = [
        { options.schema = schema.mkSchemaOption { }; }
        { config.schema.selvage = decl; }
      ];
    }).config.schema.selvage;
  field = type: genMerge.mkOption { inherit type; };
  field' =
    default:
    genMerge.mkOption {
      type = T.int;
      inherit default;
    };
  ends = selvage { options.ends = field (schema.refined T.int schema.refinements.tcpPort); };
  endsPositive = selvage { options.ends = field (schema.refined T.int schema.refinements.positive); };
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
in
{
  construct = [ "C64" ];
  check = asserts (
    # the sealed arm: one mark, and the comparison refuses rather than merging
    ends.__mint.minted == endsPositive.__mint.minted
    && !(decides (schema.kindEq ends endsPositive))
    # the minted arm: the field's digest separates the marks, and the comparison decides
    && endsInt.__mint.minted != endsStr.__mint.minted
    && !(schema.kindEq endsInt endsStr)
    # the registered arm: a term mints, so the pair separates and is decided, never refused
    && endsWide.__mint.minted != endsLow.__mint.minted
    && decides (schema.kindEq endsWide endsLow)
    && !(schema.kindEq endsWide endsLow)
    # inert content enters too: a default of 80 against 443 separates and is decided
    && !(schema.kindEq (selvage { options.ends = field' 80; }) (selvage {
      options.ends = field' 443;
    }))
    # controls: a kind is one kind with itself, and a minted twin across evaluations is one kind
    && schema.kindEq ends ends
    && schema.kindEq endsInt (selvage {
      options.ends = field T.int;
    })
  );
}
