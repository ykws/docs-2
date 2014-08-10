# Typing Haskell in Haskell

http://web.cecs.pdx.edu/~mpj/thih/TypingHaskellInHaskell.html の翻訳

MARK P. JONES

マーク P.ジョーンズ

Pacific Software Research Center 

パシフィック·ソフトウェア·研究センター

Department of Computer Science and Engineering 

コンピュータ理工学科

Oregon Graduate Institute of Science and Technology 

オレゴン科学技術大学院大学

20000 NW Walker Road, Beaverton, OR 97006, USA

mpj@cse.ogi.edu

Version of November 23, 2000.


## Abstract 要約

## 1 Intoroduction はじめに

## 2 Preliminaries 予備知識

## 3  Kinds カインド

## 4  Types 型

## 5  Substitutions 代入

## 6  Unification and Matching 単一化とマッチング

## 7  Type Classes, Predicates and Qualified Types 型クラス, 述語と量化型

### 7.1  Basic Definitions 基本定義

### 7.2  Class Environments クラス環境

### 7.3  Entailment 論理的含意、ならば、派生体?

### 7.4  Context Reduction コンテキストリダクション

## 8  Type Schemes 型スキーム

## 9  Assumptions

## 10  A Type Inference Monad 型推論モナド

## 11  Type Inference 型推論
## 11.1  Literals リテラル
## 11.2  Patterns パターン
## 11.3  Expressions 式
## 11.4  Alternatives Alternative
## 11.5  From Types to Type Schemes 型から型スキーム
## 11.5.1  Ambiguity and Defaults
## 11.6  Binding Groups バインディンググループ
## 11.6.1  Explicitly Typed Bindings
## 11.6.2  Implicitly Typed Bindings
## 11.6.3  Combined Binding Groups
## 11.6.4  Top-level Binding Groups
## 12  Conclusions まとめ
## Acknowledgments　ナレッジメント
## References 参照
## Footnotes: