{
  title = "the warm walk reads no raw payload";
  adr = "0034, 0025 item 1";
  what = "`warm-walk-reads-no-raw-payload`: a `spool` identity under nixpkgs' `listOf`, `nullOr` and `functionTo` that an edit moves is served warm, equal to cold, where the first two were refused by a payload rebuild and `functionTo` aborted uncatchably; under gen's `listOf` the move is still refused; through `mkOptionType`, `coercedTo` keeps `coercedType`/`finalType` and a freeform `submodule` keeps `freeformType`, where both read `nestedTypes = { }`";
}
