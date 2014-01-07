use Modern::Perl;
use Test::More;

use Latex::Helper;

is UsePackage(
    a   => { k1 => 'v1', k2 => 'v2' },
    b   => {},
    c   => 'opt',
), join('',
    '\usepackage[k1=v1,k2=v2]{a}',
    '\usepackage{b}',
    '\usepackage[opt]{c}',
);

done_testing 1
