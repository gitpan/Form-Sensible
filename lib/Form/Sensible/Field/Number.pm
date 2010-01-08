package Form::Sensible::Field::Number;

use Moose; 
use namespace::autoclean;
extends 'Form::Sensible::Field';

has 'integer_only' => (
    is          => 'rw',
    isa         => 'Bool',
    required    => 1,
    default     => 0,
);

has 'lower_bound' => (
    is          => 'rw',
    isa         => 'Num',
    required    => 0,
);

has 'upper_bound' => (
    is          => 'rw',
    isa         => 'Num',
    required    => 0,
);

has 'step' => (
    is          => 'rw',
    isa         => 'Num',
    required    => 0,
);


sub validate {
    my ($self) = @_;
    
    if (defined($self->lower_bound) && $self->value < $self->lower_bound) {
        return $self->display_name . " is lower than the minimum allowed value";
    }
    if (defined($self->upper_bound) && $self->value > $self->upper_bound) {
        return $self->display_name . " is higher than the maximum allowed value";
    }
    if ($self->integer_only && $self->value != int($self->value)) {
        return $self->display_name . " must be an integer.";
    }
    
    ## we ran the gauntlet last check is to see if value is in step.
    if (defined($self->step) && !$self->in_step()) {

        return $self->display_name . " must be a multiple of " . $self->step;
    }
}


## this is used when generating a slider or select of valid values.
sub get_potential_values {
    my ($self, $step, $lower_bound, $upper_bound) = @_;
    
    if (!$step) {
        $step = $self->step || 1;
    } 
    if (!defined($lower_bound)) {
        $lower_bound = $self->lower_bound;
    }
    if (!defined($upper_bound)) {
        $upper_bound = $self->upper_bound;
    }
    
    my $value = $lower_bound;
    
    ## this check ensures that we start with a value that is within our
    ## bounds.  If $self->lower_bound does not lie on a step boundry, 
    ## and we generated all our numbers from lower_bound, we would be
    ## producing a bunch of options that were always invalid. 
    ## Technically speaking, we shouldn't have a lower bound that is invalid
    ## but who are we kidding?  It will happen.
    
    if (!$self->in_step($lower_bound, $step)) {
        # lower bound doesn't lie on a step boundry.  Bump $div by 1 and 
        # multiply by step.  Should be the first value that lies above our
        # provided bound.
        my $div = $value / $step;
        
        $value = (int($div)+1) * $step;
    }
    
    my @vals;
    while ($value <= $upper_bound) {
        push @vals, $value;
        $value+= $step;
    }
    return @vals;
}

## this allows a number to behave like a Select if used that way.
sub options {
    my ($self) = @_;
    
    return [ map { { name => $_, value => $_ } } $self->get_potential_values() ];
}

sub accepts_multiple {
    my ($self) = @_;
    
    return 0;
}

sub in_step {
    my ($self, $value, $step) = @_;
    
    if (!$step) {
        $step = $self->step;
    }
    if (!defined($value)) {
        $value = $self->value;
    }
    
    ## we have to do the step check this way, because % will not deal with
    ## a fractional step value.
    my $div = $value / $step;
    return ($div == int($div));
    
}

sub get_additional_configuration {
    my $self = shift;
    
    my $result_hash = {};
    foreach my $field (qw/step lower_bound upper_bound integer_only/) {
        if (defined($self->$field())) {
            $result_hash->{$field} = $self->$field();
        }
    }
    return $result_hash;
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Form::Sensible::Field::Number - A Numeric field type.

=head1 SYNOPSIS

    use Form::Sensible::Field::Number;
    
    my $object = Form::Sensible::Field::Number->new( 
                                                        integer_only => 1,
                                                        lower_bound => 10,
                                                        upper_bound => 100,
                                                        step => 5,
                                                    );

    $object->do_stuff();

=head1 DESCRIPTION

The number field type is one of the more advanced 
field types in Form::Sensible. It has a number of features for
dealing specifically with numbers.  It can be set to have a lower and
upper bound, allowing validation to ensure that the value selected is
within a range.  It can also be set to have a 'step', which provides a
constraint to what values are valid between the upper and lower bounds.
It can also be made to accept integers only, or fractional values.  

Finally, it can be rendered in a number of ways including select boxes,
drop downs or even ranged-sliders if your renderer supports it.

=head1 ATTRIBUTES

=over 8

=item C<'integer_only'> has
=item C<'lower_bound'> has
=item C<'upper_bound'> has
=item C<'step'> has

=back 

=head1 METHODS

=over 8

=item C<validate> sub
=item C<get_potential_values> sub
=item C<options> sub
=item C<in_step> sub
=item C<get_additional_configuration> sub

=back

=head1 AUTHOR

Jay Kuri - E<lt>jayk@cpan.orgE<gt>

=head1 SPONSORED BY

Ionzero LLC. L<http://ionzero.com/>

=head1 SEE ALSO

L<Form::Sensible>

=head1 LICENSE

Copyright 2009 by Jay Kuri E<lt>jayk@cpan.orgE<gt>

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
