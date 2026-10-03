# ── C176 — den v1's `includeIf`, expressed on gen-program's literal `when` tier (den-hoag-fuci G1;
# ADR-0010 §4(b), ADR-0008, ADR-0020) ──
#
# den v1 hands a guard one context, `mkGuardCtx`, whose every field is `hasAspect` (entity stubs
# included), defined as "present in this scope and not excluded". So a v1 guard is a Boolean function
# of membership atoms, and its disjunctive normal form is a set of conjunctions of literals: one
# declaration per disjunct, each body a `when` term in the literal tier. The five forms below are that
# reading written as data, and nothing in them is a closure:
#   · `includes a b`         b ← a                          (a's `includes` lists b)
#   · `includeIf a g b`      b ← a ∧ g                      (a's `includes` lists `includeIf g [ b ]`)
#   · `held k`               k-held ← k ∧ ¬unpicked-k       (v1's `hasAspect k`, exclude-aware)
#   · `excludes e k`         unpicked-k ← e                 (e's excludes list k)
#   · `inherits p k`         k@child ← k@parent             (a scope sees its ancestors, never a sibling)
# A guard reads `has "k-held:<scope>"` for `hasAspect k`, `not` of it for `!hasAspect k`, `all` for
# `&&`; `||` is one declaration per disjunct over the one head; `_: true` is `always`; `_: false` is no
# declaration at all. Every pass is one program over a fixed Herbrand base, so the well-founded model
# decides it in one solve, in any order of writing: v1's deferred re-evaluation is not reproduced, its
# answer is.
{
  genProgram,
  genAlgebra,
  inputs,
}:
let
  T = genAlgebra.term inputs.gen.lib.substrate.identity.hashIdentity;
  inherit (T.term)
    all
    always
    has
    not
    ;
  at = s: k: "${k}:${s}";
  decl = s: head: when: {
    head = at s head;
    relata = [ s ];
    inherit when;
  };
  root = s: k: decl s k always;
  includes =
    s: a: b:
    decl s b (has (at s a));
  includeIf =
    s: a: guard: b:
    decl s b (all [
      (has (at s a))
      guard
    ]);
  hasAspect = s: k: has (at s "${k}-held");
  held =
    s: k:
    decl s "${k}-held" (all [
      (has (at s k))
      (not (has (at s "unpicked-${k}")))
    ]);
  excludes =
    s: e: k:
    decl s "unpicked-${k}" (has (at s e));
  inherits =
    parent: child: k:
    decl child k (has (at parent k));

  heldAll =
    s:
    map (held s) [
      "gusset"
      "godet"
      "facing"
      "lining"
    ];

  # `bolt`: the v1 test shapes, one scope.
  bolt = [
    (root "bolt" "selvage")
    (includes "bolt" "selvage" "gusset")
    # test-fallback-pattern: `[ sops (includeIf (hasAspect sops) [ sopsConf ]) (includeIf (!hasAspect sops) [ ageConf ]) ]`
    (includeIf "bolt" "selvage" (hasAspect "bolt" "gusset") "facing")
    (includeIf "bolt" "selvage" (not (hasAspect "bolt" "gusset")) "interlining")
    # test-hasAspect-guard-fails: the guard reads an aspect nothing includes.
    (includeIf "bolt" "selvage" (hasAspect "bolt" "godet") "ruffle")
    # test-guard-passes: `_: true`. (test-guard-fails, `_: false`, is `binding`: no declaration.)
    (includeIf "bolt" "selvage" always "piping")
    # a guard on an includer nothing reaches is never consulted.
    (includeIf "bolt" "smocking" always "shirring")
    # a guard reading what another guard includes, written before it (issue-540's multi-pass shape).
    (includeIf "bolt" "selvage" (hasAspect "bolt" "facing") "hem")
    # `hasAspect godet || hasAspect gusset`: one declaration per disjunct, one head.
    (includeIf "bolt" "selvage" (hasAspect "bolt" "godet") "placket")
    (includeIf "bolt" "selvage" (hasAspect "bolt" "gusset") "placket")
    # `!(hasAspect gusset && hasAspect facing)` = `!gusset || !facing`: DNF, so no fresh atom.
    (includeIf "bolt" "selvage" (not (hasAspect "bolt" "gusset")) "yoke")
    (includeIf "bolt" "selvage" (not (hasAspect "bolt" "facing")) "yoke")
  ]
  ++ heldAll "bolt";

  # `remnant`: the same fallback, with gusset excluded (v1's guard is exclude-aware), and an inherited
  # aspect from the parent scope `bale`. bolt's gusset does not reach remnant's guard (#613).
  remnant = [
    (root "bale" "lining")
    (root "remnant" "selvage")
    (includes "remnant" "selvage" "gusset")
    (includes "remnant" "selvage" "bias")
    (excludes "remnant" "bias" "gusset")
    (includeIf "remnant" "selvage" (hasAspect "remnant" "gusset") "facing")
    (includeIf "remnant" "selvage" (not (hasAspect "remnant" "gusset")) "interlining")
    (inherits "bale" "remnant" "lining")
    (includeIf "remnant" "selvage" (hasAspect "remnant" "lining") "collar")
  ]
  ++ heldAll "remnant";

  # c8: an exclude cycle with no `!` written at the guard. dart enters when welt is held, and dart
  # excludes welt. No stable model: dart reads U, the adjudication is `refused`, and nothing settled
  # beside it moves.
  cycle = [
    (root "bolt" "welt")
    (held "bolt" "welt")
    (includeIf "bolt" "welt" (hasAspect "bolt" "welt") "dart")
    (excludes "bolt" "dart" "welt")
  ];

  solve =
    declarations:
    genProgram.model {
      program = genProgram.program [
        "bale"
        "bolt"
        "remnant"
      ] declarations;
      interpretation = [ ];
      prior = null;
      complete = true;
    };
in
{
  includeIfPass = solve (bolt ++ remnant);
  includeIfCycle = solve (bolt ++ remnant ++ cycle);
  # v1's guard as written, a closure over `ctx`, has no body to lower: refused at the door by name.
  includeIfClosure = genProgram.declaration {
    when = ctx: ctx.hasAspect "gusset";
  } [ "bolt" ] "facing:bolt";
}
