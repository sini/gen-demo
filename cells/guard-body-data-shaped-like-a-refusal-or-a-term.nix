# `guard-body-data-shaped-like-a-refusal-or-a-term` — den-hoag-s1ua7 / den-hoag-3nr2o. A guard body's
# data is recognised as a refusal or a term only by gen-algebra's own predicates: `{ l.left = 1; }` is
# data and serves as written; the exact refusal shape refuses catchably; a record that spells
# `__bodyTerm` by hand refuses catchably, never firing as the term it imitates. What that refusal SAYS
# is the refusals row of the same name.
{
  asserts,
  s1ua7LeftData,
  s1ua7Refused,
}:
{
  construct = [ "guard-body-data-is-recognised-by-the-algebras-own-predicates" ];
  check = asserts (
    s1ua7LeftData == {
      l.left = 1;
    }
    &&
      s1ua7Refused == {
        refusalShape = true;
        handSpelledTerm = true;
      }
  );
}
