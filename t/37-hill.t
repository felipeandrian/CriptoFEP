# --- Test Script for the Hill Cipher (2x2) ---

# 1. Standard Pragmas
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;
use utf8; # Ensures Perl handles Unicode strings correctly.

# 2. Load the Testing Library
# Test::More is the standard, core Perl module for writing tests.
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
# This tells the test script where to find our custom modules.
use lib 'lib';

# 4. Import the Functions to be Tested
# We import the functions from the module we are testing.
use CriptoFEP::Hill qw(hill_encrypt hill_decrypt);
# We also import the normalizer for our full cycle test.
use CriptoFEP::Utils qw(normalize_text);

# --- Begin Tests ---

# --- Test Case 1: Valid Key Encryption/Decryption ---

# Use a standard, verifiable key and plaintext.
my $plaintext = "HELP";
my $key = "HILL"; # This is a valid key: det(15), inv(7)
# Manual calculation for verification:
# H(7), E(4) -> (7*7+8*4)%26=3(D), (11*7+11*4)%26=17(R)
# L(11), P(15) -> (7*11+8*15)%26=15(P), (11*11+11*15)%26=0(A)
my $ciphertext = "DRPA";

# Test 1: Basic encryption
# Check if the encrypt function produces the known correct ciphertext.
is(
    hill_encrypt($plaintext, $key),
    $ciphertext,
    "Encrypt: 'HELP' with key 'HILL' should be 'DRPA'"
);

# Test 2: Basic decryption
# Check if the decrypt function correctly reverses the operation.
is(
    hill_decrypt($ciphertext, $key),
    normalize_text($plaintext),
    "Decrypt: 'DRPA' with key 'HILL' should be 'HELP'"
);

# Test 3: Full Cycle Test (with padding)
# This is the most robust test, as it doesn't rely on pre-calculated values.
my $original = "A secret message"; # 15 letters (will be padded to 16)
my $encrypted = hill_encrypt($original, $key);
my $decrypted = hill_decrypt($encrypted, $key);

# The expected result is the original text, normalized.
# The `hill_decrypt` function should correctly handle the 'X' padding
# that `hill_encrypt` added.
is(
    $decrypted,
    normalize_text($original),
    "Full cycle: Encrypt then Decrypt should return the original (normalized)"
);

# --- Test Case 2: Invalid Key Handling ---

# Test 4: Invalid Key Test
# The key "ABCD" has a determinant of 24 (-2), which is not coprime with 26.
my $invalid_key = "ABCD";
# 'eval' provides a safe way to execute code that we *expect* to 'die'.
eval { hill_decrypt("TEST", $invalid_key); };
# If the 'die' command was successfully executed, the special variable $@ will be set.
# 'ok($@)' checks that our program correctly threw a fatal error as intended.
ok( $@, "Decrypt: Should fail (die) when using an invalid (non-invertible) key" );


# 5. Signal that all tests are done.
# This tells Test::More how many tests were planned and to finalize the report.
done_testing();
