{
  title = "an instance refusing a caller's config";
  adr = "0039";
  what = "gen-schema's instance type states `config`, `options` and `prefix` as base module args it refuses from a caller: a caller's `config` through the type's `withArgs` is refused, which gen-schema's own `specialArgs` door does not see, while `argand` through the same `withArgs` reaches the kind's module and the instance keeps its own field and identity";
}
