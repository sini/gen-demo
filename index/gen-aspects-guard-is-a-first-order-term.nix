{
  title = "a gen-aspects guard is a first-order term";
  adr = "Section 3, den-hoag-lwbb1";
  what = "`guard-first-order-terms`: `c141Tuck` (`has thimble`, body `concat [ (lit \"tuck-\") (readCtx \"thimble\" [ ]) ]`) fires `tuck-pewter` and, under a declared set with `thimble` absent, `null`; `c141Pleat`'s nested guard survives the outer's firing as a guard and refires `pleat` at `nixos`, `null` at `darwin`; `c141DoorNode` fires through `instanceOf` and the stub `cnf.ref` to `gusset-pewter`, formals `[ thimble ]`, and through `applyGuard` (no sources) refuses catchably; the tuck's term key (`guardKey`) is `guard:…`, one at two aspect positions, and each position is a declaration keyed by its declared path (`a`, `b`); control: a closure body refuses at declaration";
}
