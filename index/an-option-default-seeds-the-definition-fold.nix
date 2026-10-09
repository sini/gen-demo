{
  title = "an option default seeds the definition fold";
  adr = "0039 (serve half), 0025 item 1, 0029, 12e7r";
  what = "`option-default-seeds-the-fold`: an option's declared `default` that survives the priority filter beside priority-1500 definitions is the first definition the fold sees, as in nixpkgs' `evalOptionValue`, so under `genMerge.evalModuleTree` and `lib.evalModules` alike `listOf` serves `[ \"base\" \"late\" \"early\" ]` and a `submodule` default reads `[ \"late\" \"base\" ]` (the nested tree's module reversal puts it last), where gen-merge served the default last at the leaf and first in the nested tree; a plain definition beside the default drops it on both";
}
