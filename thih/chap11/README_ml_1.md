## 11.1 Lit モジュール

リテラルの型推論をするモジュールです。

	(* 11.1 Literals *)
	#load "nums.cma"
	module Lit = struct
	  open Kind
	  open Type
	  open Pred
	  open TIMonad
	  open Infer
	  open Big_int
	  open Num
	  ...
	end

ここでは、1つの型literalと1つの関数tiLitを読みます。

### type literal

リテラルには、Int,Char,Rat,Strがあります。Ratは浮動小数点数です。

	  type literal =
	    | LitInt of big_int
	    | LitChar of char
	    | LitRat of num
	    | LitStr of string

### tiLit 関数

	  let tiLit (ti:ti) (lit:literal):pred list * type_ =
	    begin match lit with
	      | LitChar _ -> ([], tChar)
	      | LitInt _ ->
	        let v = newTVar ti Star in
	        ([IsIn("Num", v)], v)
	      | LitStr _ -> ([], tString)
	      | LitRat _ ->
	        let v = newTVar ti Star in
	        ([IsIn("Fractional", v)], v)
	    end

これがリテラルの型推論関数です。
リテラルの型推論は、基本的にはリテラル値を受け取れば求まります。
tiから新しい型変数をLitInt,LitRatのときは作成しています。

整数は、新しい型変数vでNum クラスのインスタンスなので v であることを示すために述語と共に返します。

浮動小数点も整数と同様に推論します。

#### 使用例

	  let _ =
	    runTI begin fun ti ->
	      let lit = LitInt (big_int_of_string "123") in
	      let (preds,ty) = tiLit ti lit in
	      Printf.printf "preds = %s ty = %s\n" (Pred.ps preds) (Type.show ty)
	    end
