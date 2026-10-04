# `guard-first-order-terms` — C141, den-hoag-lwbb1 unit 2. `c141Tuck` fires `tuck-pewter` where
# `thimble` is present, and under a declared set that lacks it at the context it answers `null`, not
# a refusal. `c141Pleat`'s inner guard survives the outer's firing as a guard and fires at its own:
# `pleat` at `nixos`, `null` at `darwin`. `c141DoorNode` fires through `instanceOf`, which carries the
# sources, to the stub door's `gusset-pewter`, keyed on the one coordinate it reads; through
# `applyGuard`, which carries none, it is refused catchably. The tuck's TERM key is the mint
# (`guard:`), the same at two aspect positions, and each position is a declaration of its own, keyed
# by its declared path (identity design §1). The control on the refusal side: a closure body is
# refused at declaration, catchably.
{
  asserts,
  genAspects,
  c141Tuck,
  c141Pleat,
  c141DoorNode,
  c141Cnf,
  c141Source,
  c141Place,
}:
let
  gv = genAspects.mkGuardVocab { };
  dv = genAspects.mkGuardVocab c141Cnf;
  caught = e: (builtins.tryEval (builtins.deepSeq e true)).success;
  closed = c141Place c141Cnf { tuck = c141Tuck; };
  firedOuter = gv.applyGuard { class = "darwin"; } c141Pleat;
  instance = genAspects.instanceOf c141Cnf {
    aspect = "gusset";
    value = c141DoorNode;
    context.thimble = "pewter";
    sources.thimble = c141Source "pewter";
  };
  placed = c141Place { } {
    a = c141Tuck;
    b = c141Tuck;
  };
in
{
  construct = [ "C141" ];
  check = asserts (
    (gv.applyGuard { thimble = "pewter"; } c141Tuck).description == "tuck-pewter"
    && dv.applyGuard { bobbin = "damask"; } closed.tuck == null
    && firedOuter.sub.__guard
    && (gv.applyGuard { class = "nixos"; } firedOuter.sub).description == "pleat"
    && gv.applyGuard { class = "darwin"; } firedOuter.sub == null
    && instance.entry.description == "gusset-pewter"
    && builtins.attrNames instance.formals == [ "thimble" ]
    && !(caught (dv.applyGuard { thimble = "pewter"; } c141DoorNode))
    && builtins.substring 0 6 (genAspects.guardKey placed.a) == "guard:"
    && genAspects.guardKey placed.a == genAspects.guardKey placed.b
    && genAspects.key placed.a == "a"
    && genAspects.key placed.b == "b"
    && !(caught (c141Place { } { c = genAspects.guard genAspects.pred.always (ctx: { }); }).c)
  );
}
