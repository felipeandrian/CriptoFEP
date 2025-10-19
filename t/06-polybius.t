# --- Test Script for the Polybius Square Cipher ---

# 1. Standard Pragmas
use strict;
use warnings;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::Polybius qw(polybius_encrypt polybius_decrypt);

# --- Begin Tests ---

# Test 1: Basic encryption of the first few letters
is( polybius_encrypt("ABC"), "111213", "Encrypt: 'ABC' should become '111213'" );

# Test 2: Encryption with letters from various parts of the grid
is( polybius_encrypt("POLYBIUS"), "3534315412244543", "Encrypt: 'POLYBIUS' should be correctly mapped" );

# Test 3: Special handling of 'J'
# The Polybius square treats 'J' as 'I'. This test ensures both letters produce
# the same output for an identical word stem.
is( polybius_encrypt("JUMP"), polybius_encrypt("IUMP"), "Encrypt: 'J' should be treated as 'I'" );

# Test 4: Basic Decryption
is( polybius_decrypt("111213"), "ABC", "Decrypt: '111213' should become 'ABC'" );

# Test 5: Full Cycle Test
# This is the most robust test: encrypting and then decrypting should yield
# the original (normalized) text.
my $original = "A secret message with J";
my $encrypted = polybius_encrypt($original);
my $decrypted = polybius_decrypt($encrypted);
is( $decrypted, "ASECRETMESSAGEWITHI", "Full cycle: Encrypt then Decrypt should return the original (normalized, with J->I)" );

# 6. Signal that all tests are done.
done_testing();
