{
  title = "a wrapped value declared twice keeps its check";
  adr = "0025 item 1";
  what = "`wrapped-check-redeclared`: `spool` declared twice with one nixpkgs `addCheck` over gen-merge's `int` refuses `5` and reads `2`, where gen-merge merged to bare `int` and served `5`; declared beside plain `int`, in either order, the merge would drop the check and is refused, by name in `refusals` row 129";
}
