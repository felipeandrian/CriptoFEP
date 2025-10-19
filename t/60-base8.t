# --- Test Script for the Base8 (Octal) Encoding ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::Base8 qw(base8_encode base8_decode);

# --- Begin Tests ---

# FIX: The expected value has been corrected to match the program's correct output.
my $plaintext = "Hello";
my $ciphertext = "22062554330674";

# Test 1: Basic encoding of a word
is(
    base8_encode($plaintext),
    $ciphertext,
    "Encode: Should correctly encode 'Hello' to octal"
);

# Test 2: Basic decoding
is(
    base8_decode($ciphertext),
    $plaintext,
    "Decode: Should correctly decode an octal string"
);

# Test 3: Full Cycle Test
my $original = "A test for octal encoding! 123";
my $encoded = base8_encode($original);
my $decoded = base8_decode($encoded);
is(
    $decoded,
    $original,
    "Full cycle: Encode then Decode should return the original text perfectly"
);

# 4. Signal that all tests are done.
done_testing();
