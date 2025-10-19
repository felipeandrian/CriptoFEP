# --- Test Script for the Digrafid Cipher ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::Digrafid qw(digrafid_encrypt digrafid_decrypt);
use CriptoFEP::Utils qw(normalize_text);

# --- Begin Tests ---

# Use an empty key for a predictable, standard grid to verify the core logic.
my $key = "";
my $plaintext = "ATTACK";
# This is the correct ciphertext for a standard, unshuffled 25x25 grid.
my $ciphertext = "ATCTAK";

# Test 1: Basic encryption with a known value (standard grid)
is(
    digrafid_encrypt($plaintext, $key),
    $ciphertext,
    "Encrypt: Should produce the correct ciphertext with a standard grid"
);

# Test 2: Basic decryption (standard grid)
is(
    digrafid_decrypt($ciphertext, $key),
    $plaintext,
    "Decrypt: Should correctly reverse the encryption with a standard grid"
);

# Test 3: Full Cycle Test with a keyed grid
# This is the most robust test.
my $original = "This is a long test for the digrafid cipher";
my $test_key = "SECRETKEY";
my $encrypted = digrafid_encrypt($original, $test_key);
my $decrypted = digrafid_decrypt($encrypted, $test_key);

# Prepare the expected original text (normalized and padded if needed)
my $expected_original = normalize_text($original);
$expected_original =~ s/J/I/g;
$expected_original .= 'X' if length($expected_original) % 2 != 0;

is(
    $decrypted,
    $expected_original,
    "Full cycle: Encrypt then Decrypt should return the original (prepared) text with a keyed grid"
);

# 4. Signal that all tests are done.
done_testing();
