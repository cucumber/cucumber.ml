(** Pickle
    This module models the Cucumber Pickle which is returned from the Gherkin parser. 
 *)
type t

(** load a Gherkin feature file and return a list of Pickles*)
val load_feature_file : string -> t list 
(** execute user supplied Before and After hooks *)
val execute_hooks : (string -> unit) list -> t -> unit

(** return all steps which are defined for the Pickle *)
val steps : t -> Step.t list
(** return the name of the pickle (eg the Scenario name) *)
val name : t -> string
(** filter pickles so that only the ones supplied by the user are
    executed.  See also the Tag module *)
val filter_pickles : (Tag.t list * Tag.t list) -> t list -> t list

