# --- Test Script for the Two-Square Cipher ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::TwoSquare qw(two_square_encrypt two_square_decrypt);
use CriptoFEP::Utils qw(normalize_text);

# --- Begin Tests ---

# These are the correct, verified values for this example.
my $key1 = "EXAMPLE";
my $key2 = "SECRET";
my $plaintext = "HELP ME";
my $ciphertext = "HECNXR";

# Test 1: Basic encryption with a known value
is(
    two_square_encrypt($plaintext, [$key1, $key2]),
    $ciphertext,
    "Encrypt: Should produce the correct ciphertext"
);

# Test 2: Test the cipher's symmetry for decryption
is(
    two_square_decrypt($ciphertext, [$key1, $key2]),
    normalize_text($plaintext =~ s/J/I/gr),
    "Decrypt: Should correctly reverse the encryption"
);

# Test 3: Full Cycle Test
my $original = "This is a much longer test for the two square cipher";
my $encrypted = two_square_encrypt($original, [$key1, $key2]);
my $decrypted = two_square_decrypt($encrypted, [$key1, $key2]);

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
