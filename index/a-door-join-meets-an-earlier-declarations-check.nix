{
  title = "a door join meets an earlier declaration's check";
  adr = "0039, pfbow";
  what = "nixpkgs' `evalModules` merges a redeclared option last declaration first and hands the receiver only each earlier declaration's functor, so a type crossing gen-merge's `defineType` names itself there and its join meets the earlier declaration's check: `attrTag { b = addCheck int (v != 1); }` then `attrTag { b = int; }` refuses `{ b = 1; }` where nixpkgs' twin serves it, and admits `{ b = 2; }` as the twin does; the same for a type whose `typeMerge` hands itself back; two enums still join as a union, a check owed inside its own enum only";
}
