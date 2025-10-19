# --- Test Script for the Albam Cipher ---

# 1. Standard Pragmas
use strict;
use warnings;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Function to be Tested
use CriptoFEP::Albam qw(albam_cipher);

# --- Begin Tests ---

# Test 1: Basic substitution (first half of the alphabet)
is( albam_cipher("ABC"), "NOP", "Encrypt: 'ABC' should become 'NOP'" );

# Test 2: Basic substitution (second half of the alphabet)
is( albam_cipher("NOP"), "ABC", "Encrypt: 'NOP' should become 'ABC', proving the swap" );

# Test 3: Normalization test with a full phrase
is( albam_cipher("Hello World!"), "URYYBJBEYQ", "Encrypt: Should handle mixed case, spaces, and symbols" );

# Test 4: Full Cycle Test (proves it is its own inverse)
# We apply the same function twice and expect the original text back.
my $original = "secret message";
my $encrypted = albam_cipher($original);
my $decrypted = albam_cipher($encrypted); # Apply the same function again
is( $decrypted, "SECRETMESSAGE", "Full cycle: Applying Albam twice should return the original (normalized)" );

# 5. Signal that all tests are done.
done_testing();
