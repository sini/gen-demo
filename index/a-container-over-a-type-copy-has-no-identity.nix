{
  title = "a container over a `//` copy of a type has no identity";
  adr = "0034, den-hoag-6d5r3";
  what = "`container-over-type-copy-refused-by-name`: `listOf`, `attrsOf`, `nullOr` and a nested `listOf` over `spool // { verify = _: null; }`, raw and re-completed through `types.defineType`, refuse an identity demand by name where each answered `listOf spool`'s identity, and `typeEq` never takes one for its plain twin; over `spool` itself each keeps its identity, and the values served are unchanged";
}
