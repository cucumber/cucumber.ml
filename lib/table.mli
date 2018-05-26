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

(**
   Returns a Base.Map.t with the first column as the key values with the rest of the column values
   stored as list.
 *)
val to_map_with_col_header : t -> (Base.String.t, Base.String.t list, Base.String.comparator_witness) Base.Map.t

(** Applies a user supplied function to each row which is supplied to
    the function as a list of strings. *)
val transform : t -> (Base.String.t Base.List.t -> 'a) -> 'a Base.List.t

(** Applies a user supplied function to each row after the first.  The
   first row is assumed to be the header row and is supplied to the
   user's function for each row. For instance,
    | a | 1 | 2 | 3 |
    | b | 4 | 5 | 6 |
    | c | 7 | 8 | 9 |

   will be supplied to the user's function such that

   1:4,7
   2:5,8
   3:6,9
   a:b,c

 *)
val transform_with_header : t -> (Base.String.t Base.List.t -> Base.String.t Base.List.t -> 'a) -> 'a Base.List.t

(** Applies a user supplied function to the datatable with the first column used as the header.
    For instance,
    | a | 1 | 2 | 3 |
    | b | 4 | 5 | 6 |
    | c | 7 | 8 | 9 |

    This table will be given to the function as:
    a:1,2,3
    b:4,5,6
    c:7,8,9

    where a,b,c will be given as the first parameter then the rest of the row will be supplied as a
    list.
 *)
val transform_with_col_header : t -> (string -> string Base.List.t -> 'a) -> 'a Base.List.t
