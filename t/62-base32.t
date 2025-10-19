# --- Test Script for the Base32 Encoding ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::Base32 qw(base32_encode base32_decode);

# --- Begin Tests ---

# Test 1: Basic encoding of a word (requires padding)
is(
    base32_encode("FEP"),
    "IZCVA===",
    "Encode: Should correctly encode 'FEP' with padding"
);

# Test 2: Basic decoding
is(
    base32_decode("IZCVA==="),
    "FEP",
    "Decode: Should correctly decode a Base32 string"
);

# Test 3: Decoding should be case-insensitive
is(
    base32_decode("izcva==="), # Using lowercase
    "FEP",
    "Decode: Should handle lowercase Base32 input"
);

# Test 4: Full Cycle Test
my $original = "A test for base32 encoding!";
my $encoded = base32_encode($original);
my $decoded = base32_decode($encoded);
is(
    $decoded,
    $original,
    "Full cycle: Encode then Decode should return the original text perfectly"
);

# 5. Signal that all tests are done.
done_testing();
