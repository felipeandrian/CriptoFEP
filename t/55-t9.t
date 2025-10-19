# --- Test Script for the T9 (Multi-press) Encoding ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::T9 qw(t9_encode t9_decode);

# --- Begin Tests ---

# Test 1: Basic encoding of a word
# H -> 44, E -> 33, L -> 555, O -> 666
is(
    t9_encode("HELLO"),
    "44 33 555 555 666",
    "Encode: Should correctly encode 'HELLO'"
);

# Test 2: Encoding with spaces and numbers
is(
    t9_encode("TEST 1"),
    "8 33 7777 8 0 1",
    "Encode: Should handle spaces (0) and numbers"
);

# Test 3: Basic decoding
is(
    t9_decode("44 33 555 555 666"),
    "HELLO",
    "Decode: Should correctly decode a sequence of multi-press codes"
);

# Test 4: Full Cycle Test
my $original = "A FULL CYCLE TEST 123";
my $encoded = t9_encode($original);
my $decoded = t9_decode($encoded);
is(
    $decoded,
    uc($original),
    "Full cycle: Encode then Decode should return the original (uppercase)"
);

# 5. Signal that all tests are done.
done_testing();
