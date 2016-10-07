# System D<:

図1は我々のSystem D<: の式を要約したものです。
これらの項言語は本質的にラベルAと型Tが関連づいている型タグ{A=T}の値の形式が1つ追加されたラムダ計算です。
現時点では、我々は一つの型ラベルだけが必要で、Aはわずか1つの名前でアルファベット上の範囲とみなすことができます。
これは、後に一般化されます。

----

我々の説明は二つの側面でRompfとAmin（2015）とは異なります。
まず、項は[A正規形(ANF)](https://en.wikipedia.org/wiki/Algebraic_normal_form "Algebraic normal form")に制限されています。
これは、すべての中間値はlet束縛の中で抽象化されています。
次に、ビッグステップ評価とは対照的に、評価規則は小ステップ還元関係で表されます。
還元は完全な置換の代わりに唯一の変数/変数のリネームを使用しています。
置換ステップによってコピーされる代わりに、値はそれらのlet束縛にとどまります。
これは、call-by-need ラムダ計算(Ariola et al., 1995)に使用される技術に類似しています。

----
我々は全体を通してBarendregtの変数規約を使用しています。
例えば、３つ目の評価ルールでは、ネストしていないlet束縛で、我々は適切にそれが最終的なｋ的なの項uで捕捉されないようにスコープを変更する変数yをα変換できることを前提としています。

----

図1のタイプの割り当てルールは単純依存型付け規則を定義します。
ラムダ抽象は、依存関数型∀(x:S)Tを持ちます。
これは、LF (Harper et al., 1993)の依存生成物Π(x:S)Tのようなものですが、一般的ではない項である制限変数xは唯一の他の変数をインスタンス化することができます。
型タグは{A : S..U}の形式の型を持ち、Sで下有界がSかつ上有界がUであるAでラベル付けられた型を表します。
一つの特定の型を参照する型タグは{A : T..T}のように、下限と上限を一致させることによって表現されます。
型タグを参照している変数xの型は、型の投影x.Aで取り出すことができます。

----

図1のサブタイプのルールは、先行して`S <: T`型間の（Reful 反射）及び（Trans トランス）のルールを定義します。
彼らは、⊤と⊥最大と最小のタイプ（Top）、（Bot）を明示し、
その下限(<:-Sel)とその上限(Sel-<:)のサブタイプの型の投影のスーパータイプx.Aを作ります。
さらに、標準的な共同/反変サブタイプの関係は、関数型(All-<:-All)とタグ付けされた型(Typ-<:-Typ)のペアの間に導入されました。

----

我々が3章で見るように System D<: は、System F<: をエンコードすることができます。
しかし、 System F<: とは異なり、 System D<: は、型変数を持っていません。
代わりに、`{A = T}` のような型定義は、型 `{A : T..T}` のファーストクラス値です。
依存関数と組み合わせることで、これらの経路依存型は、ポリモーフィズムのような型変数のイディオムを表現することができます。
例えば、System F<: の多型恒等関数は：

	⊢ Λ(α <: ⊤).λ(x : α).x : ∀(α <: ⊤).α → α

であり、System D<:では以下のようになります :


	⊢ λ(a : {A : ⊥..⊤}).λ(x : a.A).x : ∀(a:{A : ⊥..⊤})∀(x:a.A)a.A

-----

System F<: と同様、我々はいくつかの型に多型恒等関数を適用することができるように、Tを用いてT上の恒等関数を取得します：

	⊢ let f =... in let a = {A = T} in f a : ∀(x:T)T

サブタイプの役割は本質的に:

（1）型 `{A：T..T}` の引数は型 `{A:⊥..⊤}`のパラメータを使用することが可能であり、
（2）依存結果型 `∀(x:a.A)a.A` は`T <: a.A <: T` であるため `∀(x:T)T` に変換することができます。