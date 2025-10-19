# --- Test Script for the ADFGVX Cipher ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::ADFGVX qw(adfgvx_encrypt adfgvx_decrypt);

# --- Begin Tests ---

# Use a standard, well-known set of keys and plaintext for verification.
my $grid_key = "ZEBRAS";
my $trans_key = "PRIVACY";
my $plaintext = "attack at once";
# This is the known correct ciphertext for the above keys and plaintext.
my $ciphertext = "GDFFAVGAFDAVGAVDFAFFXAVD";

# Test 1: Basic encryption with a known value
is(
    adfgvx_encrypt($plaintext, [$grid_key, $trans_key]),
    $ciphertext,
    "Encrypt: Should produce the correct, standard ciphertext"
);

# Test 2: Basic decryption
# FIX: The expected value is now correctly normalized.
my $expected_plaintext = uc($plaintext);
$expected_plaintext =~ s/[^A-Z0-9]//g;
is(
    adfgvx_decrypt($ciphertext, [$grid_key, $trans_key]),
    $expected_plaintext,
    "Decrypt: Should correctly reverse the encryption"
);

# Test 3: Full Cycle Test with numbers
my $original = "This is a secret message 123 for ADFGVX";
my $test_grid_key = "SECRETKEY";
my $test_trans_key = "CIPHER";
my $encrypted = adfgvx_encrypt($original, [$test_grid_key, $test_trans_key]);
my $decrypted = adfgvx_decrypt($encrypted, [$test_grid_key, $test_trans_key]);

my $expected_original = uc($original);
$expected_original =~ s/[^A-Z0-9]//g;

is(
    $decrypted,
    $expected_original,
    "Full cycle: Encrypt then Decrypt should return the original (normalized)"
);

# 4. Signal that all tests are done.
done_testing();
