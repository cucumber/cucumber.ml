(** The main module used to create a Cucumber instance. *)

(** A cucumber context type which contains a world state type parameter *)
type 'a t

(** Create an empty Cucumber context. *)
val empty : 'a t

(** Attach a regular expression and a step definition to a Cucumber
    context.  The step definition should accept three parameters:
    state, regular expression groups captured from the regular
    expression, and any step arguments.  The function should return a
    tuple which has an optional state parameter and an [Outcome.t] (see
    the {!module-Outcome} for more information. *)
val _Given : Re.re -> ('a option -> Re.Group.t option -> Step.arg option -> ('a option * Outcome.t)) -> 'a t -> 'a t
val _When : Re.re -> ('a option -> Re.Group.t option -> Step.arg option -> ('a option * Outcome.t)) -> 'a t -> 'a t
val _Then : Re.re -> ('a option -> Re.Group.t option -> Step.arg option -> ('a option * Outcome.t)) -> 'a t -> 'a t

(** Attach a BeforeStep hook to a Cucumber context. *)
val _Before : (string -> unit) -> 'a t -> 'a t

(** Attach an AfterStep hook to a Cucumber context. *)
val _After : (string -> unit) -> 'a t -> 'a t

(** Set the human language dialect of a set of feature files. 
    The default is set to English ([Dialect.En]).
 *)
val set_dialect : Dialect.t -> 'a t -> 'a t
  
(** Once the step definitions have been attached to the Cucumber
    context, this executes the step definitions then exits the program
    with an appropriate exit code. *)
val execute: 'a t -> unit

(** This function is a convenience method when a step definition does
    not wish to pass back a state and fail the step. *)
val fail : ('a option * Outcome.t)

(** This function is a convenience method when a step definition does
     not wish to pass back a state and pass the step. *)
val pass : ('a option * Outcome.t)

(** This function is a convenience method when a step definition does
     wish to pass back a state and pass the step. *)
val pass_with_state : 'a -> ('a option * Outcome.t)
