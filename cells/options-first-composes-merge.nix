# `options-first-composes-merge` — C91, den-hoag-7gp66 P2 L3. The same law as
# `options-first-composes`, at gen-merge. `evalUnder` is `evalModuleTree` with its `specialArgs`
# stated once, then mapped over three module lists: each reads the one `loom`, where the same door
# under `{ }` leaves the option at its default. `twilled` is `deriveType` with its description stated
# once and its `id` supplied, then applied to two bases. Each door's contract is read AS DATA
# (`__contract`), and three refusals are caught at the door's own application: an unknown option in
# the options position, the unmigrated one-record call (`modules` is no option of the door), and
# `mergeTypes` without its `partner`.
{
  asserts,
  genMerge,
}:
let
  t = genMerge.types;
  shuttle = {
    options.shuttle = genMerge.mkOption {
      type = t.str;
      default = "idle";
    };
  };
  threaded = pick: [
    shuttle
    ({ loom, ... }: { shuttle = pick loom; })
  ];
  evalUnder = genMerge.evalModuleTree { specialArgs.loom = "jacquard"; };

  twilled = genMerge.deriveType { description = "a twilled value"; } "twilled";

  refuses = e: !(builtins.tryEval (builtins.seq e null)).success;
in
{
  construct = [ "C91" ];
  check = asserts (
    map (ms: (evalUnder ms).config.shuttle) [
      (threaded (l: l))
      (threaded (l: "${l}-dobby"))
      [ shuttle ]
    ] == [
      "jacquard"
      "jacquard-dobby"
      "idle"
    ]
    # control: the same door under `{ }` leaves the option at its default
    && (genMerge.evalModuleTree { } [ shuttle ]).config.shuttle == "idle"
    &&
      map (b: (twilled b).description) [
        t.str
        t.int
      ] == [
        "a twilled value"
        "a twilled value"
      ]
    # control: under `{ }` the derivation keeps its base's phrase
    && (genMerge.deriveType { } "twilled" t.str).description != "a twilled value"
    &&
      genMerge.evalModuleTree.__contract.optional == [
        "specialArgs"
        "check"
        "prefix"
        "coreShortCircuit"
        "warmFrom"
        "editedModules"
      ]
    &&
      genMerge.mergeTypes.__contract.required == [
        "deciding"
        "partner"
      ]
    &&
      (genMerge.mergeTypes {
        deciding = t.str;
        partner = t.str;
      }).name == t.str.name
    && refuses (genMerge.evalModuleTree { specialArg = { }; })
    && refuses (genMerge.evalModuleTree { modules = [ shuttle ]; })
    && refuses (genMerge.mergeTypes { deciding = t.str; })
  );
}
