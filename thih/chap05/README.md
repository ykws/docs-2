# 5  Substitutions 置換

#### Subst

Substitutions-finite functions, mapping type variables to types-play a major role in type inference.

置換有限関数、型変数から型へのマッピング が型推論において主要な役割を果たします。

In this paper, we represent substitutions using association lists:

本論文では、連想リストを使用して置換を表します。

	  type Subst  = [(Tyvar, Type)]

To ensure that we work only with well-formed type expressions, we will be careful to construct only kind-preserving substitutions in which variables are mapped only to types of the same kind.

我々が唯一の整形型の式で動作することを保証するために、私たちは変数が、同じkindの型にマップされている唯一の種類·保存置換を構築するために慎重になります。

#### nullSubst

The simplest substitution is the null substitution, represented by the empty list, which is obviously kind-preserving:

最も単純な置換は、空のリストで表わされるnull代入で、次のとおりに明らかにカインドは保持されます:

	  nullSubst  :: Subst
	  nullSubst   = []

#### (+->)

Almost as simple are the substitutions (u +-> t)3 that map a single variable u to a type t of the same kind:

ほとんど同じ種類の型tに単一の変数uをマップするのと同じくらい簡単な置換(u +-> t)です。

	  (+->)      :: Tyvar -> Type -> Subst
	  u +-> t     = [(u, t)]

This is kind-preserving if, and only if, kind u = kind t.

これは kind u = kind t の場合のみカインドは保持されます。

#### Typesクラス apply, tv

Substitutions can be applied to types-and, in fact, to any other value with type components-in a natural way.

置換は、自然な方法で型に(そして、実際には、型コンポーネントを有する任意の他の値に)適用することができる。

This suggests that we overload the operation to apply a substitution so that it can work on different types of object:

これは、オブジェクトの異なる種類で作業できるように、置換を適用する操作をオーバーロードしていることを示唆している：

	  class Types t where
	    apply :: Subst -> t -> t
	    tv    :: t -> [Tyvar]

In each case, the purpose of applying a substitution is the same: To replace every occurrence of a type variable in the domain of the substitution with the corresponding type.

それぞれの場合において、置換を適用する目的は同じです。対応するタイプの置換ドメイン内の型変数のすべての発生を置き換えるには。

We also include a function tv that returns the set of type variables (i.e., Tyvars) appearing in its argument, listed in order of first occurrence (from left to right), with no duplicates.

また、重複なし​​で（左から右）最初に出現する順にリストを引数に現れる型変数の集合（すなわち、Tyvars）を返す関数tvが含まれる。

#### TypeのTypesインスタンス apply tv

The definitions of these operations for Type are as follows:

次のように型のため、これらの操作の定義は次のとおりです:

	  instance Types Type where
	    apply s (TVar u)  = case lookup u s of
	                         Just t  -> t
	                         Nothing -> TVar u
	    apply s (TAp l r) = TAp (apply s l) (apply s r)
	    apply s t         = t

	    tv (TVar u)  = [u]
	    tv (TAp l r) = tv l `union` tv r
	    tv t         = []

#### Types[a]のTypesインスタンス apply tv

It is straightforward (and useful!) to extend these operations to work on lists:

それは簡単ですリスト上で動作するようにこれらの操作を拡張するために（そして便利！）：


	  instance Types a => Types [a] where
	    apply s = map (apply s)
	    tv      = nub . concat . map tv

The apply function can be used to build more complex substitutions.

apply関数はより複雑な置換を生成するために使う事が出来ます。

#### 使用例

For example, composition of substitutions, satisfying apply (s1 @@ s2) = apply s1 . apply s2, can be defined using:

例えば、置換の合成物は、`apply (s1 @@ s2) = apply s1 . apply s2` を用いて定義することができます。


	  infixr 4 @@
	  (@@)       :: Subst -> Subst -> Subst
	  s1 @@ s2    = [ (u, apply s1 t) | (u,t) <- s2 ] ++ s1

We can also form a 'parallel' composition s1++s2 of two substitutions s1 and s2, but the result is left-biased because bindings in s1 take precedence over any bindings for the same variables in s2.

また、「パラレル」合成s1++s2が2つの置換S1、S2を形成することができますが、s1 でのバインディングが s2 の同じ変数のための任意のバインディングよりも優先されるため、結果は左にバイアスされます。

#### merge

For a more symmetric version of this operation, we use a merge function, which checks that the two substitutions agree at every variable in the domain of both and hence guarantees that apply (s1++s2) = apply (s2++s1).

この操作のより対称バージョンについては、我々はその `apply (s1++s2) = apply (s2++s1)` を2つの置換は、その両方のドメイン内のすべての変数に同意することを確認し、それ故に保証するmerge関数を使用します。

Clearly, this is a partial function, which we reflect by arranging for merge to return its result in a monad, using the standard fail function to provide a string diagnostic in cases where the function is undefined.

明らかに、これは私たちは、関数が定義されていない場合は、診断の文字列を提供するために、関数を失敗する標準を使用して、モナドで、その結果を返すようにマージ配置することにより反映部分関数は、ある。


	  merge      :: Monad m => Subst -> Subst -> m Subst
	  merge s1 s2 = if agree then return (s1++s2) else fail "merge fails"
	   where agree = all (\v -> apply s1 (TVar v) == apply s2 (TVar v))
	                     (map fst s1 `intersect` map fst s2)

It is easy to check that both (@@) and merge produce kind-preserving results from kind-preserving arguments.

これは、ことを確認することは容易である両方（@@）とカインド保持引数から農産物カインド保持結果をマージ。

In the next section, we will see how the first of these composition operators is used to describe unification, while the second is used in the formulation of a matching operation.

次のセクションでは、第二の整合動作の製剤に使用されている間、これらの組成オペレータの最初の、統一を記述するために使用される方法を説明します。
