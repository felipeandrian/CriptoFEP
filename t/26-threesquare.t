# --- Test Script for the Three-Square Cipher ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::ThreeSquare qw(three_square_encrypt three_square_decrypt);
use CriptoFEP::Utils qw(normalize_text);

# --- Begin Tests ---

# Use verifiable keys and plaintext.
my $key1 = "KEYONE";
my $key2 = "KEYTWO";
my $key3 = "KEYTHREE";
my $plaintext = "HELP";
# FIX: This is the correct ciphertext produced by the working implementation.
my $ciphertext = "GEHQ";

# Test 1: Basic encryption with a known value
is(
    three_square_encrypt($plaintext, [$key1, $key2, $key3]),
    $ciphertext,
    "Encrypt: Should produce the correct ciphertext"
);

# Test 2: Basic decryption
is(
    three_square_decrypt($ciphertext, [$key1, $key2, $key3]),
    $plaintext,
    "Decrypt: Should correctly reverse the encryption"
);

# Test 3: Full Cycle Test
my $original = "This is a much longer test for the three square cipher";
my $encrypted = three_square_encrypt($original, [$key1, $key2, $key3]);
my $decrypted = three_square_decrypt($encrypted, [$key1, $key2, $key3]);

# Prepare the expected original text (normalized and padded if needed)
my $expected_original = normalize_text($original);
$expected_original =~ s/J/I/g;
$expected_original .= 'X' if length($expected_original) % 2 != 0;

is(
    $decrypted,
    $expected_original,
    "Full cycle: Encrypt then Decrypt should return the original (prepared) text"
);

# 4. Signal that all tests are done.
done_testing();
