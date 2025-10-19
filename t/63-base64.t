# --- Test Script for the Base64 Encoding ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::Base64 qw(base64_encode base64_decode);

# --- Begin Tests ---

# Test 1: Basic encoding of a 3-char word (no padding)
is(
    base64_encode("FEP"),
    "RkVQ",
    "Encode: Should correctly encode 'FEP' without padding"
);

# Test 2: Encoding that requires padding
is(
    base64_encode("FE"),
    "RkU=",
    "Encode: Should correctly encode 'FE' with one padding character"
);
is(
    base64_encode("F"),
    "Rg==",
    "Encode: Should correctly encode 'F' with two padding characters"
);

# Test 3: Basic decoding
is(
    base64_decode("RkVQ"),
    "FEP",
    "Decode: Should correctly decode a Base64 string"
);

# Test 4: Full Cycle Test
my $original = "A test for base64 encoding!";
my $encoded = base64_encode($original);
my $decoded = base64_decode($encoded);
is(
    $decoded,
    $original,
    "Full cycle: Encode then Decode should return the original text perfectly"
);

# 5. Signal that all tests are done.
done_testing();
