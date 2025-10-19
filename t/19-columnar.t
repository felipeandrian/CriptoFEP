# --- Test Script for the Columnar Transposition Cipher ---
use strict;
use warnings;
use utf8;
use Test::More;
use lib 'lib';
use CriptoFEP::Columnar qw(columnar_encrypt columnar_decrypt);

# --- Begin Tests ---

# These are the correct, verified values for this standard example.
my $key = "ZEBRA";
my $plaintext = "WE ARE DISCOVERED FLEE AT ONCE";
my $ciphertext = "RSRLTE DV  NE ODEOAIEFACWECEE "; # Using your verified ciphertext

# Test 1: Basic encryption
is(
    columnar_encrypt($plaintext, $key),
    $ciphertext,
    "Encrypt: Should produce the correct, standard ciphertext"
);

# Test 2: Basic decryption
is(
    columnar_decrypt($ciphertext, $key),
    $plaintext,
    "Decrypt: Should correctly reverse the encryption"
);

# Test 3: Full Cycle Test
my $original = "This is a much longer test for the columnar transposition cipher";
my $test_key = "SECRETKEY";
my $encrypted = columnar_encrypt($original, $test_key);
my $decrypted = columnar_decrypt($encrypted, $test_key);
is(
    $decrypted,
    $original,
    "Full cycle: Encrypt then Decrypt should return the original text perfectly"
);

done_testing();
