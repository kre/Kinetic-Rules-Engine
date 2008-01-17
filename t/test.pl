#!/usr/bin/perl
use Test::Harness qw(&runtests);
@tests = @ARGV ? @ARGV : <*.t>;
runtests @tests;
