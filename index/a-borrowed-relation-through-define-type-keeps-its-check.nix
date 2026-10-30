{
  title = "a borrowed relation through defineType keeps its check";
  adr = "0025 item 1, 0034, 23u3j";
  what = "`borrowed-relation-through-define-type-keeps-its-check`: `defineType` over a nixpkgs `mkOptionType` whose check admits ints below 12, with gen's `int` relation borrowed by `// { inherit (int) typeMergeRel; }`, declared alone and beside gen's `int` in either order, refuses `12` and serves `3`, and its return reads as the record raw does at `3`, `12` and `\"s\"`; gen-merge read a completion from the relation alone, so the door completed the record and published a `check` from gen's words, which it states none of, and served the value its own check rejects. A completion states both the relation and the check witness, so a record lacking either is returned as itself";
}
