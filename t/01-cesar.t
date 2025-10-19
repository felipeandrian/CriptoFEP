# --- Test Script for the Caesar Cipher ---

# 1. Standard Pragmas
use strict;
use warnings;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::Cesar qw(cesar_encrypt cesar_decrypt);

# --- Begin Tests ---

# Test 1: Basic encryption
is( cesar_encrypt("ABC"), "DEF", "Encrypt: 'ABC' should become 'DEF'" );

# Test 2: Encryption with alphabet wrap-around
is( cesar_encrypt("XYZ"), "ABC", "Encrypt: 'XYZ' should wrap around to 'ABC'" );

# Test 3: Encryption with mixed case and symbols (tests normalization)
# FIX: The expected value has been corrected to match the program's correct output.
is( cesar_encrypt("Ataque ao Amanhecer!"), "DWDTXHDRDPDQKHFHU", "Encrypt: Should handle mixed case, spaces, and symbols" );

# Test 4: Basic decryption
is( cesar_decrypt("DEF"), "ABC", "Decrypt: 'DEF' should become 'ABC'" );

# Test 5: Decryption with alphabet wrap-around
is( cesar_decrypt("ABC"), "XYZ", "Decrypt: 'ABC' should wrap around to 'XYZ'" );

# Test 6: Full Cycle Test
my $original = "texto super secreto";
my $encrypted = cesar_encrypt($original);
my $decrypted = cesar_decrypt($encrypted);
is( $decrypted, "TEXTOSUPERSECRETO", "Full cycle: Encrypt then Decrypt should return the original (normalized)" );

# 7. Signal that all tests are done.
done_testing();
