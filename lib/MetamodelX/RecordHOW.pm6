use v6.d;
use annotations::containers;
use annotations::how;
my atomicint $ID = 1;
unit role MetamodelX::RecordHOW[::F, ::D]
     does MetamodelX::AnnotationHOW[Buffer, Metamodel::ClassHOW];

#|[ The type of field. ]
method for(::?ROLE:_: Mu $?) is raw { F }

#|[ A class to which to delegate method calls. ]
method delegate(::?ROLE:_: Mu $?) is raw { D }

method new_type(::?ROLE:_: F(Mu) $fields is raw, D $template? is raw, :$name, *%rest) is raw {
    my uint $id = !$name.DEFINITE && $ID⚛++;
    my $obj := callwith :name($id ?? "<anon record $id>" !! $name), |%rest;
    my $how := $obj.HOW;
    $how.ANN = $id, $template, $fields;
    $how.add_parent: $obj, $template;
    $obj
}

#|[ Ensures that an MRO-based type_check not be called. ]
method publish_type_cache(::?ROLE:D: Mu $obj is raw) is raw {
    use nqp;
    my $result := callsame;
    nqp::settypecheckmode($obj.WHAT,
      nqp::const::TYPE_CHECK_CACHE_DEFINITIVE);
    $result
}

#|[ A number of annotations we promise to keep via this specific HOW.
    MROish; typically called with .* dispatch. ]
method annotations(::?ROLE:_: $? --> 3) { }

#|[ A position for a list of annotations for this metaobject.
    Depending on this in a subtype requires an annotations offset to skip. ]
method annotation_offset(::?ROLE:_: Mu $obj? is raw --> Int:D) {
    self.*annotations($obj).skip.sum
}

#|[ The fields defining this record type. ]
method fields(::?ROLE:D: Mu $obj is raw) {
    self.ANN[2]<>
}

#|[ An origin for this record; should be the delegate by default. ]
method template(::?ROLE:D: Mu $obj is raw) is raw {
    self.ANN[1]<>
}

#|[ An ID given to anonymous records. ]
method anonymous_id(::?ROLE:D: Mu $obj is raw --> uint) {
    self.ANN[0]<>
}

#|[ Whether or not this is an anonymous record. ]
method is_anonymous(::?ROLE:D: Mu $obj? is raw --> Bool:D) {
    ?self.anonymous_id($obj)
}
