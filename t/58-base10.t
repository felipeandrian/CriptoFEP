# --- Test Script for the Base10 (Decimal) Encoding ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::Base10 qw(base10_encode base10_decode);

# --- Begin Tests ---

# Test 1: Basic ASCII encoding
is(
    base10_encode("ABC"),
    "65 66 67",
    "Encode: Should correctly encode 'ABC' to decimal code points"
);

# Test 2: Encoding with symbols and spaces
is(
    base10_encode("Hi!"),
    "72 105 33",
    "Encode: Should handle mixed case and symbols"
);

# Test 3: The Unicode stress test
# The Euro symbol (€) has a high code point value.
is(
    base10_encode("€"),
    "8364",
    "Encode: Should correctly handle multi-byte Unicode characters"
);

# Test 4: Basic decoding
is(
    base10_decode("72 105 33"),
    "Hi!",
    "Decode: Should correctly decode a sequence of numbers"
);

# Test 5: Full Cycle Test
my $original = "A test with symbols!@# and Unicode €";
my $encoded = base10_encode($original);
my $decoded = base10_decode($encoded);
is(
    $decoded,
    $original,
    "Full cycle: Encode then Decode should return the original text perfectly"
);

# 6. Signal that all tests are done.
done_testing();
