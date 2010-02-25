package App::Autopod::Template::FromFile;

use strict;
use warnings;

sub priority {
    return 1000;
}

# The file plugin always matches because it's
# the user that decided to supply his own file
sub matches {
    return 1;
}

sub as_filehandle {
    my ($filename, $content) = @_;
    open my $fh, '<', $filename;
    return $fh;
}

sub as_string {
    my ($filename, $content) = @_;
    my $tmpl = '';
    my $fh = as_filehandle($filename, $content);
    while (<$fh>) {
        $tmpl .= $_;
    }
    close $fh or return;
    return $tmpl;
}

1;

