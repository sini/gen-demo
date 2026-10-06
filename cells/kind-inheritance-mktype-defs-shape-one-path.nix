# `kind-inheritance-mktype-defs-shape-one-path` — C26's `mkType` branch, den-hoag-4d2zs. A caller
# `mkType` receives the kind's raw defs and then ONE nested def holding its parents, whichever of
# the plain tree's desugar or `evalSchema`'s pass composed them, so the `dart` that inherits
# `notch` hands its caller one shape on both paths. The twin without `inherits` gets no nested def,
# the cell's own discriminator.
{
  asserts,
  c26DefsShapeStaged,
  c26DefsShapeBare,
  c26DefsShapeNoInherit,
}:
{
  construct = [ "kind-inheritance-resolves-a-value" ];
  check = asserts (
    c26DefsShapeStaged == c26DefsShapeBare && c26DefsShapeNoInherit != c26DefsShapeBare
  );
}
