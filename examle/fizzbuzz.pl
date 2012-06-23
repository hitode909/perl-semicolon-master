#! /usr/bin/env perl
use strict
use warnings

for my $i (1..20) {
    my $message = ""
    $message .= "Fizz" unless $i % 3
    $message .= "Buzz" unless $i % 5
    $message = $i unless $message
    print "$message\n"
}
