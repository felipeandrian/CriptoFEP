# --- Test Script for Morse Code ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::Morse qw(morse_encode morse_decode);
use CriptoFEP::Utils qw(normalize_text);

# --- Begin Tests ---

# Test 1: Basic word encoding
is(
    morse_encode("SOS"),
    "... --- ...",
    "Encode: Should correctly encode a single word"
);

# Test 2: Encoding with word separators
is(
    morse_encode("HELLO WORLD"),
    ".... . .-.. .-.. ---   .-- --- .-. .-.. -..",
    "Encode: Should use a triple space between words"
);

# Test 3: Basic word decoding
is(
    morse_decode("... --- ..."),
    "SOS",
    "Decode: Should correctly decode a single word"
);

# Test 4: Decoding with word separators
is(
    morse_decode(".... . .-.. .-.. ---   .-- --- .-. .-.. -.."),
    "HELLO WORLD",
    "Decode: Should correctly handle the triple space between words"
);

# Test 5: Full Cycle Test
my $original = "A test with numbers 123";
my $encrypted = morse_encode($original);
my $decrypted = morse_decode($encrypted);
is(
    $decrypted,
    uc($original), # Morse code normalizes to uppercase
    "Full cycle: Encode then Decode should return the original (uppercase)"
);

# 6. Signal that all tests are done.
done_testing();
