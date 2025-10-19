# --- Test Script for the A1Z26 Encoding ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::A1Z26 qw(a1z26_encode a1z26_decode);
use CriptoFEP::Utils qw(normalize_text);

# --- Begin Tests ---

# Test 1: Basic encoding of a word
is(
    a1z26_encode("HELLO"),
    "8 5 12 12 15",
    "Encode: Should correctly encode 'HELLO'"
);

# Test 2: Encoding should handle mixed case and ignore non-alphabetic characters
is(
    a1z26_encode("Abc 123!"),
    "1 2 3",
    "Encode: Should handle mixed case and ignore spaces/symbols"
);

# Test 3: Basic decoding
is(
    a1z26_decode("8 5 12 12 15"),
    "HELLO",
    "Decode: Should correctly decode a sequence of numbers"
);

# Test 4: Full Cycle Test
my $original = "A much longer test message for a1z26";
my $encoded = a1z26_encode($original);
my $decoded = a1z26_decode($encoded);
is(
    $decoded,
    normalize_text($original),
    "Full cycle: Encode then Decode should return the original (normalized)"
);

# 5. Signal that all tests are done.
done_testing();
