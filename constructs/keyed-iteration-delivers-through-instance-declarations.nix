# ── A KEYED ITERATION DELIVERS THROUGH `instanceDeclarations`; A DELIVERING LIST ITERATION IS REFUSED ──
# A `reel` policy iterates `bolts` with `forEach` and emits one `deliver` per bolt, its payload the
# bolt's thread. Its firings go through gen-program's `instanceDeclarations`, which names each firing's
# fact and abnormality with the caller's namers and writes the declarations the well-founded engine
# solves. `bolts` is keyed, so an item is identified by its key and `over`'s source, never by its
# value or position: adding `linen` leaves `wool`'s firing where it was, and two bolts of one thread
# are two firings of one fact. The same body over a LIST of bolts is refused by name
# (`policy-body/iterated-delivery-unkeyed`): a list position is provenance only, so a delivery cannot
# take its identity from it.
{
  genProgram,
  genAlgebra,
  inputs,
}:
let
  T = genAlgebra.term inputs.gen.lib.substrate.identity.hashIdentity;
  inherit (T.term) has readCtx;
  kidiReel = genProgram.body {
    name = "reel";
    declared = [ "bolts" ];
    clauses = [
      (genProgram.forEach {
        over = readCtx "bolts" [ ];
        emit = [
          {
            ctor = "deliver";
            when = has "bolts";
            payload.thread = readCtx "item" [ ];
          }
        ];
      })
    ];
  };
  kidiNamers = {
    fact = v: {
      head = "${v.ctor}:${v.policy}@${v.at}";
      relata = [ ];
    };
    abnormal =
      { policy, at }:
      {
        head = "ab:${policy}@${at}";
        relata = [ ];
      };
  };
  kidiFire =
    bolts:
    genProgram.instanceDeclarations kidiNamers [
      {
        body = kidiReel;
        context = { inherit bolts; };
        sources.bolts = "bolts:cutting-table";
        at = "bolt:cutting-table";
        when = has "bolt:cutting-table";
      }
    ];
  kidiIdOf =
    r: thread:
    builtins.filter (id: r.firings.${id}.payload.thread == thread) (builtins.attrNames r.firings);
  kidiTwo = kidiFire {
    a = "silk";
    c = "wool";
  };
  kidiThree = kidiFire {
    a = "silk";
    b = "linen";
    c = "wool";
  };
  kidiSame = kidiFire {
    a = "silk";
    b = "silk";
  };
  kidiModel = genProgram.model {
    program = genProgram.program [ ] (
      [
        {
          head = "bolt:cutting-table";
          relata = [ ];
        }
      ]
      ++ kidiThree.declarations
    );
    interpretation = [ ];
    prior = null;
    complete = true;
  };
in
{
  kidiRead = {
    firings = builtins.length (builtins.attrNames kidiThree.firings);
    woolKeptUnderInsertion = kidiIdOf kidiTwo "wool" == kidiIdOf kidiThree "wool";
    equalThreadsFirings = builtins.length (builtins.attrNames kidiSame.firings);
    equalThreadsHeads = builtins.length (
      builtins.attrNames (
        builtins.listToAttrs (
          map (d: {
            name = d.head;
            value = null;
          }) kidiSame.declarations
        )
      )
    );
    delivered = (kidiModel.resolve "deliver:reel@bolt:cutting-table").included;
    listRefused =
      (kidiFire [
        "silk"
        "wool"
      ]).code or null;
  };
}
