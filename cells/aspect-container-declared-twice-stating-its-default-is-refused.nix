# `aspect-container-declared-twice-stating-its-default-is-refused` — a federated tree declaring the aspect container
# twice: `corpus.nix` imports `mkAspectModule`'s keyed record, and a second module applies the same record to its own
# arguments, so it is a plain module declaring `options.aspects` again. Both declarations state the container's
# `default`, which nixpkgs refuses (`bothHave`, "is already declared in"), and gen-merge refuses it by name too. The
# shape used to sit in the shared corpus module (`gen-modules/aspects-redeclaration.nix`), where gen served it and
# nixpkgs did not; it is this cell now, so the corpus keeps it as a refusal. Controls: the record imported twice is
# one construction, one module.
{
  asserts,
  genAspects,
  genMerge,
}:
let
  schema = genAspects.mkAspectSchema (import ../aspect-cnf.nix);
  read =
    mods:
    builtins.tryEval (
      builtins.deepSeq (builtins.attrNames
        (genMerge.evalModuleTree { } (mods ++ [ { aspects.probe = { }; } ])).config.aspects
      ) true
    );
  record = schema.mkAspectModule { };
  applied = args: (schema.mkAspectModule { }) args;
in
{
  construct = [ "aspect-container-declared-twice-stating-its-default-is-refused" ];
  check = asserts (
    !(read [
      record
      applied
    ]).success
    && !(read [
      applied
      record
    ]).success
    && (read [
      record
      record
    ]).success
  );
}
