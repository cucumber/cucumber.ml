(** Tags
    This module implements Cucumber Tags.
    
 *)

type t

val string_of_tag : t -> string

(** Compare two tags for equality *)
val compare : t -> t -> bool

(** Given a list of tags as a string, this will return a tuple which
   represents the allowed and disallowed tags.  These are set by the
   command line argument --tags.  This is primarily used to filter
   pickles during runtime. *)  
val list_of_string : string -> (t list * t list)
