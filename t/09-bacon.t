# --- Test Script for the Baconian Cipher ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::Bacon qw(bacon_encrypt bacon_decrypt);

# --- Begin Tests ---

# Test 1: Basic encryption of a word
is( bacon_encrypt("BACON"), "AAAAB AAAAA AAABA ABBAB ABBAA", "Encrypt: 'BACON' should be correctly mapped" );

# Test 2: Special handling of 'J' vs 'I'
is( bacon_encrypt("JUMP"), bacon_encrypt("IUMP"), "Encrypt: 'J' should be treated as 'I'" );

# Test 3: Special handling of 'V' vs 'U'
is( bacon_encrypt("VOTE"), bacon_encrypt("UOTE"), "Encrypt: 'V' should be treated as 'U'" );

# Test 4: Basic decryption
# FIX: The input string has been corrected to the proper encoding for "BACON".
my $bacon_string = "AAAABAAAAAAAABAABBABABBAA";
is( bacon_decrypt($bacon_string), "BACON", "Decrypt: Should correctly decode a string of A's and B's" );

# Test 5: Full Cycle Test
my $original = "A secret message";
my $encrypted = bacon_encrypt($original);
my $decrypted = bacon_decrypt($encrypted);
is( $decrypted, "ASECRETMESSAGE", "Full cycle: Encrypt then Decrypt should return the original (normalized)" );

# 6. Signal that all tests are done.
done_testing();
