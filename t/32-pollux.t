# --- Test Script for the Pollux Cipher ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::Pollux qw(pollux_encrypt pollux_decrypt);
use CriptoFEP::Utils qw(normalize_text);

# --- Begin Tests ---

# Use a standard, verifiable key and plaintext.
my $key = "316";
my $plaintext = "SOS";
# This is the known correct ciphertext for the above key and plaintext.
# Morse: ...x---x...
# Dots use (3,1,6), Seps use (0,2,4), Dashes use (5,7,8,9)
# ... -> 316, x -> 0, --- -> 578, x -> 2, ... -> 316
my $ciphertext = "31605782316";

# Test 1: Basic encryption with a known value
is(
    pollux_encrypt($plaintext, $key),
    $ciphertext,
    "Encrypt: Should produce the correct homophonic ciphertext"
);

# Test 2: Basic decryption
is(
    pollux_decrypt($ciphertext, $key),
    $plaintext,
    "Decrypt: Should correctly reverse the encryption"
);

# Test 3: Full Cycle Test
# This is the most robust test.
my $original = "A longer test message";
my $test_key = "987";
my $encrypted = pollux_encrypt($original, $test_key);
my $decrypted = pollux_decrypt($encrypted, $test_key);

is(
    $decrypted,
    normalize_text($original),
    "Full cycle: Encrypt then Decrypt should return the original (normalized)"
);

# 4. Signal that all tests are done.
done_testing();
