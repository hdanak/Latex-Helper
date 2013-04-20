package Latex::Helper::Collection;
our $VERSION = v0.0.1;

use Modern::Perl;
use Attribute::Handlers;
no warnings 'redefine';

use parent qw(Exporter);
our @EXPORT = qw(Collection);

use Latex::Helper;


sub Collection {
    my (@data, %conf);
    if (('REF' eq ref $_[0]) and ('ARRAY' eq ref ${$_[0]})) {
        @data = @${+shift};
        %conf = @_;
    } else {
        @data = @_;
    }
    my $delim = delete $conf{delim} // '';
    my $space = delete $conf{space} // ' ';
    my $out = shift @data or return '';
    map { my $d = $_;
        my $elem;
        given (ref $d) {
            $elem = Itemized($d, %conf)     when 'ARRAY';
            $elem = Dictionary($d, %conf)   when 'HASH';
            $elem = Collection(&$d(%conf))  when 'CODE';
            $elem = "$d"
        }
        if ($delim) {
            $out .= $delim
        } elsif ($out !~ /[\}\s]$/ and $elem !~ /^[\{\s\\]/) {
            $out .= $space
        }
        $out .= $elem;
    } @data;
    return $out
}
sub Itemized {
    my ($list, %attrs) = @_;
    Latex::Helper::Env('itemize', %attrs)->(map { +'\item', Collection($_) } @$list)
}
sub Dictionary {
    my ($dict, %attrs) = @_;
    Latex::Helper::Env('description', %attrs)->(map {
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
