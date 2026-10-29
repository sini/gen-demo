{
  title = "the aspect container declared twice, both stating its default, is refused";
  adr = "0039, xh14j K3";
  what = "`aspect-container-declared-twice-stating-its-default-is-refused`: `mkAspectModule`'s keyed record beside the same record applied to a module's own arguments declares `options.aspects` twice, both stating `default`; gen-merge refuses it by name in both orders, as nixpkgs refuses it (`bothHave`). The record imported twice is one module";
}
