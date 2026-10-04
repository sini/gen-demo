# `options-first-composes-program` — C91, den-hoag-7gp66 P2 L3. The same law as
# `options-first-composes`, at gen-program and gen-assemble. `unwound` is gen-program's
# `declaration` with its negative body stated once and its relata supplied, then mapped over three
# heads: each normalised declaration carries the body, where the same door under `{ }` carries none.
# `layered` is gen-assemble's `union` with one field's strategy stated once, then applied to the
# contributions: the two layers' bobbins append, where `union { }` keeps the last. Each door's
# contract is read AS DATA (`__contract`), and two refusals that once aborted uncatchably are caught:
# an unknown option in the options position, and `model` without its required `prior`.
{
  asserts,
  genProgram,
  genAssemble,
}:
let
  unwound = genProgram.declaration { neg = [ "unwound:selvage" ]; } [ "selvage" ];
  heads = [
    "taut:selvage"
    "slack:selvage"
    "frayed:selvage"
  ];

  layers = [
    {
      name = "warp";
      vertices = [ "selvage" ];
      decls.selvage.bobbins = [ "damask" ];
    }
    {
      name = "weft";
      vertices = [ "selvage" ];
      decls.selvage.bobbins = [ "faille" ];
    }
  ];
  layered = genAssemble.union { strategies.bobbins = "append"; };

  refuses = e: !(builtins.tryEval (builtins.seq e null)).success;
in
{
  construct = [ "C91" ];
  check = asserts (
    map (h: (unwound h).neg) heads == [
      [ "unwound:selvage" ]
      [ "unwound:selvage" ]
      [ "unwound:selvage" ]
    ]
    # control: the same door under `{ }` carries no body
    && (genProgram.declaration { } [ "selvage" ] "taut:selvage").neg == [ ]
    &&
      (layered layers).decls.selvage.bobbins == [
        "damask"
        "faille"
      ]
    # control: `union { }` keeps the last layer's list
    && (genAssemble.union { } layers).decls.selvage.bobbins == [ "faille" ]
    &&
      genProgram.declaration.__contract.optional == [
        "pos"
        "neg"
        "label"
        "promote"
        "when"
      ]
    &&
      genProgram.model.__contract.required == [
        "program"
        "interpretation"
        "complete"
        "prior"
      ]
    && genAssemble.union.__contract.optional == [ "strategies" ]
    && refuses (genAssemble.union { bobbins = "append"; })
    && refuses (genProgram.declaration { relata = [ "selvage" ]; })
    && refuses (
      genProgram.model {
        program = genProgram.program [ ] [ ];
        interpretation = [ ];
        complete = true;
      }
    )
  );
}
