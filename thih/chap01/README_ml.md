# 1 はじめに

Haskell は最も洗練された型システムを持っていると言語の１つと言えます。
しかし、簡単に作る事は出来ません。Typing Haskell in HaskellではHaskellの型検査をHaskellで記述し、解説する事でよりHaskellの型システムを分かりやすく解説しています。

しかし、Haskellを知らない、あるいは得意ではない人に取ってHaskellで書かれていることはあまり嬉しくありません。
そこで、多くの言語に移植されています。

ここでは、OCamlに移植したバージョンのソースコードを見ながら、
実際にそのコードを使って見る事に重点を置いて、理解を深めていきます。

## モジュール構成

thih.mlのモジュール構成は以下のよう14個のモジュールから構成されています。

- 2 Pre 前提知識
- 2 Id Idの生成
- 3 Kind カインド
- 4 Type 型
- 5 Subst 代入
- 6 Unify 単一化
- 7 Pred 述語と限定型
- 8 Scheme 型スキーム
- 9 Assump 前提条件
- 10 TIMonad 推論用の文脈(状態)
- 11 Infer 型推論の関数の型
- 11.1 Lit リテラル
- 11.2 Pat パターン
- 11.3 TIMain 型推論のメイン処理

Preは基礎的な話です。
Id,Typeは型を扱うのに必要な概念です。
Unify,Substは型推論のプログラムを作る為の概念です。
Schemeは多相的な型推論をする場合に必要となる概念です。

Kind,Pred,Qual,AssumpがHaskellの型システムを特徴付ける概念で、特に難しい所でしょう。

TIMonadは破壊的な代入が出来る大域変数を表す物に過ぎません。
Infer以降はこれまで作った部品を組み合わせて実際に型推論するわけです。

## 様々な概念について

ここから、いくつかの概念について説明します。

### Pre

基本的なList操作等を作成しています。例えば集合の和や積、差分等の計算の定義です。

### Id

Idは識別子の型を定義し、名前を作ります。

### Type

Typeは型です。

型推論をする場合は、プログラム上で型を表す型を定義して扱う必要が出てきます。
プリミティブな型や、型を作る型であるコンストラクタや
型を変数として表す、型変数等があります。

### パターンマッチとUnify

Unifyは単一化と呼ばれる概念です。

パターンマッチは、左から右への一方通行の計算です。

	a=1
	b=a
	c=b

のとき、cはいくつですかという問題はパターンマッチで解けます。

単一化は右から左へも戻る事が出来ます。

	a=1
	a=b
	b=c

のときに、cはいくつですかという問題を説く事が出来ます。

todo: unifyとからめてもっとわかりやすく

### Subst

Substは型推論での代入を表すオブジェクトを定義し、代入の操作についての処理も定義しています。
単一化の計算をする時は、要するに、どれとどれが同じだというリストを保存しなくては行けません。
どれがどれだという物がSubstです。

todo: unifyとからめてもっとかく。

###  Scheme


	add a b = a + b
	c = add 1 2
	d = add "a" "b"

という式があった場合に、addの型は int -> int -> int または string -> string -> stringです。
'a -> 'a -> 'aという型がaddに割り当てられるべきでしょう。
これを表すのがTypeSchemeです。add 1 2を見つけたときに、add 1 2の型はタイプスキームから型
a' -> a' -> a'を取得して、b'->b'->b'を割り当てます。そして、1の型 intとb'の単一化をして、int -> int -> intと推論します。
しかし、型スキーム内の'aは'bではないので変わりません。
次に、add "a" "b"を見つけたらまた、型スキームからaddの型 a' -> a' -> a'を取り出し、c' -> c' -> c'を作ります。そして、c'とstringを単一化して、string -> string -> stringを求めます。
このようにする為の仕組みが型スキームです。

### Kind

Kindは型の種類を表すカインドを定義します。

例)

IntのKindは\*です。
CharのKindも\*です。
ListのKindは\*->\*で
List\[Char\]のKindは\*です。
Function\[A,B\]a->b のKindは\*->\*->\*で Int->IntのKindは\*です。

### Pred

Predは述語(Pred)です。

Num a => a -> a -> a

これの => の左側の部分の要素となるものです。
述語ってなんだよ？っていうと集合論の関数みたいな奴ですけど。詳しくは7.1を見てください。

todo: もっとかく

### Qual

Qualは制限型です。

Num a => a -> a -> a

のような物を表す為の物です。詳しくは7.1を見てください。
aはNumである事を制限するといった事が出来るわけです。

todo:もっとかく

### クラス環境 classEnv

どんなクラスがあるかを表す環境です。

todo:もっとかく

### Assump

Assumpでは前提条件とその操作

AssumpはSchemeに名前を付けた物です。
Schemeは1つしかなくて、名前もついていません。
AssumpのリストとしてSchemeのリストを作る事で、複数のSchemeを名前から引く事が出来るようになります。

todo:もっとかく

### TIMonad

TIMonadでは型推論時の環境tiの定義と操作

todo:もっとかく
