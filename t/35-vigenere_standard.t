# --- Test Script for the Vigenere Standard (Repeating Key) Cipher ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::VigenereStandard qw(vigenere_standard_encrypt vigenere_standard_decrypt);
use CriptoFEP::Utils qw(normalize_text);

# --- Begin Tests ---

# Use a standard, verifiable key and plaintext.
my $plaintext = "ATTACK";
my $key = "KEY";
# This is the mathematically correct ciphertext for the standard Vigenere cipher.
# A(0)+K(10)=K, T(19)+E(4)=X, T(19)+Y(24)=R, A(0)+K(10)=K, C(2)+E(4)=G, K(10)+Y(24)=I
my $ciphertext = "KXRKGI";

# Test 1: Basic encryption with a known value
is( 
    vigenere_standard_encrypt($plaintext, $key), 
    $ciphertext, 
    "Encrypt: Standard Vigenere should produce the correct ciphertext" 
);

# Test 2: Basic decryption
is( 
    vigenere_standard_decrypt($ciphertext, $key),
    $plaintext,
    "Decrypt: Should correctly reverse the standard encryption"
);

# Test 3: Full Cycle Test
# This is the most robust test, as it doesn't depend on pre-calculated values.
my $original = "This is a much longer test for the standard vigenere cipher";
my $test_key = "SECRETKEY";
my $encrypted = vigenere_standard_encrypt($original, $test_key);
my $decrypted = vigenere_standard_decrypt($encrypted, $test_key);
is( 
    $decrypted, 
    normalize_text($original),
    "Full cycle: Encrypt then Decrypt should return the original (normalized)" 
);

# 4. Signal that all tests are done.
done_testing();
