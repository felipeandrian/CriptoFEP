# --- Test Script for the NATO Phonetic Alphabet ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::NATO qw(nato_encode nato_decode);

# --- Begin Tests ---

# Test 1: Basic encoding of a word
is(
    nato_encode("TEST"),
    "Tango Echo Sierra Tango",
    "Encode: Should correctly encode a single word"
);

# Test 2: Encoding with multiple words and numbers
is(
    nato_encode("SOS 123"),
    "Sierra Oscar Sierra / One Two Three",
    "Encode: Should handle multiple words and numbers with a slash separator"
);

# Test 3: Basic decoding (case-insensitive)
is(
    nato_decode("sierra OSCAR sierra / one tWo ThReE"),
    "SOS 123",
    "Decode: Should correctly decode a sequence, ignoring case"
);

# Test 4: Full Cycle Test
my $original = "A test for the nato phonetic alphabet";
my $encoded = nato_encode($original);
my $decoded = nato_decode($encoded);
is(
    $decoded,
    uc($original),
    "Full cycle: Encode then Decode should return the original (uppercase)"
);

# 5. Signal that all tests are done.
done_testing();
