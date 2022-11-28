(** Module implementing Cucumber Tags.

    Tags are a great way to organise your features and scenarios.

    They can be used for two purposes:
    {ul {- Running a subset of scenarios}
        {- Restricting hooks to a subset of scenarios}
    }
 *)

type t

(** Create a string from a Tag. *)
val string_of_tag : t -> string

(** Compare two tags for equality. *)
val compare : t -> t -> bool

(** Given a list of tags as a string, return a tuple representing
   the allowed and disallowed tags.  

   These are set by the command line argument --tags and
   primarily used to filter pickles during runtime. *)  
val list_of_string : string -> (t list * t list)
