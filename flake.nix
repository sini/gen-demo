{
  description = "gen-demo — the acceptance corpus for gen: gen-demo v1, one declaration per ruled construct";

  inputs = {
    # The only input of note. gen-demo consumes the hub the way den v2 will: through its published
    # surface, with no library code of its own and no direct pin on any gen-* member.
    gen.url = "github:sini/gen";

    # ★ THE SIBLING `gen-bind` INPUT C22 CARRIED IS GONE, AND ITS OWN DROP CONDITION IS WHY. It
    # existed because the hub's `gen-bind` pin sat behind den-hoag-gcr8x's extent peer-read shape,
    # and it said to drop it "once the hub's own `gen-bind` pin reaches or passes gcr8x's landed
    # sha". Measured BY NODE PATH at the drop (den-hoag-c22-sibling-exception-vacuous-2upv0), and a
    # clone's HEAD is not a source: `27860c87…` reads identically in the hub's own lock at the
    # revision this flake pins, in the `gen-bind` node of THIS lock, and at the hub's `main`. The
    # exception had stopped discriminating, so it was carrying nothing but the appearance of a
    # sanctioned carve-out — and C22 now takes the ordinary path, the hub's `genBind` module arg.
    # There is no longer any direct pin on a `gen-*` member here, which is the claim the first
    # comment above makes and the one this repository exists to keep true.

    # The systems the one `nixos` target is built with are the hub's own nixpkgs, so
    # `--override-input gen github:sini/gen` moves the target's nixpkgs with the hub rather than
    # holding it fixed against a hub that has moved on.
    nixpkgs.follows = "gen/nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      {
        lib,
        config,
        # Read only from INSIDE a value (the `gen` merge below), never to decide this module's own
        # top-level key set — that would be circular: the module system needs this module's
        # declarations to finish computing `options`.
        options,
        genScope,
        genGraph,
        genSelect,
        genValues,
        genAlgebra,
        genBind,
        genDispatch,
        genAspects,
        genSchema,
        ...
      }:
      let
        # `gen-view`, `gen-program` and `gen-delivery` are NOT among the eight module args
        # `flakeModules.genLibs` injects (`genAlgebra genSchema genAspects genScope genGraph genSelect
        # genBind genDispatch`, `gen/flakeModules/genLibs.nix`); they are reached through the published
        # stratum buckets instead — `substrate.view` and `framework.{program,delivery}`. `genProduct`,
        # `genMemo`, `genLink`, `genClass`, `genAssemble` and `genMerge` (v1.1) are reached the same
        # way, for the same reason.
        genView = inputs.gen.lib.substrate.view;
        genProgram = inputs.gen.lib.framework.program;
        genDelivery = inputs.gen.lib.framework.delivery;
        genProduct = inputs.gen.lib.substrate.product;
        genMemo = inputs.gen.lib.substrate.memo;
        genLink = inputs.gen.lib.aspects.link;
        genClass = inputs.gen.lib.aspects.class;
        genAssemble = inputs.gen.lib.framework.assemble;
        genMerge = inputs.gen.lib.modules.merge;
        # gen-rules, the one closure door (C142), at the `framework` bucket like gen-program.
        genRules = inputs.gen.lib.framework.rules;
        # gen-settings, at the `framework` bucket like gen-rules (den-hoag-7gp66 P2 L5's cell).
        genSettings = inputs.gen.lib.framework.settings;
      in
      {
        imports = [
          inputs.gen.flakeModules.default # the entry surface: gen.tree / gen.aspectCnf / systems out
          inputs.gen.flakeModules.genLibs # the roster as module args (genScope, genSchema, …)
        ];

        systems = [ "x86_64-linux" ];

        # `mkMerge` under ONE `gen` attrset, never a chain of top-level `//`: `//` shallow-updates
        # `gen` and SILENTLY DROPS the keys of the earlier operand, after which `requireCnf` fires
        # and reads exactly like a wiring failure.
        gen = lib.mkMerge [
          {
            tree = ./gen-modules;
            aspectCnf = import ./aspect-cnf.nix;
          }
          # THE NODE REGISTRY (ADR-0035): the hub no longer spells this word itself, so the corpus
          # names the attribute path of its own registry. Guarded on `options.gen ?
          # nodeRegistryPath` for the same reason `gen-schema/examples/demo` guards `aspectCnf`:
          # the option is undeclared at the committed pin, and DEFINING it there — even as `null` —
          # is itself "the option `gen.nodeRegistryPath' does not exist" (measured: exit 1 on this
          # corpus's own lock). The key is omitted outright, not conditioned false, so ARM 1 stays
          # green on the committed pin while ARM 2 exercises the option against the hub's main.
          (lib.optionalAttrs (options.gen ? nodeRegistryPath) {
            nodeRegistryPath = [ "haberdashery" ];
          })
        ];

        perSystem =
          { pkgs, ... }:
          let
            # A check is a derivation, so an assertion has to become one. `throw` rather than
            # `assert` so a red names the cell instead of printing a file position.
            asserts =
              name: cond:
              if cond then
                pkgs.runCommand "gen-demo-${name}" { } "touch $out"
              else
                throw "gen-demo: check '${name}' failed";

            # ── THE LAYOUT: every `.nix` file in `constructs/` and `cells/` is discovered, never
            # listed. A construct file is a function of the names it reads, returning the names it
            # declares; a cell file is a function of the names it reads, returning
            # `{ construct; check; }`, and its check is named after the file. Adding either is adding
            # one file. See README.md, "Adding a construct or a cell".
            nixFilesIn =
              dir:
              lib.mapAttrs' (file: _: lib.nameValuePair (lib.removeSuffix ".nix" file) (dir + "/${file}")) (
                lib.filterAttrs (file: type: type == "regular" && lib.hasSuffix ".nix" file) (builtins.readDir dir)
              );

            # Call `f` with exactly the arguments its formals name, each read lazily out of `names`.
            # The argument set's KEYS come from `functionArgs`, never from `names`, so a construct
            # file can read a name another construct file declares without the fixpoint below
            # having to know its own key set first (which would be infinite recursion). A name
            # nothing declares is refused BY NAME, at the first read.
            callWith =
              names: where: f:
              f (
                lib.mapAttrs (
                  arg: _: names.${arg} or (throw "gen-demo: ${where} reads '${arg}', which nothing declares")
                ) (builtins.functionArgs f)
              );

            # What every construct and cell may read without declaring it: the module args, the
            # hub's buckets bound above, this system's `pkgs`, and the flake's inputs.
            base = {
              inherit
                lib
                pkgs
                config
                options
                inputs
                genScope
                genGraph
                genSelect
                genValues
                genAlgebra
                genBind
                genDispatch
                genAspects
                genView
                genProgram
                genDelivery
                genProduct
                genMemo
                genLink
                genClass
                genSchema
                genAssemble
                genMerge
                genRules
                genSettings
                ;
            };

            # One namespace over `base` and every construct file. `//` would let a second
            # declaration of a name silently replace the first, so a name declared twice is
            # refused, naming both declaring files.
            constructFiles = nixFilesIn ./constructs;
            declared = lib.mapAttrs (
              stem: file: callWith corpus "constructs/${stem}.nix" (import file)
            ) constructFiles;
            declaredBy = lib.zipAttrs (
              [ (lib.mapAttrs (_: _: "the flake's own module args") base) ]
              ++ lib.mapAttrsToList (stem: decls: lib.mapAttrs (_: _: "constructs/${stem}.nix") decls) declared
            );
            clashes = lib.filterAttrs (_: by: builtins.length by > 1) declaredBy;
            corpus =
              if clashes == { } then
                builtins.foldl' (acc: decls: acc // decls) base (builtins.attrValues declared)
              else
                throw "gen-demo: declared more than once: ${
                  lib.concatStringsSep "; " (
                    lib.mapAttrsToList (n: by: "'${n}' by ${lib.concatStringsSep ", " by}") clashes
                  )
                }";

            cells = lib.mapAttrs (
              name: file: callWith (corpus // { asserts = asserts name; }) "cells/${name}.nix" (import file)
            ) (nixFilesIn ./cells);

            # den-hoag-nv8fd — a construct is its NAME, and its facts are one file, `index/<name>.nix`
            # (`{ title; adr; what; }`), checked against the constructs the cells THEMSELVES attribute
            # (each cell file's `construct`), plus the one construct with no check cell (the planted
            # refusals). There is no committed table and no number to choose: two units adding a
            # construct add two files and share no line, and two units choosing the same name add the
            # same path, which git reports at the first merge. The index is rendered, never written:
            # `nix build .#construct-index`.
            #
            # `legacy-ids.nix` keeps every citation that predates the names resolving. `constructs`
            # and `rows` map each old `C<n>` / `row<n>` id to the name it became, frozen at the
            # migration (frozen by convention: nothing here refuses a new key yet). `renamed` maps a
            # retired name to its successor, so a rename keeps the old name, and through it the
            # legacy id, resolving; a legacy value is never edited. Checked here: every legacy id and
            # every `renamed` target resolves to an index entry, and no `renamed` key is still a live
            # name (the old name must actually be retired, and a chain cannot form).
            #
            # den-hoag-v4cpr — the comparing runs at EVAL time rather than in a `runCommand` shell
            # script: a script's `exit 1` is invisible to `nix flake check --no-build`. Only the
            # SUCCESS path builds a derivation, to keep the report.
            indexEntries = lib.mapAttrs (_: file: import file) (nixFilesIn ./index);
            legacy = import ./legacy-ids.nix;

            constructIndex =
              let
                sortUnique = l: lib.unique (builtins.sort (a: b: a < b) l);
                noCell = [ "planted-refusals" ];
                expected = sortUnique (lib.concatMap (c: c.construct) (builtins.attrValues cells) ++ noCell);
                have = builtins.attrNames indexEntries;
                renamed = legacy.renamed.constructs;
                resolve = name: renamed.${name} or name;
                aliasesOf =
                  name:
                  let
                    formerNames = builtins.attrNames (lib.filterAttrs (_: n: n == name) renamed);
                  in
                  builtins.attrNames (
                    lib.filterAttrs (_: n: n == name || builtins.elem n formerNames) legacy.constructs
                  )
                  ++ formerNames;
                dangling = lib.filterAttrs (_: name: !(indexEntries ? ${resolve name})) legacy.constructs;
                renamedDangling = lib.filterAttrs (_: new: !(indexEntries ? ${new})) renamed;
                renamedLive = builtins.filter (old: indexEntries ? ${old}) (builtins.attrNames renamed);
                unindexed = lib.subtractLists have expected;
                uncited = lib.subtractLists expected have;
                # A cell still citing an id the migration retired gets the name it should cite.
                legacyHint =
                  id:
                  lib.optionalString (legacy.constructs ? ${id})
                    " (${id} is a legacy id: cite '${resolve legacy.constructs.${id}}')";
                badNames = builtins.filter (n: builtins.match "[a-z0-9-]+" n == null) have;
                idKey = id: [
                  (lib.toInt (builtins.head (builtins.match "[A-Za-z]*([0-9]+).*" id)))
                  id
                ];
                legacyFirst = builtins.sort (a: b: idKey a < idKey b) (builtins.attrNames legacy.constructs);
                ordered = lib.unique (
                  builtins.filter (n: indexEntries ? ${n}) (map (id: resolve legacy.constructs.${id}) legacyFirst)
                  ++ have
                );
                row =
                  name:
                  let
                    e = indexEntries.${name};
                  in
                  "| ${name} | ${lib.concatStringsSep ", " (aliasesOf name)} | ${e.adr} | ${e.title}: ${e.what} |";
                readmeTable = builtins.filter (l: builtins.match "\\| [A-Za-z0-9]+ -- .*" l != null) (
                  lib.splitString "\n" (builtins.readFile ./README.md)
                );
                problems =
                  lib.optional (unindexed != [ ])
                    "a cell attributes a construct with no index entry: ${
                      lib.concatMapStringsSep ", " (n: "${n}${legacyHint n}") unindexed
                    }; a construct is `index/<name>.nix`, `{ title; adr; what; }`"
                  ++
                    lib.optional (uncited != [ ])
                      "an index entry no cell attributes: ${
                        lib.concatMapStringsSep ", " (n: "index/${n}.nix") uncited
                      }; name it in a cell's `construct`, or remove the file"
                  ++ lib.optional (
                    dangling != { }
                  ) "legacy-ids.nix names no construct: ${lib.concatStringsSep ", " (builtins.attrNames dangling)}"
                  ++
                    lib.optional (renamedDangling != { })
                      "legacy-ids.nix renamed.constructs names no construct: ${
                        lib.concatStringsSep ", " (lib.mapAttrsToList (old: new: "${old} -> ${new}") renamedDangling)
                      }"
                  ++
                    lib.optional (renamedLive != [ ])
                      "legacy-ids.nix renamed.constructs retires a name index/ still carries: ${lib.concatStringsSep ", " renamedLive}"
                  ++ lib.optional (
                    badNames != [ ]
                  ) "an index name is not [a-z0-9-]+: ${lib.concatStringsSep ", " badNames}"
                  ++
                    lib.optional (readmeTable != [ ])
                      "README.md carries a hand-written construct table; a construct is `index/<name>.nix` and the table is `nix build .#construct-index`";
              in
              {
                agrees = problems == [ ];
                inherit problems;
                report = ''
                  cells/: ${toString (builtins.length (builtins.attrNames cells))} cells discovered
                  index/: ${toString (builtins.length have)} constructs agree with ${toString (builtins.length expected)} expected; ${toString (builtins.length (builtins.attrNames legacy.constructs))} legacy ids and ${toString (builtins.length (builtins.attrNames renamed))} renamed names resolve
                '';
                markdown = lib.concatStringsSep "\n" (
                  [
                    "| construct | legacy id, former name | ADR | what it is here |"
                    "| --- | --- | --- | --- |"
                  ]
                  ++ map row ordered
                  ++ [ "" ]
                );
              };
          in
          {
            checks = lib.mapAttrs (_: cell: cell.check) cells // {
              construct-index =
                if constructIndex.agrees then
                  pkgs.writeText "gen-demo-construct-index" constructIndex.report
                else
                  throw "gen-demo: check 'construct-index' failed: ${lib.concatStringsSep "; " constructIndex.problems}";
            };
            packages.construct-index = pkgs.writeText "construct-index.md" constructIndex.markdown;
          };
      }
    );
}
