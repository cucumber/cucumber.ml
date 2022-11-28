(** A type representing a location within a Gherkin feature file. *)

type t

(** Pretty print a string from a [t]. *)
val string_of_location : t -> string

(** This is to support Tags which are passed in via the command
   line. It will create a default location for a Tag of line: 0 and
   column: 0 *)
val from_command_line : unit -> t
