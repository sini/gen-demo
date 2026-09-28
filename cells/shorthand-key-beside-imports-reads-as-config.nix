# `shorthand-key-beside-imports-reads-as-config` — C91, den-hoag-1n12c (G7). A `loom` kind declared
# `{ imports = [ weftModule ]; weft = "twill"; }` resolves `looms.jacquard.weft` to `"twill"` because
# gen-merge's `moduleSyntax.structuring` is narrowed to `config`/`options`: `imports` alone no longer
# structures the declaration, so `weft` is a shorthand config definition, not a surplus declaration
# key. Before the narrowing this shape was refused by name (`'weft'`) — the RED half of G7.
#
# The explicit-`config` twin, `{ imports = [ weftModule ]; config.weft = "twill"; }`, is the
# discriminator: nothing about `moduleSyntax.structuring` ever touched that form, and it reads the
# identical `"twill"`. Equal values off two syntactically different declarations is what shows the
# shorthand form landed the SAME reading the explicit form always had, not a coincidence of literals.
{
  asserts,
  c91ShorthandWeft,
  c91TwinWeft,
}:
{
  construct = [ "C91" ];
  check = asserts (c91ShorthandWeft == "twill" && c91TwinWeft == "twill");
}
