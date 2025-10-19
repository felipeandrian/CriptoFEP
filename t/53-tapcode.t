# --- Test Script for the Tap Code Encoding ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::TapCode qw(tap_code_encode tap_code_decode);
use CriptoFEP::Utils qw(normalize_text);

# --- Begin Tests ---

# Test 1: Basic encoding of a word
is(
    tap_code_encode("WATER"),
    "..... .. / . . / .... .... / . ..... / .... ..",
    "Encode: Should correctly encode 'WATER'"
);

# Test 2: Special handling of 'K' vs 'C'
# The Tap Code treats 'K' as 'C'. This test ensures both produce the same output.
is(
    tap_code_encode("KNOCK"),
    tap_code_encode("CNOCK"),
    "Encode: 'K' should be treated as 'C'"
);

# Test 3: Basic decoding
is(
    tap_code_decode("..... .. / . . / .... .... / . ..... / .... .."),
    "WATER",
    "Decode: Should correctly decode a sequence of taps"
);

# Test 4: Full Cycle Test
my $original = "A secret message";
my $encoded = tap_code_encode($original);
my $decoded = tap_code_decode($encoded);
# Tap code normalizes to A-Z and combines K with C.
my $expected = normalize_text($original);
$expected =~ s/K/C/g;

is(
    $decoded,
    $expected,
    "Full cycle: Encode then Decode should return the original (normalized)"
);

# 5. Signal that all tests are done.
done_testing();
