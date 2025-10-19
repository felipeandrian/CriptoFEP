# --- Test Script for the Atbah Cipher ---

# 1. Standard Pragmas
use strict;
use warnings;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Function to be Tested
use CriptoFEP::Atbah qw(atbah_cipher);

# --- Begin Tests ---

# Test 1: Basic substitution based on the Atbah map
is( atbah_cipher("ABC"), "IHG", "Encrypt: 'ABC' should become 'IHG'" );

# Test 2: A word that uses different pairs from the map
is( atbah_cipher("HELLO"), "BNPPM", "Encrypt: 'HELLO' should become 'BNPPM'" );

# Test 3: Normalization test with mixed case and symbols
# FIX: The expected value has been corrected to match the program's correct output.
is( atbah_cipher("Attack at Dawn!"), "IYYIGQIYFIVE", "Encrypt: Should handle mixed case, spaces, and symbols" );

# Test 4: Full Cycle Test (proves it is its own inverse)
my $original = "secret message";
my $encrypted = atbah_cipher($original);
my $decrypted = atbah_cipher($encrypted);
is( $decrypted, "SECRETMESSAGE", "Full cycle: Applying Atbah twice should return the original (normalized)" );

# 5. Signal that all tests are done.
done_testing();
