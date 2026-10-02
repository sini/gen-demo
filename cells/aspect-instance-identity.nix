# `aspect-instance-identity` — C135, den-hoag-0cmbt (U6). A parametric aspect applied at a scope is a
# node of its own, the instance, identified by its declaration and the identities that supplied what it
# receives (gen-aspects `instanceOf`), and `instancesFor` is the relation of those nodes: one vertex
# per instance, edges from the scopes that reach it, and edges from a vertex to the instances its body
# reaches. The aspects are declared in the corpus's own grammar. Two entity kinds, `loom` (a scope's
# own) and `shuttle` (a descendant's), and one argument, `tension`, supplied by a gen-scope
# `argumentBinding` (K1): introduced at `loft` and inherited by `warpA` and `warpB`, overridden at
# `warpC`. Every context is derived from `suppliers`, written as one literal entry per supplier node.
#
# Each limb names the den-hoag-0cmbt spec §3a cell it carries:
#   S1  `{ }:` at a wider context is handed `{ }` through `wrapFn`, the aspect type's merge,
#       `applyGuard` and a functor; before the shape classifier each aborted uncatchably;
#   I-1 `gauge` at two looms is two instances, and the relation's vertex id is `instanceOf`'s;
#   I-2 `warpA` and `warpB` differ in `dye`, which `gauge` never receives, and reach one instance;
#   I-4 `twill`, defined twice (`c:` and `{ tension }:`), is a guard carrier whose formals are the
#       union, `loom` and `tension`;
#   R-3 `pick`, reached inside `gauge`'s body, is one nested instance, and `warpB`'s own `pick` edge
#       is that same vertex;
#   R-7 `heddle` fans out over a scope's shuttles, one instance each, and has no edge where there are
#       none;
#   B-2 the inherited binding is one id at both scopes that inherit it, and the override another, so
#       `temper` is one instance across `warpA` and `warpB` and another at `warpC`.
# `ctx:`, `{ ... }:` and `{ }:` are each reached from all three warps: the first two are keyed on the
# loom (the entity kinds narrow them), and `{ }:` is one instance everywhere.
{
  asserts,
  genAspects,
  genMerge,
  genScope,
  inputs,
}:
let
  cnf = import ../aspect-cnf.nix // {
    entityKinds = [
      "loom"
      "shuttle"
    ];
  };
  keys = c: builtins.concatStringsSep "," (builtins.attrNames c);
  aspects =
    (genMerge.evalModuleTree {
      modules = [
        { options.aspects = (genAspects.mkAspectSchema cnf).mkAspectOption { }; }
        {
          aspects = {
            frame.includes = [
              "bare"
              "open"
              "closed"
              "gauge"
              "heddle"
              "twill"
              "temper"
            ];
            bare = c: { description = "bare:${keys c}"; };
            open = { ... }: { description = "open"; };
            closed = { }: { description = "closed"; };
            gauge =
              { loom, ... }:
              {
                description = "gauge-${loom}";
                includes = [ "pick" ];
              };
            pick = { loom, ... }: { description = "pick-${loom}"; };
            heddle = { shuttle, ... }: { description = "heddle-${shuttle}"; };
            temper = { tension, ... }: { description = "temper-${tension}"; };
          };
        }
        { aspects.twill = c: { description = "twill:${keys c}"; }; }
        { aspects.twill = { tension }: { description = "twill-${tension}"; }; }
      ];
    }).config.aspects;

  entity = n: inputs.gen.lib.substrate.identity.hashIdentity "entity" [ "name" ] (_: n);
  binding =
    scope: name:
    genScope.argumentBinding {
      inherit scope name;
      supplyRoute = "specialArgs";
    };
  inherited = binding "loft" "tension";
  override = binding "warpC" "tension";
  dye = binding "warpB" "dye";

  # Written as a literal: one value per (supplier, key) by construction, and a repeated name aborts.
  suppliers = {
    ${entity "jacquard"}.loom = "jacquard";
    ${entity "dobby"}.loom = "dobby";
    ${entity "fly"}.shuttle = "fly";
    ${entity "boat"}.shuttle = "boat";
    ${entity "rapier"}.shuttle = "rapier";
    ${inherited}.tension = "taut";
    ${override}.tension = "slack";
    ${dye}.dye = "madder";
  };
  warp = loom: tension: shuttles: extra: members: {
    inherit members;
    sources = {
      loom = entity loom;
      inherit tension;
    }
    // extra;
    descendants = map (s: {
      sources = {
        loom = entity loom;
        shuttle = entity s;
        inherit tension;
      };
    }) shuttles;
  };
  r = genAspects.instancesFor cnf aspects {
    inherit suppliers;
    scopes = {
      warpA = warp "jacquard" inherited [ "fly" "boat" ] { } [ "frame" ];
      warpB = warp "jacquard" inherited [ "rapier" ] { inherit dye; } [
        "frame"
        "pick"
      ];
      warpC = warp "dobby" override [ ] { } [ "frame" ];
    };
  };
  at = n: a: r.reaches.${n}.${a} or [ ];
  descs = ids: builtins.sort (x: y: x < y) (map (id: r.vertices.${id}.entry.description) ids);
  one = a: at "warpA" a == at "warpB" a && builtins.length (at "warpA" a) == 1;
  apart = a: one a && at "warpC" a != at "warpA" a && builtins.length (at "warpC" a) == 1;

  wide = {
    loom = "jacquard";
    dye = "madder";
  };
  closedEmpty = { }: { description = "ce"; };
  s1 =
    (genAspects.wrapFn cnf "closedEmpty" closedEmpty wide).description == "ce"
    && (aspects.closed wide).description == "closed"
    && (genAspects.applyGuard wide closedEmpty).description == "ce"
    &&
      (genAspects.applyGuard wide { __functor = _: { }: { description = "fce"; }; }).description == "fce";

  gaugeA = builtins.head (at "warpA" "gauge");
  i1 =
    apart "gauge"
    && descs (at "warpC" "gauge") == [ "gauge-dobby" ]
    &&
      (genAspects.instanceOf cnf {
        # the mint's relatum is the aspect's identity (`cnf.providerPrefix` is unset, so `[ ]`); a
        # vertex's `aspect` is its facts id
        aspect = genAspects.aspectId [ ] aspects.gauge;
        value = aspects.gauge;
        context = wide;
        sources = {
          loom = entity "jacquard";
          inherit dye;
        };
      }).id == gaugeA;
  i2 = one "gauge" && r.vertices.${gaugeA}.formals == { loom = entity "jacquard"; };
  shapes =
    apart "bare"
    && apart "open"
    && one "closed"
    && at "warpC" "closed" == at "warpA" "closed"
    && r.vertices.${builtins.head (at "warpA" "closed")}.formals == { }
    && descs (at "warpB" "bare") == [ "bare:loom" ];
  twillA = r.vertices.${builtins.head (at "warpA" "twill")};
  i4 =
    aspects.twill ? fragments
    &&
      builtins.attrNames twillA.formals == [
        "loom"
        "tension"
      ]
    &&
      twillA.entry == (genAspects.mkGuardVocab cnf).applyGuard {
        loom = "jacquard";
        tension = "taut";
      } aspects.twill
    && apart "twill";
  nestedPick = builtins.concatMap (id: r.nested.${id}.pick or [ ]) (at "warpA" "gauge");
  r3 =
    builtins.length nestedPick == 1
    && descs nestedPick == [ "pick-jacquard" ]
    && at "warpB" "pick" == nestedPick
    && at "warpA" "pick" == [ ];
  r7 =
    descs (at "warpA" "heddle") == [
      "heddle-boat"
      "heddle-fly"
    ]
    && descs (at "warpB" "heddle") == [ "heddle-rapier" ]
    && !(r.reaches.warpC ? heddle);
  b2 =
    inherited != override
    && inherited == binding "loft" "tension"
    && apart "temper"
    && descs (at "warpA" "temper") == [ "temper-taut" ]
    && descs (at "warpC" "temper") == [ "temper-slack" ];
in
{
  construct = [ "C135" ];
  # B-2's bindings first: a constructor that ignores the scope makes `suppliers` name one binding
  # twice, which aborts uncatchably, so the conjunct that reads them apart must fail before it.
  check = asserts (b2 && s1 && i1 && i2 && shapes && i4 && r3 && r7);
}
