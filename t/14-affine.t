# --- Test Script for the Affine Cipher ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::Affine qw(affine_encrypt affine_decrypt);
use CriptoFEP::Utils qw(normalize_text);

# --- Begin Tests ---

# Use a standard, verifiable key and plaintext.
my $key = "5,8";
my $plaintext = "HELLO";
# This is the known correct ciphertext for the above key and plaintext.
# H(7) -> (5*7+8)%26 = 17 -> R
# E(4) -> (5*4+8)%26 = 2  -> C
# L(11)-> (5*11+8)%26 = 11 -> L
# L(11)-> (5*11+8)%26 = 11 -> L
# O(14)-> (5*14+8)%26 = 0  -> A
my $ciphertext = "RCLLA";

# Test 1: Basic encryption with a known value
is(
    affine_encrypt($plaintext, $key),
    $ciphertext,
    "Encrypt: Should produce the correct ciphertext for 'HELLO'"
);

# Test 2: Basic decryption
is(
    affine_decrypt($ciphertext, $key),
    $plaintext,
    "Decrypt: Should correctly reverse the encryption"
);

# Test 3: Full Cycle Test
# This is the most robust test, as it doesn't depend on pre-calculated values.
my $original = "This is a much longer test for the affine cipher";
my $test_key = "7,10"; # Another valid key
my $encrypted = affine_encrypt($original, $test_key);
my $decrypted = affine_decrypt($encrypted, $test_key);
is(
    $decrypted,
    normalize_text($original),
    "Full cycle: Encrypt then Decrypt should return the original (normalized)"
);

# 4. Signal that all tests are done.
done_testing();
