集合の基本４（べき集合、直積など）

サイトのTOP→理系インデックス
集合論のTOP→集合論インデックス




定義 （ べき集合 ）

Ｘ を集合とする。

Ｘ の部分集合全体を 『 Ｘ のべき集合 』 といい、２Ｘ と表す。

すなわち、２Ｘ＝｛ Ａ | Ａ⊂Ｘ ｝である。

例えば、Ｘ＝｛１，２，３｝ のべき集合は次のように表される。



べき集合の元の数は２のべき乗になる。

例えば、上の例では集合 Ｘ の元は３個で、２Ｘ の元は ２３＝８個 である。 

なぜこのような関係が成り立つのだろうか？

いま、２Ｘ に属する Ｘ の部分集合にどのようなものがあるかを考えてみよう。

これは Ｘ の各元が部分集合に 「 属する・属さない 」 の組み合わせを考えることと同じである。

だから、べき集合の元の数は２のべき乗になるのである。

べき集合を ２Ｘ と表すのもこれが理由である。

参考

Ａ⊂Ｘ と Ａ∈２Ｘ は同じ意味である。

定義 （ 直積～その１ ）

Ａ、Ｂ を集合とする。

元 ｘ∈Ａ と、元 ｙ∈Ｂ の組を（ｘ、ｙ）と表す。

さらに、（ｘ、ｙ）の相等を次のように定義する。



このとき、（ｘ、ｙ）を 『 ｘ と ｙ の順序対 』 という。

このような順序対全体を 『 Ａ と Ｂ の直積 』 といい、Ａ×Ｂ と表す。

すなわち、



とくに、Ａ×Ａ を Ａ２ と表す。

上の定義によれば、（ｘ、ｙ）＝（ｘ’、ｙ’）は ｘ＝ｘ’∧ ｙ＝ｙ’と定義されている。

これは、簡単にいうと、「 直積には順番が定義されている 」 ということである。

実際、集合については ｛１、３｝＝｛３、１｝ が成り立つが、（１、３） と （３、１） はそれぞれ別の元と見なされる。

例えば、Ａ＝｛ａ 、ｂ｝、Ｂ＝｛１、２、３｝ の直積は



このように、（１、ａ） や （３、ｂ） は属さない。

注意

次の（１）と（２）は同じ意味である。



参考

定義より、



直積の概念は座標と同じである。

実際、座標 （１，２） と （２，１） は異なる座標として見なされる。

直積と同じように、座標にも順番が定義されているのである。

座標は実数の順序対であるから、直積を用いて座標を表すと、Ｒ×Ｒ となる。

Ｒ×Ｒ を Ｒ２ と表してもよい。

平面座標は Ｒ２ を図式化したものであるといえる。

定義 （ 直積～その２ ）

改めて直積の定義をここに書こう。



これを ｎ個 の集合に拡張して次のように定義する。



これを次のように書き表すこともある。



とくに、Ａ１＝・・・＝Ａｎ＝Ａ ならば、この直積を Ａｎ と表す。

例えば、Ｒｎ は ｎ個 の実数の順序対全体を表す。

Ａ１４

Ａ、Ｂ、Ｃ を集合とする。

このとき、次が成り立つ。



（１）についてのみ証明する。

Ａ５より、



定義 （ 開区間、閉区間 ）

ａ、ｂ を実数とし、ａ＜ｂ とする。

このとき、Ｒ の部分集合について次のように定義する。



各集合を上から順番に 『 開区間 』 『 閉区間 』 『 左半開区間 』 『 右半開区間 』 という。

また、次のような区間を定義する。



開区間（ａ、ｂ）は実数の組を意味する（ａ、ｂ）と同じ記号であるが、これは文脈から区別する。




