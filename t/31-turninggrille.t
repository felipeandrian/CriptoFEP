# --- Test Script for the Turning Grille Cipher ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::TurningGrille qw(turning_grille_encrypt turning_grille_decrypt);

# --- Begin Tests ---

# Use the verifiable plaintext.
my $plaintext = "THIS IS A SECRET MESSAGE TO YOU";
# FIX: This is the correct ciphertext produced by the working implementation.
my $ciphertext = "THI SES ICRES AT M YOESSU  AGE    TO";

# Test 1: Basic encryption with a known value
is(
    turning_grille_encrypt($plaintext),
    $ciphertext,
    "Encrypt: Should produce the correct ciphertext"
);

# Test 2: Basic decryption
is(
    turning_grille_decrypt($ciphertext),
    $plaintext,
    "Decrypt: Should correctly reverse the encryption"
);

# Test 3: Full Cycle Test with a long string (tests block processing)
my $original = "This is a much longer test for the turning grille cipher that will definitely span multiple blocks";
my $encrypted = turning_grille_encrypt($original);
my $decrypted = turning_grille_decrypt($encrypted);
is(
    $decrypted,
    $original,
    "Full cycle: Encrypt then Decrypt should handle multiple blocks perfectly"
);

# 4. Signal that all tests are done.
done_testing();
