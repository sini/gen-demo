# `a-door-attrtag-receivers-tag-check-is-enforced-in-nixpkgs-evaluation` — den-hoag-yg7fo (ADR-0039). The
# `held-check-through-mk-option-type` attrTag holder (`attrTag { weft = mkOption { type = addCheck int (v != 5); }; }`),
# read in nixpkgs' `lib.evalModules` rather than gen's `evalModuleTree`, through both doors (`genMerge.mkOptionType`
# and `genMerge.types.mkOptionType`). nixpkgs reverses the declaration list, so the last declaration is the receiver,
# and the door return's `typeMerge` owes the receiver's tag checks. Per door and order (alone, twice, the unchecked
# holder then the door), `{ weft = 2; }` is served at its value and `{ weft = 5; }` is refused. The unchecked holder
# also declares `selvage`, a tag the receiver does not: `{ selvage = 7; }` is served, and a throwing `selvage` value is
# not forced. gen-merge served `{ weft = 5; }` at twice and unchecked-then-door. The door-then-unchecked order (the
# door's declaration as nixpkgs' partner) is not read here.
{
  asserts,
  genMerge,
  lib,
}:
let
  ft = lib.types;
  eval =
    types: v:
    (lib.evalModules {
      modules = map (type: { options.bobbin = lib.mkOption { inherit type; }; }) types ++ [
        { config.bobbin = v; }
      ];
    }).config.bobbin;
  read =
    types: v:
    let
      r = builtins.tryEval (builtins.deepSeq (eval types v) (eval types v));
    in
    if r.success then r.value else "REFUSED";
  # the tag names alone, so the undeclared tag's value is never forced by this reader
  names =
    types: v:
    let
      r = builtins.tryEval (builtins.attrNames (eval types v));
    in
    if r.success then r.value else "REFUSED";
  leaf = ft.addCheck ft.int (v: v != 5);
  holder = ft.attrTag { weft = lib.mkOption { type = leaf; }; };
  plain = ft.attrTag {
    weft = lib.mkOption { type = ft.int; };
    selvage = lib.mkOption { type = ft.int; };
  };
  orders = door: {
    alone = [ (door holder) ];
    twice = [
      (door holder)
      (door holder)
    ];
    plainThenDoor = [
      plain
      (door holder)
    ];
  };
  doors = {
    d1 = genMerge.mkOptionType;
    d2 = genMerge.types.mkOptionType;
  };
  expr = lib.mapAttrs (
    _: door:
    lib.mapAttrs (_: types: {
      admitted = read types { weft = 2; };
      rejected = read types { weft = 5; };
    }) (orders door)
    // {
      undeclaredServed = read (orders door).plainThenDoor { selvage = 7; };
      undeclaredUnforced = names (orders door).plainThenDoor { selvage = throw "selvage forced"; };
    }
  ) doors;
  cell = {
    admitted = {
      weft = 2;
    };
    rejected = "REFUSED";
  };
  expected = lib.mapAttrs (_: _: {
    alone = cell;
    twice = cell;
    plainThenDoor = cell;
    undeclaredServed = {
      selvage = 7;
    };
    undeclaredUnforced = [ "selvage" ];
  }) doors;
in
{
  construct = [ "a-door-attrtag-receivers-tag-check-is-enforced-in-nixpkgs-evaluation" ];
  check = asserts (expr == expected);
}
