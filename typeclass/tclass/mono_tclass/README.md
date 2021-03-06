# 単相型推論+型クラス

単相型システムの型推論器に型クラスを導入する事を考えましょう。
単相型システムでは、関数や変数の型は１つに決定できます。
オーバーロードされた値も型は１つに決定できます。
オーバーロードされた値が表れた場合、辞書を参照するように式を置き換えます。

式を置き換える必要があるので、型推論器は、型を推論しつつ、式も返すように変更するように式も返すように変更します。

オーバーロードされた関数が表れた場合には、型から辞書を選択する式へ変換する処理を追加するのですが、
型推論のトラバース中は型が決定されているとは限りません。例えば以下の式、

	let a = add in
	a 1 2

のトラバース中にa=addの束縛を行った時点でaの型や、addの型は決定されていません。
そのため型推論時にはプレースホルダadd[t]に置き換えます。

以下のように型推論時に、式を変換します:

型推論中:

	let (a:(t1=t2->t2->t2)) = (add[t2]:t2->t2->t2) in
	(a:(t1=int->int->t3) (1:int) (2:int):t3)

	t1 = t2->t2->t2
	t1 = int->int->t3
	t2 = int
	t3 = t2

型推論終了後:

	let a = add[t2] in
	a 1 2


t2は型推論後に、t2を代入すると以下のように型を決定出来ます:

	let a = add[int] in
	a 1 2

add[int]をadd num\_intに置き換えます:
			
	let a = add num_int in
	a 1 2

変数がオーバーロードされた値だった場合、型クラスの辞書を値へ受け渡します。
型クラスの環境は、多相的に拡張する場合でも動作するような事を考えて、型推論器のパラメータとして引き渡します。
実装は2パスで行えます。
１パス目では型推論と同時に式の変換を行います。
２パス目では型推論が推論した型情報のリンクをなくしてプレーンな型に変換しつつ、プレースホルダを置き換えます。

### let, let rec

再帰的に変数を用いる事ができるlet recは、束縛変数に新しい型変数を割り当ててから推論します。
letや、let rec、funでバインドされる変数は必ず決定出来ます。

## 参考文献

Implementing Type Classes