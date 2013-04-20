use Modern::Perl;
use Test::More;

use Latex::Helper qw/Collection/;

is Collection(1, 2, '\hello', '\foo', 'goodbye', ' world', 4, "OK\n"
                    ), "1 2\\hello\\foo goodbye world 4 OK\n";
is Collection(\[ 1, 2, '\hello', '\foo', 'goodbye', ' world', 4, "OK\n" ],
    delim => "\n"), "1\n2\n\\hello\n\\foo\ngoodbye\n world\n4\nOK\n";

done_testing 2
