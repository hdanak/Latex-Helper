use Modern::Perl;
use Test::More;

use Latex::Helper;

sub X :Group;
is X, '{}';
is X(qw/a b c d 1 2 3/), '{}';

sub Y :Group { 'a', 'b', 'c' }
is Y, '{a b c}';
is Y(qw/x y z d 1 2 3/), '{a b c}';

sub Z :Group { 'a', 'b', @_, 'c' }
is Z, '{a b c}';
is Z(qw/x y z d 1 2 3/), '{a b x y z d 1 2 3 c}';

is Z(Y), '{a b{x y z}}'

sub I :Group {
    [ 'd', 'e', 'f' ],
}
sub D :Group {
    { a => 'd', b => 'e', c => 'f' ],
}
is Y, '\metoo';
is Y(qw/a b c d 1 2 3/), Group([qw{\metoo a b c d 1 2 3}]);

done_testing 4
