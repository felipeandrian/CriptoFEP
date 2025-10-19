# --- Test Script for the Base2 (Binary) Encoding ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::Base2 qw(base2_encode base2_decode);

# --- Begin Tests ---

# Test 1: Basic encoding of a word
is(
    base2_encode("Hi"),
    "01001000 01101001",
    "Encode: Should correctly encode 'Hi' to binary bytes"
);

# Test 2: Basic decoding with spaces
is(
    base2_decode("01001000 01101001"),
    "Hi",
    "Decode: Should correctly decode a binary string with spaces"
);

# Test 3: Decoding should be robust and handle input without spaces
is(
    base2_decode("0100100001101001"),
    "Hi",
    "Decode: Should handle binary strings without spaces"
);

# Test 4: Full Cycle Test
my $original = "A test for binary encoding!";
my $encoded = base2_encode($original);
my $decoded = base2_decode($encoded);
is(
    $decoded,
    $original,
    "Full cycle: Encode then Decode should return the original text perfectly"
);

# 5. Signal that all tests are done.
done_testing();
