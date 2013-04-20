package Latex::Helper::Collection;
our $VERSION = v0.0.1;

use Modern::Perl;
use Attribute::Handlers;
no warnings 'redefine';

use parent qw(Exporter);
our @EXPORT = qw(Collection);

use Latex::Helper;

use overload '""' => \&render;

sub new {
    my ($class, $data, %conf) = @_;
    my $delim = delete $conf{delim} // '';
    bless {
        list    => [
            map { my $d = $_;
                given (ref $d) {
                    Itemized($d, %conf)     when 'ARRAY';
                    Dictionary($d, %conf)   when 'HASH';
                    Collection(&$d(%conf))  when 'CODE';
                    $d
                }
            } @$data ],
        delim   => $delim,
    }, $class
}
sub render {
    my ($self) = @_;
    return '' unless @{$$self{list}};
    my $out = $$self{list}[0];
    for (1 .. $#{$$self{list}}) {
        my $elem = $$self{list}[$_];
        if ($$self{delim}) {
            $out .= $$self{delim}
        } elsif ($out !~ /[\}\s]$/ and $elem !~ /^[\{\s\\]/) {
            $out .= ' '
        }
        $out .= $elem;
    }
    return $out
}

sub Collection {
    if (('REF' eq ref $_[0]) and ('ARRAY' eq ref ${$_[0]})) {
        my ($lstrr, %conf) = @_;
        __PACKAGE__->new($$lstrr, %conf)
    } else {
        __PACKAGE__->new(\@_)
    }
}
sub Itemized {
    my ($list, %attrs) = @_;
    Latex::Helper::Env('itemize', \%attrs)->(map { +'\item', Collection($_) } @$list)
}
sub Dictionary {
    my ($dict, %attrs) = @_;
    Latex::Helper::Env('description', \%attrs)->(map {
                    +"\\item[$_]", Collection($$dict{$_}) } keys %$dict)
}
INIT {
    Latex::Helper::attr_sub(Collection  => sub {
        my ($pkg, $sym, $ref, undef, $data) = @_;
        $ref //= sub { @_ };
        $$sym = sub { Collection(\[&ref], $data ? ( delim => $data ):()) }
    });
    Latex::Helper::attr_sub(Itemized    => sub {
        my ($pkg, $sym, $ref, undef, $data) = @_;
        $$sym = sub { Itemized(\@_, @$data) }
    });
    Latex::Helper::attr_sub(Dictionary  => sub {
        my ($pkg, $sym, $ref, undef, $data) = @_;
        $$sym = sub { Dictionary(\@_, @$data) }
    });
}

1
