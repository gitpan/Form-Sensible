package Form::Sensible::Field::SubForm;

use Moose; 
use namespace::autoclean;
extends 'Form::Sensible::Field';

has 'form' => (
    is          => 'rw',
    isa         => 'Form::Sensible::Form',
    required    => 1,
);

sub BUILDARGS {
    my $class = shift;
    
    my $args = $_[0];
    if (!ref($args)) {
        $args = { @_ };
    }
    
    ## could probably do this with some sort of coersion - not sure if I want to though.
    if (ref($args->{'form'}) eq 'HASH') {
        $args->{'form'} = Form::Sensible->create_form($args->{'form'});
    }
    return $class->SUPER::BUILDARGS($args);
}

sub BUILD {
    my $self = shift;
    
    if (!exists($self->form->render_hints->{'form_template_prefix'})) {
        $self->form->render_hints->{'form_template_prefix'} = 'subform';
    } 
}

sub get_additional_configuration {
    my ($self, $template_only) = @_;
    
    return { 
                'form' => $self->form->flatten($template_only),
           };

}

sub validate {
    my ($self) = shift;

    return $self->form->validate();    
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Form::Sensible::Field::SubForm - encapsulate an entire form within another.

=head1 SYNOPSIS

    use Form::Sensible::Field::SubForm;
    
    my $object = Form::Sensible::Field::SubForm->new( form => $otherform );

    $object->do_stuff();

=head1 DESCRIPTION

The subform field type allows you to embed one form within another.  The fields
in the subform are submitted and validated as though they belong to the primary
form.  Please note that this feature is experimental at best and how it is 
used is still subject to change.  


=head1 Attributes

=over 8

=item C<'form'>

The sub-form to render at this field's position.

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