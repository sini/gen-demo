{
  title = "kind inheritance resolves a value";
  adr = "0016 ruling 7, 0033";
  what = "the corpus's own `dart` kind inherits `notch`'s `grade` option through the relocated pass (`inherits = [ \"notch\" ]`); `darts.chambray` sets only `bevel`, so `grade` resolving to `notch`'s default is the inheritance and not two defaults agreeing; a mirrored fixture with `inherits` dropped shows the same option unreachable; the same pair through an `mkType` schema option whose result publishes no collections composes too (`kind-inheritance-mktype-resolves-a-value`), and the same pair on a plain `mkSchemaOption` tree composes identically, while a plain tree naming an undeclared parent, or closing an inheritance cycle, is refused by name (`ci/refusals/declared-inherits-on-a-tree-evalschema-did-not-build-composes-as-the-import.sh`)";
}
