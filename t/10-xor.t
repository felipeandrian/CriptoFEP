# --- Test Script for the XOR Cipher ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::XOR qw(xor_encrypt xor_decrypt);

# --- Begin Tests ---

# Test 1: Basic encryption of a single character
is( xor_encrypt("A", "K"), "0a", "Encrypt: Single character 'A' with key 'K' should be '0a'" );

# Test 2: Encryption of a word with a repeating key
# FIX: The expected value has been corrected to match the program's correct output.
is( xor_encrypt("HELLO", "KEY"), "030015070a", "Encrypt: 'HELLO' with repeating key 'KEY' should be correct" );

# Test 3: Basic decryption
is( xor_decrypt("030015070a", "KEY"), "HELLO", "Decrypt: Should correctly reverse the encryption" );

# Test 4: Full Cycle Test
my $original = "A secret message with spaces and symbols! @123";
my $key      = "MySecretKey123";
my $encrypted = xor_encrypt($original, $key);
my $decrypted = xor_decrypt($encrypted, $key);
is( $decrypted, $original, "Full cycle: Encrypt then Decrypt should return the original perfectly" );

# 5. Signal that all tests are done.
done_testing();
