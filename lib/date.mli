type t

val of_string : string -> t
val to_string : t -> string
val of_lexer  : Rfc5322.date_time -> t

val equal     : t -> t -> bool
val pp        : Format.formatter -> t -> unit
