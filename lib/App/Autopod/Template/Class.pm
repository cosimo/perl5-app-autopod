package App::Autopod::Template::Class;

use strict;
use warnings;
use IO::Scalar;

sub priority {
    return 200;
}

# Determines if the current plugin can be used
# with the desired file or content
sub is_applicable {
    my ($self, $filename, $content) = @_;

    if ($filename !~ m{.+\.[pP][mM]$}) {
        return 0;
    }

    if ($content !~ m{^package \s+ \S+}ms) {
        return 0;
    }

    return 1;
}

sub as_filehandle {
    my $content = content();
	return IO::Scalar->new(\$content);
}

sub as_string {

	my $content = q~
=pod

=head1 NAME

__CLASS__ - My shiny new class FTW FTW!

=head1 SYNOPSIS

Fill in the synopsis of __CLASS__

=head1 DESCRIPTION

Fill in the description of __CLASS__ 

=head1 SUBROUTINES/METHODS

=head2 AUTOGENERATED FUNCTIONS

XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
You have to move the following functions to class or instance sections
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

__FUNCTIONS__

=head2 CLASS METHODS

=head3 C<new( [\%args] )>

Class constructor. Describe optional mandatory or
additional arguments if any.

If there's missing or invalid arguments, it returns
an undefined value.

Example:

    my $obj = __CLASS__->new();

=head2 INSTANCE METHODS

=head3 C<some_method($arg1, $arg2, ...)>

Accelerates to warp speed.

C<$arg1> is the acceleration factor.
C<$arg2> is the warp target speed.

Returns a boolean value that tells you if the
acceleration is possible or not.

=head1 BUGS AND LIMITATIONS

=head1 SEE ALSO

Other stuff to be looked into...

=over 4

=item * this

=item * that

=back

=head1 AUTHOR

__FULLNAME__, E<lt>__USER__@domain.localE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (c), __YEAR__ __FULLNAME__
All rights reserved.

~;

    return $content;
}

1;
