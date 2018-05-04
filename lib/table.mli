type t

val string_of_table : t -> string
val to_map_with_header : t -> (Base.String.t, Base.String.t list, Base.String.comparator_witness) Base.Map.t
val transform : t -> (Base.String.t Base.List.t -> 'a) -> 'a Base.List.t
val transform_with_header : t -> (string Base.List.t -> string Base.List.t -> 'a) -> 'a Base.List.t
val to_map_with_col_header : t -> (Base.String.t, string list, Base.String.comparator_witness) Base.Map.t
