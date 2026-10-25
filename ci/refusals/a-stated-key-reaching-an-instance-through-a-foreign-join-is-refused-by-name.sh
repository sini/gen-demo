# shellcheck shell=bash
# ── a stated key reaching an instance through a foreign join is refused by name, catchably
#    (den-hoag-b7v1h; C29) ──
# C29's `bobbin` instance type redeclared beside a nixpkgs `submoduleWith` whose `specialArgs` carry
# the caller's args. The join is nixpkgs' record and carries no refused set, so another instance's
# `config` planted there was served: the instance read `id_hash` of another. gen's relation now
# refuses it at the join in gen's engine, and the instance's own evaluation refuses it under
# nixpkgs' engine. The unplanted arm asserts a STDOUT VALUE: a caller's non-stated `argand` crosses
# the foreign join and the instance keeps its own identity.
row_a_stated_key_through_a_foreign_join='let
  flake = builtins.getFlake (toString ./.);
  lib = flake.inputs.nixpkgs.lib;
  schema = flake.inputs.gen.lib.substrate.schema;
  merge = flake.inputs.gen.lib.modules.merge;
  kinds = schema.evalSchema { specialArgs.argand.selvage = "tabby"; } [
    {
      config.schema.bobbin = {
        imports = [
          ({ argand, ... }: {
            options.selvage = merge.mkOption { type = merge.types.str; default = argand.selvage; };
          })
        ];
        options.spool = merge.mkOption { type = merge.types.str; };
      };
    }
  ];
  bobbin = schema.mkInstanceType { } kinds.bobbin;
  other = (merge.evalModuleTree { } [
      {
        options.b0 = merge.mkOption { type = bobbin.withArgs { argand.selvage = "tweed"; }; default = { }; };
        config.b0.spool = "wool";
      }
    ]).config.b0;
  nsw = sa: lib.types.submoduleWith { modules = [ ]; specialArgs = sa; shorthandOnlyDefinesConfig = true; };
  argand.selvage = "gimp";
  decls = mkOption: sa: [
      { options.b1 = mkOption { type = bobbin; }; }
      { options.b1 = mkOption { type = nsw sa; default = { }; }; config.b1.spool = "linen"; }
    ];
  read = b: b.selvage + " " + b.spool + " " + (if b.id_hash == other.id_hash then "ID-OF-ANOTHER" else "own-id");
  green = read (merge.evalModuleTree { } (decls merge.mkOption { inherit argand; })).config.b1;
  planted = read (merge.evalModuleTree { } (decls merge.mkOption { inherit argand; config = other; })).config.b1;
  plantedNp = read (lib.evalModules { modules = decls lib.mkOption { inherit argand; config = other; }; }).config.b1;
  caught = if (builtins.tryEval planted).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 a-stated-key-reaching-an-instance-through-a-foreign-join-is-refused-by-name unplanted (a caller argand crosses the foreign join, the instance keeps its own id)" \
  "${row_a_stated_key_through_a_foreign_join/BODY/green}" 0 "" "$tmpdir/a-stated-key-through-a-foreign-join-green.err" 'gimp linen own-id'
check "T5 a-stated-key-reaching-an-instance-through-a-foreign-join-is-refused-by-name planted   (another instance's config at the join is refused by gen's relation)" \
  "${row_a_stated_key_through_a_foreign_join/BODY/planted}" 1 \
  "a redeclaration supplies the base module argument \`config' to a \`submodule' that refuses it from a caller" \
  "$tmpdir/a-stated-key-through-a-foreign-join-red.err"
check "T5 a-stated-key-reaching-an-instance-through-a-foreign-join-is-refused-by-name planted   (under nixpkgs' engine the instance's own evaluation refuses it)" \
  "${row_a_stated_key_through_a_foreign_join/BODY/plantedNp}" 1 \
  "gen-schema: an instance of kind 'bobbin' is evaluated with a caller's \`config'" \
  "$tmpdir/a-stated-key-through-a-foreign-join-np-red.err"
check "T5 a-stated-key-reaching-an-instance-through-a-foreign-join-is-refused-by-name catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_a_stated_key_through_a_foreign_join/BODY/caught}" 0 "" "$tmpdir/a-stated-key-through-a-foreign-join-catch.err" 'CAUGHT'
