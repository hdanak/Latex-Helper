use Modern::Perl;
use Test::More;

use Latex::Helper;

sub X :AutoGroup('\myself');
is X, '\myself';
is X(qw/a b c d 1 2 3/), Group(qw{\myself a b c d 1 2 3});

sub Y :AutoGroup('\metoo') { map { uc } @_ }
is Y, '\metoo';
is Y(qw/a b c d 1 2 3/), Group(qw{\metoo A B C D 1 2 3});

is italic('a', 'b', '\d'), '{\itshape a b\d}\/';

done_testing 5
