type t = {
    location : Location.t;
    name : string;
  }

let create_from_command_line name =
  { location = (Location.from_command_line ()) ;
    name = name
  }

let string_of_tag tag =
  let loc_str = Location.string_of_location tag.location in
  "\ntag name : " ^ tag.name ^ "\n" ^ loc_str

let compare t1 t2 =
  t1.name = t2.name

let strip_not_from_tag_name str_lst =
  Base.List.map str_lst ~f:(Base.String.strip ~drop:(fun c -> Base.Char.equal c '~'))

let filter_disallowed_tags str_lst =
  strip_not_from_tag_name (Base.List.filter str_lst ~f:(Base.String.is_prefix ~prefix:"~"))

let filter_allowed_tags str_lst =
  Base.List.filter str_lst ~f:(fun str -> not (Base.String.is_prefix str ~prefix:"~"))

let match_spaces = (Re.Perl.compile_pat "[\t ]+")

let list_of_string str_lst =
  let tags_str_lst = Re.split match_spaces str_lst in
  let disallowed_tags_str = filter_disallowed_tags tags_str_lst in
  let allowed_tags_str = filter_allowed_tags tags_str_lst in
  let allowed_tags = Base.List.map allowed_tags_str ~f:(create_from_command_line) in
  let disallowed_tags = Base.List.map disallowed_tags_str ~f:(create_from_command_line) in
  (allowed_tags, disallowed_tags)


