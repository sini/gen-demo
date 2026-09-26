# `foreign-type-cross-instance-decides` — C75, den-hoag-6xj95. Two nixpkgs lib instances (`lib.extend`,
# or two nixpkgs inputs) build distinct records whose `functor.type` points back into their own lib,
# so a record `==` across them recursed until the evaluator aborted, uncatchably, whenever `functor`
# was interned before the first differing attribute. `typeEq` now compares each record's closures
# before the record, and decides every such pair. `_intern` is the adverse order: it interns
# `functor` first. `description` is interned by the evaluator itself at startup, so the synthetic
# back-edge through it is reached before `check` in every context. Live controls: each type still
# equals itself and its `// { }` copy, and two records sharing every closure but differing in
# `description` stay apart, so neither a `typeEq` answering `false` to everything nor one comparing
# closures alone can pass.
{ asserts, inputs }:
let
  _intern = {
    functor = 0;
  };
in
{
  construct = [ "C75" ];
  check = builtins.seq _intern (
    asserts (
      let
        inherit (inputs.gen.lib.modules.types) typeEq;
        t = inputs.nixpkgs.lib.types;
        u = (inputs.nixpkgs.lib.extend (_: _: { })).types;
        f = s: s != "a";
        mk =
          tag:
          let
            r = {
              _type = "option-type";
              name = "gauge";
              nestedTypes = { };
              description = r;
              check = v: v == tag;
            };
          in
          r;
        g = mk 1;
      in
      !(typeEq t.port u.port)
      && !(typeEq (t.ints.between 0 1) (u.ints.between 0 1))
      && !(typeEq t.nonEmptyStr u.nonEmptyStr)
      && !(typeEq (t.addCheck t.str f) (u.addCheck u.str f))
      && !(typeEq (t.listOf t.port) (u.listOf u.port))
      && !(typeEq g (mk 2))
      && !(typeEq (t.port // { description = "a"; }) (t.port // { description = "b"; }))
      && typeEq g g
      && typeEq t.port t.port
      && typeEq t.port (t.port // { })
    )
  );
}
