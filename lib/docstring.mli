type t
   
val string_of_docstring : t -> string       
val transform : t -> (Base.String.t -> 'a) -> 'a
