# --- Test Script for the Four-Square Cipher ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::FourSquare qw(four_square_encrypt four_square_decrypt);
use CriptoFEP::Utils qw(normalize_text);

# --- Begin Tests ---

# Use a standard, verifiable key and plaintext.
my $key1 = "EXAMPLE";
my $key2 = "KEYWORD";
my $plaintext = "HELP ME";
# This is the known correct ciphertext for the above keys and plaintext.
my $ciphertext = "FYNFNE";

# Test 1: Basic encryption with a known value
is(
    four_square_encrypt($plaintext, [$key1, $key2]),
    $ciphertext,
    "Encrypt: Should produce the correct ciphertext"
);

# Test 2: Basic decryption
is(
    four_square_decrypt($ciphertext, [$key1, $key2]),
    "HELPME", # The normalized/padded version
    "Decrypt: Should correctly reverse the encryption"
);

# Test 3: Full Cycle Test
# This is the most robust test.
my $original = "This is a much longer test for the four square cipher";
my $encrypted = four_square_encrypt($original, [$key1, $key2]);
my $decrypted = four_square_decrypt($encrypted, [$key1, $key2]);

# Prepare the expected original text (normalized and padded if needed)
my $expected_original = normalize_text($original);
$expected_original =~ s/J/I/g;
$expected_original .= 'X' if length($expected_original) % 2 != 0;

is(
    $decrypted,
    $expected_original,
    "Full cycle: Encrypt then Decrypt should return the original (prepared) text"
);

# 4. Signal that all tests are done.
done_testing();
