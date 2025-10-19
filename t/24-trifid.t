# --- Test Script for the Trifid Cipher ---
use strict;
use warnings;
use utf8;
use Test::More;
use lib 'lib';
use CriptoFEP::Trifid qw(trifid_encrypt trifid_decrypt);
use CriptoFEP::Utils qw(normalize_text);

# --- Begin Tests ---

# These are the mathematically correct values.
my $key = "SECRET";
my $plaintext = "HELP";
my $ciphertext = "HPHM";

# Test 1: Basic encryption
is(
    trifid_encrypt($plaintext, $key),
    $ciphertext,
    "Encrypt: Should produce the correct ciphertext for 'HELP'"
);

# Test 2: Basic decryption
is(
    trifid_decrypt($ciphertext, $key),
    $plaintext,
    "Decrypt: Should correctly reverse the encryption"
);

# Test 3: Full cycle
my $original = "This is a much longer test for the trifid cipher.";
my $test_key = "CRYPTO";
my $encrypted = trifid_encrypt($original, $test_key);
my $decrypted = trifid_decrypt($encrypted, $test_key);

# FIX: The expected value now uses the same normalization function as the module.
is(
    $decrypted,
    normalize_text($original),
    "Full cycle: Encrypt then Decrypt should return the original (normalized)"
);

done_testing();
