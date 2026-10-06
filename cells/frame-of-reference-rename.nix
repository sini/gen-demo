# `frame-of-reference-rename` — C94, den-hoag-41du. A category-preserving rename of a class key
# commutes with gen-delivery's projection, in its key SETS and in the content each class carries; the
# same rename declared `channel` does not. The content arm is what reds on a `project` that keeps every
# class key but gives content only to the literal `nixos` — a term meaning more than its category.
{ asserts, frameOfReferenceRename }:
let
  r = frameOfReferenceRename;
in
{
  construct = [ "rename-of-the-frame-of-reference" ];
  check = asserts (
    r.residue == [ ]
    && r.control != [ ]
    # the universe really carries two classes on one node, so the set comparison is load-bearing
    &&
      r.identityClasses.pewter == [
        r.second
        r.from
      ]
    && r.preservingClasses == r.rhoIdentityClasses
    && r.preservingContent == r.identityContent
    && r.changingClasses != r.rhoIdentityClasses
  );
}
