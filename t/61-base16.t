# --- Test Script for the Base16 (Hexadecimal) Encoding ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::Base16 qw(base16_encode base16_decode);

# --- Begin Tests ---

# Test 1: Basic encoding of a word
# Note: Perl's unpack('H*') produces lowercase hex digits.
is(
    base16_encode("Hello"),
    "48656c6c6f",
    "Encode: Should correctly encode 'Hello' to lowercase hexadecimal"
);

# Test 2: Basic decoding
is(
    base16_decode("48656c6c6f"),
    "Hello",
    "Decode: Should correctly decode a hexadecimal string"
);

# Test 3: Decoding should be case-insensitive
is(
    base16_decode("48656C6C6F"), # Using uppercase hex
    "Hello",
    "Decode: Should handle uppercase hexadecimal input"
);

# Test 4: Full Cycle Test
my $original = "A test for hexadecimal encoding! @123";
my $encoded = base16_encode($original);
my $decoded = base16_decode($encoded);
is(
    $decoded,
    $original,
    "Full cycle: Encode then Decode should return the original text perfectly"
);

# 5. Signal that all tests are done.
done_testing();
