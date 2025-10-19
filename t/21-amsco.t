# --- Test Script for the AMSCO Cipher ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::AMSCO qw(amsco_encrypt amsco_decrypt);

# --- Begin Tests ---

# FIX: These are the mathematically correct values for the implementation.
my $trans_key = "KEY";
my $pattern_key = "12";
my $plaintext = "ATTACK";
my $ciphertext = "TTACKA";

# Test 1: Basic encryption with a known value
is(
    amsco_encrypt($plaintext, [$trans_key, $pattern_key]),
    $ciphertext,
    "Encrypt: Should produce the correct ciphertext"
);

# Test 2: Basic decryption
is(
    amsco_decrypt($ciphertext, [$trans_key, $pattern_key]),
    $plaintext,
    "Decrypt: Should correctly reverse the encryption"
);

# Test 3: Full Cycle Test
my $original = "This is a much longer test for the amsco transposition cipher";
my $test_trans_key = "SECRETKEY";
my $test_pattern_key = "1221";
my $encrypted = amsco_encrypt($original, [$test_trans_key, $test_pattern_key]);
my $decrypted = amsco_decrypt($encrypted, [$test_trans_key, $test_pattern_key]);
is(
    $decrypted,
    $original,
    "Full cycle: Encrypt then Decrypt should return the original text perfectly"
);

# 4. Signal that all tests are done.
done_testing();
