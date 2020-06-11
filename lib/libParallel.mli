type 'a t

(** Create an empty Cucubmer context *)
val empty : 'a t

(** Attach a regular expression and a step definition to a Cucumber
    context.  The step definition should accept three parameters:
    state, regular expression groups captured from the regular
    expression, and any step arguments.  The function should return a
    tuple which has an optional state parameter and an Outcome.t (see
    the Outcome module for more information *)

val _Given : Re.re -> (Re.Group.t option -> Step.arg option -> ('a option * Outcome.t) -> ('a option * Outcome.t) Lwt.t) -> 'a t -> 'a t

val _When : Re.re -> (Re.Group.t option -> Step.arg option -> ('a option * Outcome.t) -> ('a option * Outcome.t) Lwt.t) -> 'a t -> 'a t

val _Then : Re.re -> (Re.Group.t option -> Step.arg option -> ('a option * Outcome.t) -> ('a option * Outcome.t) Lwt.t) -> 'a t -> 'a t

(** Attach a BeforeStep and AfterStep hooks to a Cucumber context. *)
val _Before : (string -> unit Lwt.t) -> 'a t -> 'a t
val _After : (string -> unit Lwt.t) -> 'a t -> 'a t

val set_dialect : Dialect.t -> 'a t -> 'a t
  
val execute : 'a t -> string -> string option -> ('a option * Outcome.t) list
