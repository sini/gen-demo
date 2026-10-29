{
  title = "a kind's collection reads an instance beside a same-named kind";
  adr = "0034, d65ta, xh14j (A)";
  what = "`kind-collection-reads-an-instance-beside-a-same-named-kind`: `host`'s identity-kept collection reads an instance of `host`, and its registry reaches another tree's kind also named `host`; kinds meet only at one declaration node, so the two never meet and the instance reads its own address and the other kind's port, as the renamed `box` control does. Before, the same-named pair met by name and the read recursed uncatchably";
}
