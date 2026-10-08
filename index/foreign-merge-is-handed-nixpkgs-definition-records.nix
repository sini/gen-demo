{
  title = "a foreign merge is handed nixpkgs' definition records";
  adr = "0039, 0025 item 1, j5gfg";
  what = "`foreign-merge-reads-definition-files`: gen-merge's own `evalModuleTree` over nixpkgs `coercedTo str _ (listOf (lazyAttrsOf (attrsOf sub)))`, the `listOf` merge overridden to sort its definitions by `file` or to group them with `file` as an attribute name, reads each element's keys as the cell's own `lib.evalModules` reference does, where each aborted uncatchably: the threaded split hands its foreign merge `{ file; value; }`";
}
