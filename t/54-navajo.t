# --- Test Script for the Navajo Code ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::Navajo qw(navajo_encode navajo_decode);

# --- Begin Tests ---

# Test 1: Basic encoding of a word
# This value is taken directly from the module's info function for consistency.
is(
    navajo_encode("ATTACK"),
    "WOL-LA-CHEE THAN-ZIE THAN-ZIE WOL-LA-CHEE MOASI KLIZZIE-YAZZIE",
    "Encode: Should correctly encode a single word"
);

# Test 2: Encoding with multiple words
is(
    navajo_encode("CODE TALKER"),
    "MOASI NE-AHS-JAH BE DZEH / THAN-ZIE WOL-LA-CHEE DIBEH-YAZZIE KLIZZIE-YAZZIE DZEH GAH",
    "Encode: Should handle multiple words with a slash separator"
);

# Test 3: Basic decoding (case-insensitive)
is(
    navajo_decode("wol-la-chee THAN-ZIE than-zie WOL-LA-CHEE moasi klizzie-yazzie"),
    "ATTACK",
    "Decode: Should correctly decode a sequence, ignoring case"
);

# Test 4: Full Cycle Test
my $original = "A test for the navajo code";
my $encoded = navajo_encode($original);
my $decoded = navajo_decode($encoded);
is(
    $decoded,
    uc($original),
    "Full cycle: Encode then Decode should return the original (uppercase)"
);

# 5. Signal that all tests are done.
done_testing();
