# `crossing-binding-key` — C104, den-hoag-bme8i (B1) clause 1, amended 2026-09-30 (Q1a). A
# crossing's BINDING relatum is the binding's KEY together with its VALUE's node identity, minted
# through the hub's ONE mint (`substrate.identity.hashIdentity`), never the key itself, and the
# binding node is minted at `registerSupply`, one pass before the `link` that relates it (ADR-0034's
# rider; ADR-0016 ruling 7), which reads it off the registration.
#
# Two looms bind the import `bobbin` under the one key `bobbin` to one value, `cotton`, with two
# different Wrapped bodies declared in `warp.nix` and `weft.nix`, and cross the same target. Both
# crossings carry the one binding relatum, because the sealed body enters no mint. A build that
# keeps the key as the relatum, or mints the binding at `link` rather than at registration, goes
# red here. What `merge` does with the two is C132's (`crossing-binding-origin`).
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

  registered =
    file: body:
    (ops.registerSupply {
      bindings.bobbin = x.binding.wrapped {
        producer = "loom";
        inherit body;
        mark = x.mark.open;
      };
      proposals = { };
      origins.bobbin = file;
      valueIdentities.bobbin = mint "thread" [ "name" ] (_: "cotton");
    }).value;
  nodeOf =
    registration:
    let
      linked = (ops.link jacquard registration fragment).value;
    in
    linked.nodes.${builtins.head linked.crossings};

  linen = registered "warp.nix" (_: "linen");
  # `link` reads the relatum off the registration: a different identity planted there is the
  # node's relatum, so a `link` that re-mints from the key goes red.
  planted = mint "binding" [ "key" ] (_: "sentinel");
  forged = linen // {
    bindingIdentities.bobbin = planted;
  };
  wool = registered "weft.nix" (_: "wool");
in
{
  construct = [ "C104" ];
  check = asserts (
    (nodeOf linen).binding == mint "binding" [ "key" "value" ] (
      l: if l == "key" then "bobbin" else mint "thread" [ "name" ] (_: "cotton")
    )
    && (nodeOf linen).binding == linen.bindingIdentities.bobbin
    && (nodeOf wool).binding == (nodeOf linen).binding
    && (nodeOf linen).name == "bobbin"
    && (nodeOf forged).binding == planted
    && planted != (nodeOf linen).binding
  );
}
