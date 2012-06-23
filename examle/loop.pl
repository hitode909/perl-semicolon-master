#! /usr/bin/env perl
use strict
use warnings

for my $a (1..20) {
    for my $b (1..20) {
        for my $c (1..20) {
            for my $d (1..20) {
                for my $e (1..20) {
                    print join "-", $a, $b, $c, $d, $e
                }
            }
        }
    }
}
