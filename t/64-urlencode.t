# --- Test Script for the URL Encoding ---

use strict;
use warnings;
use utf8;
use Test::More;
use lib 'lib';
use CriptoFEP::UrlEncode qw(url_encode url_decode);

# --- Begin Tests ---

# Test 1: Encoding with spaces and multi-byte UTF-8 characters
is(
    url_encode("Olá Mundo!"),
    "Ol%C3%A1%20Mundo%21",
    "Encode: Should correctly encode spaces and Unicode characters"
);

# Test 2: Encoding of reserved URI characters
is(
    url_encode("/?&=#"),
    "%2F%3F%26%3D%23",
    "Encode: Should correctly encode all reserved characters"
);

# Test 3: Decoding should correctly handle percent-encoding
# FIX: Corrected the expected value to use the proper Unicode character.
is(
    url_decode("Ol%C3%A1%20Mundo%21"),
    "Olá Mundo!",
    "Decode: Should correctly decode percent-encoded strings"
);

# Test 4: Decoding should handle the '+' convention for spaces
is(
    url_decode("teste+de+decode"),
    "teste de decode",
    "Decode: Should correctly interpret '+' as a space"
);

# Test 5: Full Cycle Test
my $original = "A test with symbols!@# and Unicode € and spaces";
my $encoded = url_encode($original);
my $decoded = url_decode($encoded);
is(
    $decoded,
    $original,
    "Full cycle: Encode then Decode should return the original text perfectly"
);

done_testing();
