(** Datatables
    
    This module implements Cucumber Datatables.  For instance:

    Given the following users exist:
    | name   | email              | twitter         |
    | Aslak  | aslak@cucumber.io  | @aslak_hellesoy |
    | Julien | julien@cucumber.io | @jbpros         |
    | Matt   | matt@cucumber.io   | @mattwynne      |
*)

type t

val string_of_table : t -> string

(** Returns a Base.Map.t with the first row as the key values and the column values
   as a list which is returned when the key value is given. *)
val to_map_with_header : t -> (Base.String.t, Base.String.t list, Base.String.comparator_witness) Base.Map.t

(** Applies a user supplied function to each row which is supplied to
    the function as a list of strings. *)
val transform : t -> (Base.String.t Base.List.t -> 'a) -> 'a Base.List.t

(** Applies a user supplied function to each row after the first.  The
   first row is assumed to be the header row and is supplied to the
   user's function for each row.
 *)
val transform_with_header : t -> (Base.String.t Base.List.t -> Base.String.t Base.List.t -> 'a) -> 'a Base.List.t

(**
   Returns a Base.Map.t with the first column as the key values with the rest of the column values
   stored as list.
 *)
val to_map_with_col_header : t -> (Base.String.t, Base.String.t list, Base.String.comparator_witness) Base.Map.t
