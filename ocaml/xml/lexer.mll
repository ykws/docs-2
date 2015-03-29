{
open Parser
}

let space = [' ' '\t']
let identchar = ['A'-'Z' 'a'-'z' '_' '0'-'9' ':' '-']

rule token = parse
  | '<' (['a'-'z'] ['a'-'z' '0'-'9']* as s) space*
    {
      match attributes lexbuf with
      | l,false -> START(s, l)
      | l,true -> SINGLE(s, l)
    }
  | "</" (['a'-'z'] ['a'-'z' '0'-'9']* as s) '>' { STOP s }
  | "<!--" as s { let c = comment lexbuf in Printf.printf "%s\n" c; COMMENT (s ^ c) }
  | [^ '>' '<']+ as s { STR s }
  | eof { EOF }

and attributes = parse
  | '>' { [], false }
  | "/>" { [], true }
  | (identchar+ as a) space* '=' space* '"' (([^ '"' '\\'] | '\\' ['"' '\''])* as s) '"' space*
    {
      let l,r = attributes lexbuf in
      ((a,s)::l,r)
    }
and comment = parse
  | "-->" as s { Printf.printf "comment end\n";s }
  | _ as s { Printf.printf "comment\n";(String.make 1 s) ^ (comment lexbuf) }
  | eof { assert false }