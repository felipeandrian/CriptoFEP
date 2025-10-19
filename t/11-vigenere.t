# --- Test Script for the Vigenere (Autokey) Cipher ---
use strict;
use warnings;
use utf8;
use Test::More;
use lib 'lib';
use CriptoFEP::Vigenere qw(vigenere_encrypt vigenere_decrypt);
use CriptoFEP::Utils qw(normalize_text);

# --- Begin Tests ---

# These are the mathematically correct values for the Autokey implementation.
my $plaintext = "ATTACK AT DAWN";
my $key = "LEMON";
my $ciphertext = "LXFOPKTMDCGN"; 

# Test 1: Basic encryption
is( 
    vigenere_encrypt($plaintext, $key), 
    $ciphertext, 
    "Encrypt: Autokey Vigenere should produce the correct ciphertext" 
);

# Test 2: Basic decryption
is( 
    vigenere_decrypt($ciphertext, $key),
    normalize_text($plaintext),
    "Decrypt: Should correctly reverse the Autokey encryption"
);

# Test 3: Full cycle
my $original = "This is a much longer test for the autokey vigenere cipher";
my $test_key = "SECRETKEY";
my $encrypted = vigenere_encrypt($original, $test_key);
my $decrypted = vigenere_decrypt($encrypted, $test_key);
is( 
    $decrypted, 
    normalize_text($original),
    "Full cycle: Encrypt then Decrypt should return the original (normalized)" 
);

done_testing();
