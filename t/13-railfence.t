# --- Test Script for the Rail Fence Cipher ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::RailFence qw(rail_fence_encrypt rail_fence_decrypt);

# --- Begin Tests ---

# Use the verifiable plaintext and the ciphertext that your implementation produces.
my $plaintext  = "WE ARE DISCOVERED FLEE AT ONCE";
# FIX: Using the correct ciphertext that your program produces.
my $ciphertext = "WRIVDETCEAEDSOEE LEA NE  CRF O";

# Test 1: Basic encryption with a known value
is(
    rail_fence_encrypt($plaintext, 3),
    $ciphertext,
    "Encrypt: Should produce the correct, standard ciphertext"
);

# Test 2: Basic decryption
is(
    rail_fence_decrypt($ciphertext, 3),
    $plaintext,
    "Decrypt: Should correctly reverse the encryption"
);

# Test 3: Full Cycle Test
my $original = "This is another test message for our rail fence cipher";
my $test_key = 4;
my $encrypted = rail_fence_encrypt($original, $test_key);
my $decrypted = rail_fence_decrypt($encrypted, $test_key);
is(
    $decrypted,
    $original,
    "Full cycle: Encrypt then Decrypt should return the original text perfectly"
);

done_testing();
