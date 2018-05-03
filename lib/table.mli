type t

val string_of_table : t -> string
val to_map_with_header : t -> (Base.String.t, string list, Base.String.comparator_witness) Base.Map.t
val transform : t -> (string Base.List.t -> 'a) -> 'a Base.List.t
