# --- Test Script for the Playfair Cipher ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::Playfair qw(playfair_encrypt playfair_decrypt);
use CriptoFEP::Utils qw(normalize_text);

# --- Begin Tests ---

# Use a standard, well-known key and plaintext for verification.
my $key = "PLAYFAIR EXAMPLE";
my $plaintext = "HIDE THE GOLD IN THE TREE STUMP";
# This is the known correct ciphertext for the above key and plaintext.
my $ciphertext = "BMODZBXDNABEKUDMUIXMMOUVIF";

# Test 1: Basic encryption with a known value
is(
    playfair_encrypt($plaintext, $key),
    $ciphertext,
    "Encrypt: Should produce the correct, standard ciphertext for the example"
);

# Test 2: Basic decryption
is(
    playfair_decrypt($ciphertext, $key),
    "HIDETHEGOLDINTHETREXESTUMP", # Note the 'X' inserted for the double 'E' in 'TREE'
    "Decrypt: Should correctly reverse the encryption"
);

# Test 3: Full Cycle Test
# This is the most robust test, as it doesn't depend on pre-calculated values.
my $original = "This is another test message for our playfair cipher";
my $encrypted = playfair_encrypt($original, $key);
my $decrypted = playfair_decrypt($encrypted, $key);

# Prepare the expected original text (normalized, with 'X' padding if needed)
my $expected_original = normalize_text($original);
$expected_original =~ s/J/I/g;
while ($expected_original =~ s/(.)\1/$1X$1/g) {}
if (length($expected_original) % 2 != 0) {
    $expected_original .= 'X';
}

is(
    $decrypted,
    $expected_original,
    "Full cycle: Encrypt then Decrypt should return the original (prepared) text"
);

# 4. Signal that all tests are done.
done_testing();
