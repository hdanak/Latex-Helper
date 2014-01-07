use Modern::Perl;
use Test::More;

use Latex::Helper;

is Env('name')->(1,2,3), join('',
    '\begin{name}', '1 2 3', '\end{name}'
);
is Env('name', attr1 => 'val1', attr2 => 'val2')->(), join('',
    '\begin{name}[attr1=val1,attr2=val2]',
    '\end{name}'
);
is Env('name', attr1 => 'val1', attr2 => 'val2')->(qw(a b \c d \e)), join('',
    '\begin{name}[attr1=val1,attr2=val2]',
    'a b\c d\e',
    '\end{name}'
);

done_testing 3
