# `standalone-entry-agrees-with-the-flake-entry` — den-hoag-idhzc. The hub's standalone entry,
# `import gen { }`, is what with-inputs and npins users take, and it builds its roster from the hub's
# own `flake.lock`, one value per lock node, not through the flake output. This cell builds the roster
# that way from the corpus's own `inputs.gen` and asks it the identity mint's question that
# `mint-context-stance` asks through `inputs.gen.lib`; the two entries must agree, and so must their
# roster keys. It exercises the standalone path on every evaluator the corpus runs. It does not
# discriminate one construction of that path from another by value (both answer alike); the hub's own
# ci counts the construction.
{ asserts, inputs }:
let
  standalone = import inputs.gen.outPath { };
  flake = inputs.gen.lib;
  answer = mint: [
    (mint "spindle" [ "name" ] (_: "flax"))
    (mint "spindle" [ "name" ] (_: "linen"))
  ];
in
{
  construct = [ "standalone-entry-agrees-with-the-flake-entry" ];
  check = asserts (
    builtins.attrNames standalone == builtins.attrNames (flake.mkGenLibs { })
    && answer standalone.identity.hashIdentity == answer flake.substrate.identity.hashIdentity
  );
}
