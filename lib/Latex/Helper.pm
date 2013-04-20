package Latex::Helper;
our $VERSION = v0.0.1;

use Modern::Perl;
use Attribute::Handlers;

=head1 SYNOPSIS

    ...

=cut

BEGIN {

use parent qw(Exporter);
our @EXPORT = qw( MODIFY_CODE_ATTRIBUTES
    Collection Itemized Dictionary
    Group AutoGroup NewCommand Env Dedent
    br space nbsp
    normal italic slanted boldface mediumface
    smallcaps sans_serif monospace teletype
    size url Paragraph Document
);

no warnings 'redefine';

sub MODIFY_CODE_ATTRIBUTES {
    my ($pkg, $ref, @attrs) = @_;
    our %_CODE_HANDLERS;
    no warnings 'void';
    my $sym = Attribute::Handlers::findsym($pkg, $ref, 'CODE');
    grep {
        if (/^([^(]+)(?:[(](.*)[)])?$/ and exists $_CODE_HANDLERS{$1}) {
            my ($handler, %flags) = @{$_CODE_HANDLERS{$1}};
            my $data = $2;
            $data = eval(qq{
                package $pkg; no warnings; no strict;
                local \$SIG{__WARN__}=sub{die}; [$2]
            }) or $2 if not $flags{raw} and defined $2;
            $handler->($pkg, $sym, defined &$$sym ? \&$$sym : sub{@_}, $data);
            0
        } else { 1 }
    } @attrs
}
sub attr_sub {
    my ($attr_name, $attr_sub, %flags) = @_;
    our %_CODE_HANDLERS;
    $_CODE_HANDLERS{$attr_name} = $_CODE_HANDLERS{$attr_sub} and return
            unless ref $attr_sub;
    warn "Redefining attribute $attr_name" if exists $_CODE_HANDLERS{$attr_name};
    $_CODE_HANDLERS{$attr_name} = [ $attr_sub, %flags ];
}

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
attr_sub(Collection  => sub {
    my ($pkg, $sym, $ref, undef, $data) = @_;
    $ref //= sub { @_ };
    $$sym = sub { Collection(\[&ref], $data ? ( delim => $data ):()) }
});
sub Itemized {
    my ($list, %attrs) = @_;
    Env('itemize', %attrs)->(map { +'\item', Collection($_) } @$list)
}
attr_sub(Itemized    => sub {
    my ($pkg, $sym, $ref, undef, $data) = @_;
    $$sym = sub { Itemized(\@_, @$data) }
});
sub Dictionary {
    my ($dict, %attrs) = @_;
    Env('description', %attrs)->(map {
                    +"\\item[$_]", Collection($$dict{$_}) } keys %$dict)
}
attr_sub(Dictionary  => sub {
    my ($pkg, $sym, $ref, undef, $data) = @_;
    $$sym = sub { Dictionary(\@_, @$data) }
});

sub Group {
# NOTE: device method for items to communicate with their Collection;
#   for example, the C<italic> element could add an italic-correction token at
#   the end of its C<Group>, without every C<Group> having one.
    '{'.&Collection.'}'
}
attr_sub Group => sub {
    my ($pkg, $sym, $ref, $data) = @_;
    $$sym = sub { Group(\[&$ref], @$data) }
};
attr_sub AutoGroup => sub {
    my ($pkg, $sym, $ref, $data) = @_;
    $$sym = sub {
        my @items = &$ref;
        @items ? Group(@$data, @items) : "@$data"
    }
};
sub NewCommand {
    my ($name, $argc, $defarg) = @_;
    sub { "\\newcommand{$name}" . ($argc ? "[$argc]":'')
        . ($defarg ? "[$defarg]":'') . Group(@_) }
}
sub Env {
    my ($name, $attrs) = @_;
    sub {
        Collection(
            "\\begin{$name}".(
                $attrs ? '['.join(',', map {"$_=$$attrs{$_}"} keys %$attrs).']':''
            ), @_, "\\end{$name}"
        )
    }
}
attr_sub Env => sub {
    my ($pkg, $sym, $ref, $data) = @_;
    $$sym = sub { Env(@$data)->(&$ref) }
};
sub Dedent {
    my ($max, $indent, $tabsize) = map{int}(shift//0, shift//1, shift//8);
        # Remove as much as (evenly) possible------^         ^         ^
        # strip away all indentation by default--------------'         |
        # standard UNIX tabstop size-----------------------------------'
    my $tabexpand = ' ' x $tabsize;
    my $indent_re = qr/^[ ]{$indent}/;
    sub {
        my @lines = map { map { s/^\s*?\K\t/$tabexpand/g } split /\n/ } @_;
        my $i = 0;
        while (not $max or $i < $max) {
            last unless @lines == grep { /$indent_re/ } @lines;
            map { s/$indent_re//g } @lines;
            ++$i
        }
        return @lines
    }
}
attr_sub Dedent => sub {
    my ($pkg, $sym, $ref, $data) = @_;
    my @params = ref($data) eq 'ARRAY' ? @$data[0..2] : $data;
    $$sym = sub { Dedent(@params)->(&$ref) }
};
# NOTE: Make the result from all of the above auto-chainable;
# that is,  sub X :Attr1(...) { ... }
#           sub Y :X(...) { ... }
attr_sub Wrap => sub {
    my ($pkg, $sym, $ref, $data) = @_;
    $$sym = sub { local *inner = $ref; eval($data) }
}, raw => 1;

}

## Latex Helper Macros

use constant {
    br      => "\n\n",
    sp      => '\ ',
    thinsp  => '\,',
    negsp   => '\!',
    thicksp => '\;',
    quadsp  => '\quad',
    qquadsp => '\qquad',
    nbsp    => '\~',
};
sub space {
    my ($n) = @_;
    ($n >= 0 ? '\,':'\!') x abs($n)
}

sub normal      :AutoGroup('\normalfont');
sub italic      :AutoGroup('\itshape'):Wrap(&inner.(@_?'\/':''));
sub slanted     :AutoGroup('\slshape');
sub boldface    :AutoGroup('\bfseries');
sub mediumface  :AutoGroup('\mdseries');
sub smallcaps   :AutoGroup('\scshape');
sub sans_serif  :AutoGroup('\sffamily');
sub monospace   :AutoGroup('\ttfamily');
sub teletype    :AutoGroup('\ttfamily');

sub size {
    my ($size, $line_space) = @_;
    $line_space = $line_space//0 + $size;
    "\\fontsize{$size}{$line_space}\\selectfont"
}
sub url :Group { normal, size(9), teletype, "<\\url@_>" }

sub Paragraph :AutoGroup('\par');
sub Document  :Env('document'):Wrap(shift . &inner);

1
