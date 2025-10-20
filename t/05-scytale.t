# --- Test Script for the Scytale Cipher ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::Scytale qw(scytale_encrypt scytale_decrypt);

# --- Begin Tests ---


my $plaintext  = "WE ARE DISCOVERED FLEE AT ONCE";

my $ciphertext = "W VFTEDEL  IREOASEENRCD CEO AE";

# Test 1: Basic encryption with a known value
is(
    scytale_encrypt($plaintext),
    $ciphertext,
    "Encrypt: Should produce the correct ciphertext"
);

# Test 2: Basic decryption
is(
    scytale_decrypt($ciphertext),
    $plaintext,
    "Decrypt: Should correctly reverse the encryption"
);

# Test 3: Full Cycle Test
my $original_text = "This is a test of the Scytale cipher module";
my $encrypted = scytale_encrypt($original_text);
my $decrypted = scytale_decrypt($encrypted);
is(
    $decrypted,
    $original_text,
    "Full cycle: Encrypt then Decrypt should return the original perfectly"
);

# 4. Signal that all tests are done.
done_testing();
