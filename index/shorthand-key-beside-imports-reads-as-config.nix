{
  title = "a shorthand key beside `imports` reads as config";
  adr = "den-hoag-1n12c";
  what = "`shorthand-key-beside-imports-reads-as-config`: a `loom` kind declared `{ imports = [ weftModule ]; weft = \"twill\"; }` resolves `looms.jacquard.weft` to `\"twill\"`, because gen-merge's published `moduleSyntax.structuring` is narrowed to `config`/`options` and `imports` alone no longer structures the declaration; the explicit-`config` twin, `{ imports = [ weftModule ]; config.weft = \"twill\"; }`, reads the identical `\"twill\"` as the discriminator";
}
