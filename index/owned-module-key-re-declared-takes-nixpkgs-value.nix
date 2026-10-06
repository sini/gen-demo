{
  title = "an owned `_module` key re-declared takes nixpkgs' value";
  adr = "0025 item 1, wv300";
  what = "`module-decl-shapes`: an `options._module` typed `submodule` takes `_module.weft` and still serves `_module.args.sateen`, and an `apply` on `args` declared inside it maps the merged set; an `apply` on a nested child's `_module.args` maps the set holding its position's `name`, under `attrsOf` of a gen module tree and of `types.submodule`, so the child reads the applied `name`; each equals nixpkgs' own `lib.evalModules` over the same input, where gen-merge refused the leaf as a single option and read the position over the `apply`. The child with no `apply` reads its position, the control; the planted halves (an owned key re-declared with another type, or as a group) are `refusals` row 137";
}
