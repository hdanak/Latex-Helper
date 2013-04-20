use Modern::Perl;
use Test::More;

use Latex::Helper;

sub X :Group;
is X, '{}';
is X(qw/a b c \d 1 2 3/), '{a b c\d 1 2 3}';

sub Y :Group { 'i', 'j', 'k' }
is Y, '{i j k}';
is Y(qw/x y z d 1 2 3/), '{i j k}';

sub Z :Group { 'a', 'b', @_, 'c' }
is Z, '{a b c}';
is Z(qw/x y z d 1 2 3/), '{a b x y z d 1 2 3 c}';

is Z(Y), '{a b{i j k}c}';

sub I :Group {
    [ 'd', 'e', 'f' ],
}
sub D :Group {
    { a => 'd', b => 'e', c => 'f' }
}

done_testing 7
