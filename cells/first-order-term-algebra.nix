# `first-order-term-algebra` — C137. A safe clause is admitted and fires; at a context where its
# declared coordinate is absent it does not fire (FALSE, not a refusal); the same body under `always`
# is refused naming the uncovered read; a misspelt coordinate is refused at declaration with the
# declared set; the body's derived reads are its one coordinate; and the body mints.
{
  asserts,
  basteAbsent,
  basteChecked,
  basteFired,
  basteIdentity,
  basteReads,
  basteUndeclaredChecked,
  basteUnsafeChecked,
}:
{
  construct = [ "one-first-order-term-algebra" ];
  check = asserts (
    basteChecked ? right
    && basteFired == { right.description = "baste-brass"; }
    && basteAbsent == { right = null; }
    && (basteUnsafeChecked.left.code or null) == "unsafe-read"
    && map (r: r.head) (basteUnsafeChecked.left.witness.uncovered or [ ]) == [ "thimble" ]
    && (basteUndeclaredChecked.left.code or null) == "undeclared-name"
    &&
      (basteUndeclaredChecked.left.witness.declared or null) == [
        "thimble"
        "bobbin"
      ]
    && basteReads == [ "thimble" ]
    && basteIdentity ? minted
    && builtins.substring 0 5 basteIdentity.minted == "term:"
  );
}
