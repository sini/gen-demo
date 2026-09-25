# `crossing-import-relatum-identity` — C67 (number assigned at landing), den-hoag-bme8i. A
# crossing's IMPORT relatum is the import node's IDENTITY, never its identifier (ADR-0016 ruling
# 4), read through gen-bind's crossing operation set with the hub's ONE mint injected
# (`substrate.identity.hashIdentity`), never a stub.
#
# Two fragments each import the name `bobbin`, under two declarations that differ in their
# contract, and cross the same supply at the same target. They are two imports, so they mint two
# crossings, and no node's `import` is the name `bobbin`, which rides beside it as `name`. A build
# whose import relatum is the NAME mints one crossing for both and carries `import = "bobbin"`,
# and this cell goes red on it. The control: one declaration, declared twice by two declarers
# (only `origin` differs), mints ONE crossing, so the separating arm is not reading a digest that
# moves on everything.
#
# The target, `jacquard`, is the loom's minted identity by the CALLER's choice: gen-bind passes a
# `TargetId` through unchanged, so this cell asserts nothing about the target relatum.
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

  bobbinImport = contract: origin: {
    merge = "one";
    inherit contract origin;
    required = true;
    sealed = false;
    satisfiedBy = null;
  };
  bindings.bobbin = x.binding.plain {
    value = "linen";
    mark = x.mark.open;
  };
  supply = {
    inherit bindings;
    proposals = { };
    origins = { };
  };
  projection = (x.registerSupply supply).value.projection;
  crossed =
    decl:
    (ops.link jacquard projection supply
      (ops.declare {
        imports.bobbin = decl;
        exports = { };
      } null).value
    ).value;

  anyThread = crossed (bobbinImport x.contractTerm.any "selvage");
  stringThread = crossed (bobbinImport (x.contractTerm.prop "isString") "selvage");
  anyThreadElsewhere = crossed (bobbinImport x.contractTerm.any "warp");
  nodes = builtins.map (id: anyThread.nodes.${id}) anyThread.crossings;
in
{
  construct = [ "C67" ];
  check = asserts (
    anyThread.crossings != stringThread.crossings
    && anyThread.crossings == anyThreadElsewhere.crossings
    && builtins.all (n: n.import != "bobbin" && (n.name or null) == "bobbin") nodes
  );
}
