# --- Test Script for the Multiplicative Cipher ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::Multiplicative qw(multiplicative_encrypt multiplicative_decrypt);
use CriptoFEP::Utils qw(normalize_text);

# --- Begin Tests ---

# Use a standard, verifiable key and plaintext.
my $key = 7;
my $plaintext = "HELLO";
# This is the known correct ciphertext for the above key and plaintext.
# H(7)*7=49%26=23(X), E(4)*7=28%26=2(C), L(11)*7=77%26=25(Z), O(14)*7=98%26=20(U)
my $ciphertext = "XCZZU";

# Test 1: Basic encryption with a known value
is(
    multiplicative_encrypt($plaintext, $key),
    $ciphertext,
    "Encrypt: Should produce the correct ciphertext for 'HELLO'"
);

# Test 2: Basic decryption
is(
    multiplicative_decrypt($ciphertext, $key),
    $plaintext,
    "Decrypt: Should correctly reverse the encryption"
);

# Test 3: Full Cycle Test
# This is the most robust test, as it doesn't depend on pre-calculated values.
my $original = "This is a much longer test for the multiplicative cipher";
my $test_key = 11; # Another valid key
my $encrypted = multiplicative_encrypt($original, $test_key);
my $decrypted = multiplicative_decrypt($encrypted, $test_key);
is(
    $decrypted,
    normalize_text($original),
    "Full cycle: Encrypt then Decrypt should return the original (normalized)"
);

# 4. Signal that all tests are done.
done_testing();
