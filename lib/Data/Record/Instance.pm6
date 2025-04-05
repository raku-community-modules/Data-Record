use v6.d;
use Data::Record::Exceptions;
unit role Data::Record::Instance[::T];

proto method new(::?ROLE:_: |)                               {*}
# multi method new(::?ROLE:_: T)                             { ... }
# multi method new(::?ROLE:_: T, Bool:D :$consume! where ?*) { ... }
# multi method new(::?ROLE:_: T, Bool:D :$subsume! where ?*) { ... }
# multi method new(::?ROLE:_: T, Bool:D :$coerce! where ?*)  { ... }

#|[ Wraps a data structure, typechecking it to ensure it matches this record
    type. This is done recursively for record type fields.
    This will die with X::Data::Record::Missing if any fields are missing from
    the data structure, and X::Data::Record::Extraneous if any extraneous fields
    exist within it. ]
method wrap(::?ROLE:_: T --> T) { ... }

#|[ Consumes a data structure, stripping any extraneous fields so it matches
    this record type. This is done recursively for record type fields.
    This will die with X::Data::Record::Missing if any fields are missing from
    the data structure. ]
method consume(::?ROLE:_: T --> T) { ... }

#|[ Subsumes a data structure, filling out any missing fields if possible so
    it matches this record type. This is done recursively for record type
    fields.
    This will die with X::Data::Record::Extraneous if any extraneous fields
    exist within the data structure. ]
method subsume(::?ROLE:_: T --> T) { ... }

#|[ Coerces a data structure, both consuming any extraneous fields and filling
    out any missing fields if possible. This is done recursively for record
    type fields. ]
method coerce(::?ROLE:_: T --> T) { ... }

#|[ The data structure type that this record wraps. ]
method for(::?ROLE:_: --> Mu) { T }
#|[ The fields of this record. ]
method fields(::?ROLE:_: --> T) { ... }

#|[ Returns this record's wrapped data as is. ]
method record(::?ROLE:D: --> T)   { ... }
#|[ Returns this record's wrapped data, recursively unwrapping any records found within it. ]
method unrecord(::?ROLE:D: --> T) { ... }

multi method gist(::?CLASS:D: --> Str:D) { self.record.gist }

# multi method raku(::?CLASS:U: --> Str:D) { ... }
multi method raku(::?CLASS:D: --> Str:D) { self.^name ~ '.new(' ~ self.record.raku ~ ')' }

proto method ACCEPTS(Mu: Mu) {*}
multi method ACCEPTS(::?ROLE:U: T --> True) { }
multi method ACCEPTS(::?ROLE:_: Mu --> False) { }
multi method ACCEPTS(::?CLASS:_: ::?CLASS:_ \topic) { self.WHAT =:= topic.WHAT }

#|[ Handles an operation on a field of the record given a callback accepting a
    value to perform the operation with. Typechecking and coercion of data
    structures to records is handled before passing the value to the callback. ]
method !field-op(
    ::?ROLE:_:
    Str:D  $operation,
           &op         is raw,
    Mu     $field      is raw,
    Mu     $value      is raw,
          *%named-args
    --> Mu
) is raw #`[is DEPRECATED] {
    if $field ~~ Data::Record::Instance {
        if $value ~~ Data::Record::Instance {
            if $value.DEFINITE {
                op $value ~~ $field
                ?? $value
                !! $field.new: $value.record, |%named-args
            } else {
                X::Data::Record::TypeCheck.new(
                    operation => $operation,
                    expected  => $field,
                    got       => $value,
                ).throw;
            }
        } elsif $value ~~ $field.for {
            op $field.new: $value, |%named-args
        } else {
            X::Data::Record::TypeCheck.new(
                operation => $operation,
                expected  => $field,
                got       => $value,
            ).throw;
        }
    } elsif $value ~~ $field {
        op $value
    } else {
        X::Data::Record::TypeCheck.new(
            operation => $operation,
            expected  => $field,
            got       => $value,
        ).throw;
    }
}
