# shellcheck shell=bash
# ── a forwarded argument set reaching an instance through a second foreign join is refused by name,
#    catchably (den-hoag-psqwi; C29) ──
# C29's `bobbin` instance type declared LAST of three, after a nixpkgs `submoduleWith` stating no
# `specialArgs` and, first, one carrying the caller's set. The first join gen decides returns nixpkgs'
# record, and the second join is that record's to decide. A caller forwarding another instance's
# `config` beside its own `specialArgs` was served there: the instance read `id_hash` of another. The
# joined record now keeps the type's stated keys, so the second join refuses in either engine. The
# unplanted arms assert a STDOUT VALUE: a caller's non-stated `argand` crosses both joins and the
# instance keeps its own identity.
row_a_forwarded_set_through_a_second_foreign_join='let
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
  chain = evalF: mkOption: sa: (evalF [
      { options.b1 = mkOption { type = nsw sa; }; }
      { options.b1 = mkOption { type = nsw { }; }; }
      { options.b1 = mkOption { type = bobbin; default = { }; }; config.b1.spool = "linen"; }
    ]).config.b1;
  gen = chain (merge.evalModuleTree { }) merge.mkOption;
  np = chain (ms: lib.evalModules { modules = ms; }) lib.mkOption;
  fwd = { inherit argand; config = other; specialArgs = { }; };
  read = b: b.selvage + " " + b.spool + " " + (if b.id_hash == other.id_hash then "ID-OF-ANOTHER" else "own-id");
  green = read (gen { inherit argand; });
  greenNp = read (np { inherit argand; });
  planted = read (gen fwd);
  plantedNp = read (np fwd);
  caught = if (builtins.tryEval planted).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 a-forwarded-argument-set-reaching-an-instance-through-a-second-foreign-join-is-refused-by-name unplanted (a caller argand crosses both joins, the instance keeps its own id)" \
  "${row_a_forwarded_set_through_a_second_foreign_join/BODY/green}" 0 "" "$tmpdir/a-forwarded-set-through-a-second-foreign-join-green.err" 'gimp linen own-id'
check "T5 a-forwarded-argument-set-reaching-an-instance-through-a-second-foreign-join-is-refused-by-name unplanted (the same under nixpkgs' engine)" \
  "${row_a_forwarded_set_through_a_second_foreign_join/BODY/greenNp}" 0 "" "$tmpdir/a-forwarded-set-through-a-second-foreign-join-np-green.err" 'gimp linen own-id'
check "T5 a-forwarded-argument-set-reaching-an-instance-through-a-second-foreign-join-is-refused-by-name planted   (another instance's config forwarded to the second join is refused, gen's engine naming the pair)" \
  "${row_a_forwarded_set_through_a_second_foreign_join/BODY/planted}" 1 \
  "option \`b1' is declared with types that do not merge (\`submodule' and \`submodule')" \
  "$tmpdir/a-forwarded-set-through-a-second-foreign-join-red.err"
check "T5 a-forwarded-argument-set-reaching-an-instance-through-a-second-foreign-join-is-refused-by-name planted   (under nixpkgs' engine the second join refuses, naming the declarations)" \
  "${row_a_forwarded_set_through_a_second_foreign_join/BODY/plantedNp}" 1 \
  "is already declared in" \
  "$tmpdir/a-forwarded-set-through-a-second-foreign-join-np-red.err"
check "T5 a-forwarded-argument-set-reaching-an-instance-through-a-second-foreign-join-is-refused-by-name catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_a_forwarded_set_through_a_second_foreign_join/BODY/caught}" 0 "" "$tmpdir/a-forwarded-set-through-a-second-foreign-join-catch.err" 'CAUGHT'
