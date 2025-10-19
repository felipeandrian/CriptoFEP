# --- Test Script for the Atbash Cipher ---

# 1. Standard Pragmas
use strict;
use warnings;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Function to be Tested
use CriptoFEP::Atbash qw(atbash_cipher);

# --- Begin Tests ---

# Test 1: Basic alphabet reversal
is( atbash_cipher("ABC"), "ZYX", "Encrypt: 'ABC' should become 'ZYX'" );

# Test 2: A common test word
is( atbash_cipher("WIZARD"), "DRAZIW", "Encrypt: 'WIZARD' should become 'DRAZIW'" );

# Test 3: Normalization test with mixed case and symbols
is( atbash_cipher("Hello World!"), "SVOOLDLIOW", "Encrypt: Should handle mixed case, spaces, and symbols" );

# Test 4: Full Cycle Test (proves it is its own inverse)
# This is the most important test for a reciprocal cipher.
# We apply the same function twice and expect the original text back.
my $original = "secret message";
my $encrypted = atbash_cipher($original);
my $decrypted = atbash_cipher($encrypted); # Apply the same function again
is( $decrypted, "SECRETMESSAGE", "Full cycle: Applying Atbash twice should return the original (normalized)" );

# 5. Signal that all tests are done.
done_testing();
