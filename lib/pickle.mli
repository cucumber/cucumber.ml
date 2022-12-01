(** Module for parsing and running Cucumber feature files.

    This module models the Cucumber Pickle which is returned from the Gherkin parser. 
 *)

type t

(** Load a Gherkin feature file and return [t list]. *)
val load_feature_file : string -> string -> t list 

(** Execute user supplied Before and After hooks. *)
val execute_hooks : (string -> unit) list -> t -> unit

(** Return all steps which are defined for the Pickle. *)
val steps : t -> Step.t list

(** Return the name of the pickle (eg the Scenario name). *)
val name : t -> string

(** Filter pickles so that only the ones supplied by the user are
    executed.  See also [Tag.t] *)
val filter_pickles : (Tag.t list * Tag.t list) -> t list -> t list

