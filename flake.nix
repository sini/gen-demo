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
                genAssemble
                genMerge
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

            # den-hoag-bl06m — README.md's "## What v1 declares" table is the one hand-maintained
            # index left over the construct set, and it is checked against the constructs the
            # cells THEMSELVES attribute (each cell file's `construct`), plus T5 — the one construct
            # with no check cell. The list of checks is no longer an index anybody maintains: it is
            # `cells/`, read. The comparison reports how many rows it scanned against how many it
            # expected — a comparison that passes without saying so is not an oracle over the set
            # it claims to cover.
            #
            # den-hoag-v4cpr — the comparing runs at EVAL time (`readFile` + string matching)
            # rather than in a `runCommand` shell script: a script's `exit 1` is invisible to
            # `nix flake check --no-build`. Only the SUCCESS path builds a derivation, to keep the
            # report.
            readmeIndex =
              let
                readmeLines = lib.splitString "\n" (builtins.readFile ./README.md);

                # awk '/start/,/end/' — the inclusive line range from the first line matching
                # `startRe` through the first LATER line matching `endRe`.
                sectionBetween =
                  startRe: endRe: ls:
                  let
                    idxs = lib.range 0 (builtins.length ls - 1);
                    at = i: builtins.elemAt ls i;
                    startIdx = lib.findFirst (i: builtins.match startRe (at i) != null) null idxs;
                    endIdx = lib.findFirst (i: i >= startIdx && builtins.match endRe (at i) != null) null idxs;
                  in
                  lib.sublist startIdx (endIdx - startIdx + 1) ls;

                sortUnique = l: lib.unique (builtins.sort (a: b: a < b) l);
                firstMatch =
                  re: line:
                  let
                    m = builtins.match re line;
                  in
                  if m == null then null else builtins.head m;

                declares = sectionBetween ".*## What v1 declares.*" ".*### The naming rule.*" readmeLines;
                expectedConstructs = sortUnique (
                  lib.concatMap (c: c.construct) (builtins.attrValues cells) ++ [ "T5" ]
                );
                tableRows = sortUnique (
                  builtins.filter (n: n != null) (map (firstMatch "\\| ([A-Za-z0-9]+) -- .*") declares)
                );
              in
              {
                agrees = tableRows == expectedConstructs;
                report = ''
                  cells/: ${toString (builtins.length (builtins.attrNames cells))} cells discovered
                  '## What v1 declares' table: scanned ${toString (builtins.length tableRows)} rows agree with ${toString (builtins.length expectedConstructs)} expected constructs
                '';
              };
          in
          {
            checks = lib.mapAttrs (_: cell: cell.check) cells // {
              construct-index =
                if readmeIndex.agrees then
                  pkgs.writeText "gen-demo-construct-index" readmeIndex.report
                else
                  throw "gen-demo: check 'construct-index' failed";
            };
          };
      }
    );
}
