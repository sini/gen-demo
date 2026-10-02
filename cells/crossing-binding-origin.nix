# `crossing-binding-origin` — C132, den-hoag-bme8i, the 2026-09-30
# ruling (Q1a, Q1b = E2, C11), through the hub's ONE mint. A binding's VALUE is part of its crossing
# identity: two weavers, `linen` and `wool`, bind the import `bobbin` to one loom, and merged they
# are TWO crossings. Where two operands hold one crossing id, the pair is one binding iff it was
# declared at one site (the supplier's `origin` plus the binding attribute's source position): one
# declaration reached twice collapses; one written binding under two declared origins, and two
# different bodies written in one file under one origin, are refused by name at MERGE. Bindings a
# `mapAttrs` built carry no position, so two such bodies under one origin cannot show they are one
# declaration and refuse too. A binding without an origin is refused at registration. One factory
# site called with two bodies under one origin still collapses (den-hoag-yqz1j, with the owner).
{
  asserts,
  genBind,
  inputs,
}:
let
  mint = inputs.gen.lib.substrate.identity.hashIdentity;
  x = genBind.crossing;
  ops = (x.mkOperations { hashIdentity = mint; }).value;
  jacquard = mint "loom" [ "name" ] (_: "jacquard");

  fragment =
    (ops.declare {
      imports.bobbin = {
        merge = "one";
        contract = x.contractTerm.any;
        required = true;
        sealed = false;
        origin = "selvage";
        satisfiedBy = null;
      };
      exports = { };
    } null).value;
  link = r: (ops.link jacquard r fragment).value;
  thread =
    name:
    x.binding.wrapped {
      producer = "loom";
      body = _: name;
      mark = x.mark.open;
    };
  outcome =
    m: if x.isOk m then builtins.length (builtins.attrNames m.value.nodes) else m.refusal.code;

  linen =
    (ops.registerSupply {
      bindings.bobbin = thread "linen";
      proposals = { };
      origins.bobbin = "weavers/linen.nix";
      valueIdentities.bobbin = mint "thread" [ "name" ] (_: "linen");
    }).value;
  wool =
    (ops.registerSupply {
      bindings.bobbin = thread "wool";
      proposals = { };
      origins.bobbin = "weavers/wool.nix";
      valueIdentities.bobbin = mint "thread" [ "name" ] (_: "wool");
    }).value;
  linenAt =
    origin:
    ops.registerSupply {
      bindings.bobbin = thread "linen";
      proposals = { };
      origins.bobbin = origin;
      valueIdentities.bobbin = mint "thread" [ "name" ] (_: "linen");
    };
  # Two different linen bodies written in ONE file under one origin.
  linenWarp =
    (ops.registerSupply {
      bindings.bobbin = thread "linen-warp";
      proposals = { };
      origins.bobbin = "weavers.nix";
      valueIdentities.bobbin = mint "thread" [ "name" ] (_: "linen");
    }).value;
  linenWeft =
    (ops.registerSupply {
      bindings.bobbin = thread "linen-weft";
      proposals = { };
      origins.bobbin = "weavers.nix";
      valueIdentities.bobbin = mint "thread" [ "name" ] (_: "linen");
    }).value;
  # Two linen bodies whose `bindings` a `mapAttrs` built: no position, one origin.
  spun =
    name:
    (ops.registerSupply {
      bindings = builtins.mapAttrs (_: thread) { bobbin = name; };
      proposals = { };
      origins.bobbin = "weavers.nix";
      valueIdentities.bobbin = mint "thread" [ "name" ] (_: "linen");
    }).value;
in
{
  construct = [ "C132" ];
  check = asserts (
    outcome (ops.merge (link linen) (link wool)) == 2
    && outcome (ops.merge (link linen) (link linen)) == 1
    &&
      outcome (
        ops.merge (link (linenAt "weavers/linen.nix").value) (link (linenAt "weavers/linen-too.nix").value)
      ) == "crossing-origin-conflict"
    && outcome (ops.merge (link linenWarp) (link linenWeft)) == "crossing-origin-conflict"
    &&
      outcome (ops.merge (link (spun "linen-warp")) (link (spun "linen-weft")))
      == "crossing-origin-conflict"
    && x.isRefusal (linenAt null)
  );
}
