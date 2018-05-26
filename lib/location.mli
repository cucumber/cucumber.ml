(** Location

    All Gherkin AST records have a location stored.  This module is
    that location information for those.
*)
type t

val string_of_location : t -> string

(** This is to support Tags which are passed in via the command
   line. It will create a default location for a Tag of line: 0 and
   column: 0 *)
val from_command_line : unit -> t
