# --- Test Script for the Bifid Cipher ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::Bifid qw(bifid_encrypt bifid_decrypt);
use CriptoFEP::Utils qw(normalize_text);

# --- Begin Tests ---

# FIX: These are the mathematically correct values for the implementation.
my $key = "SECRET";
my $plaintext = "FUGA";
my $ciphertext = "FBUV";

# Test 1: Basic encryption with a known value
is(
    bifid_encrypt($plaintext, $key),
    $ciphertext,
    "Encrypt: Should produce the correct ciphertext for 'FUGA'"
);

# Test 2: Basic decryption
is(
    bifid_decrypt($ciphertext, $key),
    $plaintext,
    "Decrypt: Should correctly reverse the encryption"
);

# Test 3: Full Cycle Test
my $original = "This is a much longer test for the bifid cipher";
my $test_key = "CRYPTO";
my $encrypted = bifid_encrypt($original, $test_key);
my $decrypted = bifid_decrypt($encrypted, $test_key);

is(
    $decrypted,
    normalize_text($original =~ s/J/I/gr),
    "Full cycle: Encrypt then Decrypt should return the original (normalized)"
);

# 4. Signal that all tests are done.
done_testing();
