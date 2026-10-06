{
  title = "`attrs` serves a key its definitions agree on";
  adr = "0039, 0029, den-hoag-t1j4z";
  what = "`attrs-serves-agreeing-definitions`: two modules setting `selvedge.warp = \"flax\"`, one also setting `weft = \"tussah\"`, serve `{ warp = \"flax\"; weft = \"tussah\"; }` rather than refusing a shared key; with the second's `warp = \"linen\"`, `weft` still reads `\"tussah\"` and `warp` refuses by name, catchably";
}
