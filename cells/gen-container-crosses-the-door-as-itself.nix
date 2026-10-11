# `gen-container-crosses-the-door-as-itself` — den-hoag-we9fu. A container gen-merge itself completed,
# over a gen `submodule`, crosses gen-merge's `mkOptionType` door as itself, where the door refused it
# at construction. Through the door, gen's `nullOr` and `attrsOf` over `S` read what nixpkgs' own
# `lib.evalModules` reads on the same record, and so does the door handed its own output. A copy of
# gen's `nullOr` over `S` whose `check` rejects `a = 1` keeps that check through the door: the planted
# `{ a = 1; }` is refused catchably, never served silently.
{
  asserts,
  genMerge,
  lib,
}:
{
  construct = [ "gen-container-crosses-the-mkoptiontype-door-as-itself" ];
  check = asserts (
    let
      seam = mkOption: type: v: [
        { options.seam = mkOption { inherit type; }; }
        { seam = v; }
      ];
      read = type: v: (genMerge.evalModuleTree { } (seam genMerge.mkOption type v)).config.seam;
      nixpkgsRead = type: v: (lib.evalModules { modules = seam lib.mkOption type v; }).config.seam;
      json = builtins.toJSON;
      same = type: v: json (read type v) == json (nixpkgsRead type v);
      refused = type: v: !(builtins.tryEval (builtins.deepSeq (read type v) null)).success;
      door = genMerge.mkOptionType;
      types = genMerge.types;
      S = types.submodule { options.a = genMerge.mkOption { type = types.int; }; };
      nullS = types.nullOr S;
    in
    same (door nullS) { a = 2; }
    && same (door (types.attrsOf S)) { k.a = 2; }
    && same (door (door (lib.types.nullOr S))) { a = 2; }
    && refused (door (nullS // { check = v: nullS.check v && (v == null || v.a or 0 != 1); })) {
      a = 1;
    }
  );
}
