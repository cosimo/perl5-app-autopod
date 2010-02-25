package App::Autopod::Template;

use strict;
use warnings;
use Carp;

use Module::Pluggable
    require => 1,
    search_path => "App::Autopod::Template"
    ;

sub new {
    my ($class, $opt) = @_;

    $class = ref $class || $class;
    $opt ||= {};

    my $type = ucfirst ($opt->{type} || 'default');

    # We accept fully qualified package names
    my $pack = $type =~ m{.::.}
        ? $type
        : "App::Autopod::Template::${type}";

    my $self = {};
    bless $self, $class;

    if (! $self) {
        croak("There was a problem instancing class $pack");
    }

    #warn "# Plugins: " . join(', ', $self->plugins) . "\n";

    return $self;
}

# Get all available plugins and check which of them
# can match the current content and filename
sub find_template {
    my ($self, $filename, $content) = @_;

    my @plugins = $self->plugins();

    if (! @plugins) {
        croak("No available App::Autopod::Template::* plugins?");
    }

    # Plugins that can be used with given file/content
    my @match = ();
    for my $class (@plugins) {
        if ($class->is_applicable($filename, $content)) {
            push @match, [ $class, $class->priority ];
        }
    }

    # By priority ascendent
    @match = sort { $a->[1] <=> $b->[1] } @match;
    my $best_match = pop @match;

    return $best_match;
}

sub as_filehandle {
    my ($self) = @_;
    my $class = ref $self;

    croak(qq[Abstract ${class}::as_filehandle() should be redefined]);
}

sub as_string {
    my ($self) = @_;
    my $class = ref $self;

    croak(qq[Abstract ${class}::as_string() should be redefined]);
}

1;

