package App::Autopod;

use warnings;
use strict;

use Carp        ();
use File::Slurp ();
use File::Spec  ();
use IO::Scalar  ();

our $VERSION = '0.01';

sub eval_vars {
    my ($args) = @_;

    my $mod = $args->{module};
    if (! $mod) {
        Carp::croak "eval_vars() needs a 'module' argument";
    }

    my $class = get_class($mod);
    (my $testless_class = $class) =~ s{^Test::}{};

    my $user = exists $args->{user}
        ? $args->{user}
        : $ENV{AUTOPOD_USER} || $ENV{USER}
        ;

    my $fullname = exists $args->{fullname}
        ? $args->{fullname}
        : $ENV{AUTOPOD_FULLNAME} || $ENV{DEBFULLNAME}
        ;

    my $current_year = (localtime())[5] + 1900;

    my $vars = {
        '__CLASS__'     => $class,
        '__FULLNAME__'  => $fullname,
        '__FUNCTIONS__' => get_subs_block($mod),
        '__TESTLESS_CLASS__' => $testless_class,
        '__USER__'      => $user,
        '__YEAR__'      => $current_year,
    };

    return $vars;
}

sub open_template {
    my ($file) = @_;

    my $found = 0;
    my $fh;

    for my $try_dir
    (".", $ENV{HOME}, "$ENV{HOME}/.autopod/templates", "/usr/share/autopod/templates", "/etc/autopod/templates")
    {
        my $path = File::Spec->catfile($try_dir, $file);

        # Try both .pod and no-extension
        open $fh, '<', "$path.pod"
            and $found = $fh
            and last;

        open $fh, '<', $path
            and $found = $fh
            and last;

    }

    unless ($found) {
        die "Can't file template file $file: $!\n";
    }

    return $fh;
}

sub _get_lines_matching {
	my ($re, @content) = @_;

	if (! $re || ! @content) {
		return;
	}

	# You can pass lines with/without final "\n"
	my $text = join("\n", @content);
	@content = split(m{[\r\n]+}m, $text);

	# Collect all matching lines
	my @matches;
	for (@content) {
		if ($_ =~ $re) {
			push @matches, $_;
			last unless wantarray;
		}
	}

	return wantarray 
		? @matches
		: $matches[0];
}

sub get_class {
	my ($file) = @_;
	my @content = File::Slurp::read_file($file);
	return get_class_from_source(@content);
}

sub get_class_from_source {

    my (@content) = @_;

	# Collect all package declaration lines
	my @class = _get_lines_matching(
		qr{^ \s* package \s+}x,
		@content
	);

	# Try to match the "package" declaration and
	# find the class/module identifier
	for my $class (@class) {
		if (defined $class and $class =~ m{
			^ \s*                # Start of line
			package \s+          # Package keyword
			(
				[_A-Za-z]        # Initial letter or underscore
				(?:\w|::)*       # Either \w or a "::"
			)
			\s* ;?               # Any whitespace and ";"
			}mx)
		{
			$class = $1;
		}
	}

    return wantarray
		? @class
		: $class[0];
}

sub get_subs {
	my ($file) = @_;
	my @content = File::Slurp::read_file($file);
	return get_subs_from_source(@content);
}

sub get_subs_block {
	my ($file) = @_;
	my @subs = get_subs($file);
	my $block = qq{\n};

	for my $sub_name (@subs) {
		$block .= "=head3 C<< $sub_name >>\n";
		$block .= "\n";
		$block .= "A. U. Thor was too lazy to document this function apparently...\n";
		$block .= "\n";
	}

	return $block;
}

sub get_subs_from_source {
    my (@content) = @_;

	# Collect all function headers
	my @sub = _get_lines_matching(
		qr{^ \s* sub \s+}x,
		@content
	);

	# Try to find the sub identifier
	for my $sub (@sub) {
		if (defined $sub and $sub =~ m<
			^ \s*                             # Start of line
			sub \s+                           # sub keyword
			(
				[_A-Za-z]                     # Initial letter or underscore
				(?: \w | :: | ')*             # Either \w, "::" or the archaic ' 
			)
			\s*
			(?: \( \s* [\$\%\&\@\;] \s* \) )? # Prototype or not?
			\s*
			{?                                # Opening block
		>mx)
		{
			$sub = $1;
		}
	}

    return wantarray
		? @sub
		: $sub[0];
}

sub process_template {
	my ($args) = @_;

	my $mod = $args->{module};
	my $tmpl = $args->{template};

	if (! $mod) {
		Carp::croak "Can't generate documentation without a 'module' argument";
	}

    my $vars = eval_vars($args);

    my $fh = defined $tmpl
        ? open_template($tmpl)
        : default_template_fh();

	my $output = q{};
    while(<$fh>) {
        s[(__\w+__)][$vars->{$1}]eg;
        $output .= $_;
    }

    close $fh;
	return $output;
}

sub usage {
    return
		"Usage: $0 <module.pm>\n" .
        "       $0 --template=<sometemplate.pod> <module.pm>\n";
}

1; # End of App::Autopod

__END__

=pod

=head1 NAME

App::Autopod - The great new App::Autopod!

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use App::Autopod;

    my $foo = App::Autopod->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 FUNCTIONS

=head2 eval_vars({ module => $module, user => $username, fullname => $fullname)

Main function, takes in a set of params and returns a struct with documentation and variables gathered:

    __CLASS__          - Classname
    __FULLNAME__       - Fullname
    __FUNCTIONS__      - Function documentation
    __TESTLESS_CLASS__ - Class name without Test:: prefix
    __USER__           - Username
    __YEAR__           - Current year

=head2 open_template($file)

Returns a filehandle after opening the provided template $file. Looks into a set of pre-defined directories.

=head2 _get_lines_matching($re, @lines)

Returns lines matching the given regular expression.
Returns first match in scalar context.

=head2 get_class($file)

Returns a list of class declarations found in $file.
Returns first match in scalar context.

=head2 get_class_from_source(@lines)

Returns a list of class declarations found in the @lines provided. 
Returns first match in scalar context.

=head2 get_subs($file)

Returns a list of sub names found in $file. 
Returns first match in scalar context.

=head2 get_subs_block($file)

Returns a string with documention made from the subs found in $file

=head2 get_subs_from_source(@lines)

Returns a list of sub names found in the @lines provided.
Returns first match in scalar context.

=head2 process_template({ module => $module, template => $template_file })

Processes a template for the given module and returns the result

=head2 usage

Return usage text

=head1 AUTHOR

Cosimo Streppone, C<< <cosimo at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-app-autopod at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=App-Autopod>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::Autopod


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=App-Autopod>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/App-Autopod>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/App-Autopod>

=item * Search CPAN

L<http://search.cpan.org/dist/App-Autopod>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2010 Cosimo Streppone, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

