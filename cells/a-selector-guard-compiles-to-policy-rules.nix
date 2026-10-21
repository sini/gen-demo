# `a-selector-guard-compiles-to-policy-rules` — den-hoag-mr6xf. C5's piping guard is a selector:
# `and [ nap:pewter (not scotched:pewter) ]` compiles to C5's own `pos`/`neg`, the atoms named by
# the caller's `atomOf`. A disjunctive guard needs one declaration per disjunct, which gen-program
# asks for and does not write; the adapter writes them, and the solved head is `included` exactly
# where `matches` decides the selector true, at each of the four leaf valuations.
#
# Red before gen-select published `adapters.program`: `attribute 'program' missing`.
{
  asserts,
  genSelect,
  genProgram,
  pipingDeclarations,
  pipingHead,
}:
let
  sel = genSelect;
  atomOf = s: builtins.head (builtins.attrNames s.a);
  leaf = a: sel.attrs { ${a} = true; };
  nap = leaf "nap:pewter";
  scotched = leaf "scotched:pewter";
  piping = builtins.head (builtins.filter (d: d.head == pipingHead) pipingDeclarations);
  # `(nap ∧ scotched) ∨ ¬nap`, and its negation `(¬nap ∨ ¬scotched) ∧ nap`.
  guard = sel.anyOf [
    (sel.and [
      nap
      scotched
    ])
    (sel.not nap)
  ];
  guards = [
    guard
    (sel.not guard)
  ];
  head = "trim:grosgrain:faille";
  declsOf =
    g:
    map (
      b:
      b
      // {
        inherit head;
        relata = [
          "grosgrain"
          "faille"
        ];
      }
    ) (sel.adapters.program.bodies atomOf g);
  # Each valuation of the two leaves is asserted to the program and read by `matches` off one node.
  valuations = [
    {
      "nap:pewter" = true;
      "scotched:pewter" = true;
    }
    {
      "nap:pewter" = true;
      "scotched:pewter" = false;
    }
    {
      "nap:pewter" = false;
      "scotched:pewter" = true;
    }
    {
      "nap:pewter" = false;
      "scotched:pewter" = false;
    }
  ];
  ctxOf = v: {
    data = _: v;
    parent = _: null;
    children = _: [ ];
    ancestors = _: [ ];
    siblings = _: [ ];
  };
  agrees =
    g: v:
    let
      r =
        (genProgram.model {
          prior = null;
          program = genProgram.program [
            "pewter"
            "damask"
            "grosgrain"
            "faille"
          ] (declsOf g);
          interpretation = map (atom: {
            inherit atom;
            verdict = if v.${atom} then "true" else "false";
          }) (builtins.attrNames v);
          complete = true;
        }).resolve
          head;
    in
    r.flag == "T" && r.included == sel.matches g "pewter" (ctxOf v);
in
{
  construct = [ "a-selector-guard-compiles-to-policy-rules" ];
  check = asserts (
    sel.adapters.program.bodies atomOf (
      sel.and [
        nap
        (sel.not scotched)
      ]
    ) == [ { inherit (piping) pos neg; } ]
    &&
      map (g: builtins.length (declsOf g)) guards == [
        2
        2
      ]
    && builtins.all (g: builtins.all (agrees g) valuations) guards
    # both answers occur, so `included` is compared in both directions
    &&
      map (g: map (v: sel.matches g "pewter" (ctxOf v)) valuations) guards == [
        [
          true
          false
          true
          true
        ]
        [
          false
          true
          false
          false
        ]
      ]
  );
}
