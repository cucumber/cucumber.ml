(** Implementation of Cucumber Localisation.

    In order to allow Gherkin to be written in a number of languages, 
    the keywords have been translated into multiple languages. This module
    allows selection of the dialect to use. 
    See {{: https://cucumber.io/docs/gherkin/languages/}Cucumber Localisation} 
    for more details about the supported languages.
*)

type t =
  Af
| Am
| An
| Ar
| Ast
| Az
| Bg
| Bm
| Bs
| Ca
| Cs
| Cy_GB
| Da
| De
| El
| Em
| En
| En_Scouse
| En_au
| En_LOL
| En_old
| En_pirate
| Eo
| Es
| Et
| Fa
| Fi
| Fr
| Ga
| Gj
| Gl
| He
| Hi
| Hr
| Ht
| Hu
| Id
| Is
| It
| Ja
| Jv
| Ka
| Kn
| Ko
| Lt
| Lu
| Lv
| Mk_Cyrl
| Mk_Latn
| Mn
| Nl
| No
| Pa
| Pl
| Pt
| Ro
| Ru
| Sk
| Sl
| Sr_Cyrl
| Sr_Latn
| Sv
| Ta
| Th
| Tl
| Tlh
| Tr
| Tt
| Uk
| Ur
| Uz
| Vi
| Zh_Cn
| Zh_Tw

val string_of_dialect : t -> string
