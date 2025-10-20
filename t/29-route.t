# --- Test Script for the Route Cipher (Spiral) ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::Route qw(route_encrypt route_decrypt);

# --- Begin Tests ---

# Use the verifiable plaintext and the ciphertext
my $plaintext  = "WE ARE DISCOVERED FLEE AT ONCE";
# FIX: Using the correct ciphertext
my $ciphertext = "WE ARE FLEE DNCE DEO TAIREVOCS";

# Test 1: Basic encryption with a known value
is(
    route_encrypt($plaintext, 6),
    $ciphertext,
    "Encrypt: Should produce the correct spiral ciphertext"
);

# Test 2: Basic decryption
is(
    route_decrypt($ciphertext, 6),
    $plaintext,
    "Decrypt: Should correctly reverse the encryption"
);

# Test 3: Full Cycle Test
my $original = "This is a much longer test for the clockwise inward spiral route";
my $test_key = 5;
my $encrypted = route_encrypt($original, $test_key);
my $decrypted = route_decrypt($encrypted, $test_key);
is(
    $decrypted,
    $original,
    "Full cycle: Encrypt then Decrypt should return the original text perfectly"
);

# 4. Signal that all tests are done.
done_testing();
