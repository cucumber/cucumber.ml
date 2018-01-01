type arg = DocString of Docstring.t | Table of Table.t  | Empty

type t = {
    locations : Location.t list;
    text : string;
    argument : arg
  }    

val string_of_arg : arg -> string
val string_of_step : t -> string
