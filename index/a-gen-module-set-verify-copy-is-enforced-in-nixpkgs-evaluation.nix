{
  title = "a gen module-set verify copy is enforced in nixpkgs' evaluation";
  adr = "0039, 0025 item 1 (den-hoag-olrmz)";
  what = "`module-set-verify-copy-in-nixpkgs-evaluation`: a gen `submodule`, and a gen `attrsOf` of one, copied with a member-reading `verify` and completed through `types.defineType`, `mkOptionType` or both in turn, declared in nixpkgs' `lib.evalModules`, serves an accepted value as nixpkgs' `addCheck` twin serves it and refuses a value its `verify` rejects, where nixpkgs' evaluation served the rejected value through the base's re-derived rebuild";
}
