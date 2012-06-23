use strict
use warnings
use Perl6::Say

my $input = shift @ARGV

if ($input < 2) {
    say "$input is not prime"
    exit
}

my $divide_by = 2

while ($divide_by < $input) {
    if ($input % $divide_by == 0) {
        say "$input is not prime ( $divide_by )"
        exit
    }
    $divide_by++
}

say "$input is prime"
