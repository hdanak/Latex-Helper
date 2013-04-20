use Modern::Perl;
use Test::More;

use Latex::Helper;

is UsePackage(
    a   => { k1 => 'v1', k2 => 'v2' },
    b   => {}
), '\usepackage[k1=v1,k2=v2]{a}\usepackage{b}';

done_testing 1
