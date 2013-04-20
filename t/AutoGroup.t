use Modern::Perl;
use Test::More;

use Latex::Helper;

sub X :AutoGroup('\myself');
is X, '\myself';
is X(qw/a b c d 1 2 3/), Group(qw{\myself a b c d 1 2 3});

sub Y :AutoGroup('\metoo') { [@_] }
is Y, '\metoo';
is Y(qw/a b c d 1 2 3/), Group([qw{\metoo a b c d 1 2 3}]);

done_testing 4
