module Pre = struct
  (* 和集合 *)
  let union (xs: 'a list) (ys: 'a list):'a list =
    List.filter begin fun x ->
      not (List.mem x ys)
    end xs @ ys

  (* 積集合 *)
  let intersect (xs: 'a list) (ys: 'a list): 'a list =
    List.filter begin fun x ->
      List.mem x ys
    end xs

  (* リストをセットにする。要素が１つずつにまとめる *)
  let nub (xs : 'a list): 'a list =
    List.fold_left begin fun ys y ->
      if List.mem y ys
      then ys
      else y :: ys
    end [] xs

  let show_list show sep xs =
    begin
      let rec loop xs =
        begin match xs with
          | [] -> ""
          | [x] -> show x
          | x::xs -> show x ^ sep ^ loop xs
        end
    in
      Printf.sprintf "[%s]" (loop xs)
    end
  let show_int_list xs =
    show_list string_of_int "; " xs
end

module Id = struct
  type id = string

  (* 数値に対するidを取得する *)
  let enumId (n:int) : id =
    "v" ^ string_of_int n
end

(* 3 Kinds *)
module Kind = struct
  type kind =
    | Star
    | Kfun of kind * kind

  let rec show (k:kind):string =
    begin match k with
      | Star -> "*"
      | Kfun(Kfun _ as k1,k2) -> Printf.sprintf "(%s) -> %s" (show k1) (show k2) 
      | Kfun(k1,k2) -> Printf.sprintf "%s -> %s" (show k1) (show k2) 
    end

end

(* 4 Types *)
module Type = struct
  open Kind
  (* 型変数 *)
  type tyvar = Tyvar of Id.id * kind
  (* 型コンストラクタ *)
  type tycon = Tycon of Id.id * kind
  (* 型 *)
  type type_ =
    | TVar of tyvar
    | TCon of tycon
    | TAp of type_ * type_
    | TGen of int

  let tUnit :type_ = TCon(Tycon("()", Star))
  let tChar :type_ = TCon(Tycon("Char", Star))
  let tInt :type_ = TCon(Tycon("Int", Star))
  let tInteger :type_ = TCon(Tycon("Integer", Star))
  let tFloat :type_ = TCon(Tycon("Float", Star))
  let tDouble :type_ = TCon(Tycon("Double", Star))

  let tList :type_ = TCon(Tycon("[]", Kfun(Star, Star)))
  let tArrow :type_ = TCon(Tycon("(->)", Kfun(Star, Kfun(Star, Star))))
  let tTuple2 :type_ = TCon(Tycon("(,)", Kfun(Star, Kfun(Star, Star))))

  let fn (a:type_) (b:type_) :type_ = TAp(TAp(tArrow, a), b)

  let list t :type_ = TAp(tList, t)

  let tString :type_ = list tChar

  let pair a b :type_ = TAp(TAp(tTuple2, a), b)

  let tyvarKind (Tyvar(_, k)) :kind = k
  let tyconKind (Tycon(_, k)) :kind = k
  let rec typeKind t:kind =
    match t with
    | TCon tc -> tyconKind tc
    | TVar u -> tyvarKind u
    | TAp(t, _) ->
      begin match typeKind t with
        | Kfun(_, k) -> k
        | _ -> failwith "inconsistent type"
      end
    | TGen _ -> failwith "generic type variables have no kind"

  let rec show (t:type_): string =
    begin match t with
      | TVar(Tyvar(id,kind)) -> Printf.sprintf "TVar(Tyvar(%s,%s))" id (Kind.show kind)
      | TCon(Tycon(id,kind)) -> Printf.sprintf "TCon(Tycon(%s,%s))" id (Kind.show kind)
      | TAp(t1,t2)           -> Printf.sprintf "TAp(%s,%s)" (show t1) (show t2)
      | TGen(i)              -> Printf.sprintf "TGen(%d)" i
    end
end

(* 5 Substitutions *)
module Subst = struct
  open Type

  type subst = (tyvar * type_) list

  let nullSubst : subst = []

  let (+->) u t : subst = [(u, t)]

  (* 型変数を展開する *)
  let rec typeApply (s : subst) (t:type_):type_ = 
    begin match t with
      | TVar u as t ->
        begin try
          List.assoc u s
        with
          Not_found -> t
        end
      | TAp(l, r) -> TAp(typeApply s l, typeApply s r)
      | t -> t
    end

  let rec typeTv (t:type_):tyvar list =
    begin match t with
      | TVar u -> [u]
      | TAp(l, r) -> Pre.union (typeTv l) (typeTv r)
      | _ -> []
    end

  let listApply (apply : subst -> 'a -> 'b) (s : subst) (xs:'a list):'b list =
    List.map (apply s) xs

  let listTv (tv:'a -> tyvar list) (xs:'a list) : tyvar list =
    Pre.nub (List.concat (List.map tv xs))

  let (@@) (s1:subst) (s2 : subst) : subst =
    List.map begin fun (u, t) ->
      (u, typeApply s1 t)
    end s2 @ s1

  let merge s1 s2 : subst =
    let agree =
      let agreeOnVar v =
        typeApply s1 (TVar v) = typeApply s2 (TVar v)
      in
      List.for_all agreeOnVar (Pre.intersect (List.map fst s1) (List.map fst s2))
    in
    if agree
    then s1 @ s2
    else failwith "substitutions do not agree"

  let show (subst:subst):string =
    Pre.show_list begin fun (Tyvar(id,kind),type_) ->
      Printf.sprintf "Tyvar(%s,%s),%s" id (Kind.show kind) (Type.show type_)
    end "; " subst

  let show_tyvar_list xs :string =
    Pre.show_list begin fun (Tyvar(id,kind)) ->
      Printf.sprintf "Tyvar(%s,%s)" id (Kind.show kind)
    end "; " xs
end

(* 6 Unification and Matching *)
module Unify = struct
  open List
  open Kind
  open Type
  open Subst
  
  let rec mgu (t1:type_) (t2:type_):subst =
    match t1, t2 with
    | TAp(l, r), TAp(l', r') ->
      let s1 = mgu l l' in
      let s2 = mgu (typeApply s1 r) (typeApply s1 r') in
      s2 @@ s1
    | TVar u, t | t, TVar u -> varBind u t
    | TCon tc1, TCon tc2 when tc1 = tc2 -> nullSubst
    | _ -> failwith "types do not unify"

  and varBind (u:tyvar) (t:type_):subst =
    if t = TVar u then nullSubst
    else if mem u (typeTv t) then failwith "occurs check fails"
    else if tyvarKind u <> typeKind t then failwith "kinds do not match"
    else u +-> t

  let rec match_ (t1:type_) (t2:type_):subst =
    match t1, t2 with
    | TAp(l, r), TAp(l', r') ->
      let sl = match_ l l' in
      let sr = match_ r r' in
      merge sl sr
    | TVar u, t when tyvarKind u = typeKind t -> u +-> t
    | TCon tc1, TCon tc2 when tc1 = tc2 -> nullSubst
    | _ -> failwith "types do not match"

  let _ =
    (* mgu *)
    let t1 = TVar(Tyvar("a", Star)) in
    let t2 = TVar(Tyvar("b", Star)) in
    let subst = mgu t1 t2 in
    Printf.printf "mgu subst=%s\n" (Subst.show subst);
    (* varBind *)
    let tv1 = Tyvar("a", Star) in
    let subst = varBind tv1 t1 in
    Printf.printf "varBind subst=%s\n" (Subst.show subst);
    (* match_ *)
    let subst = match_ t1 t2 in
    Printf.printf "match subst=%s\n" (Subst.show subst);
    ()
end

