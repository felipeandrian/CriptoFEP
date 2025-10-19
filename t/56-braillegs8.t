# --- Test Script for the Braille (GS8) Encoding ---

# 1. Standard Pragmas
use strict;
use warnings;
# Crucial for handling the Braille Unicode characters directly in this test file.
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::BrailleGS8 qw(braille_encode braille_decode);

# --- Begin Tests ---

# FIX: Corrected the expected ciphertext value to match the program's correct output.
my $plaintext = "CODE";
my $encoded_braille = "⠉⠕⠙⠑";

# Test 1: Basic encoding of a word
is(
    braille_encode($plaintext),
    $encoded_braille,
    "Encode: Should correctly encode 'CODE' into Braille symbols"
);

# Test 2: Basic decoding of Braille symbols
is(
    braille_decode($encoded_braille),
    $plaintext,
    "Decode: Should correctly decode Braille symbols back to 'CODE'"
);

# Test 3: Full Cycle Test
my $original = "A TEST IN BRAILLE";
my $encoded = braille_encode($original);
my $decoded = braille_decode($encoded);
# The expected value correctly reflects that the module preserves spaces.
is(
    $decoded,
    uc($original),
    "Full cycle: Encode then Decode should return the original (uppercase)"
);

# 4. Signal that all tests are done.
done_testing();
