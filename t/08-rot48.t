# --- Test Script for the ROT47 Cipher ---

use strict;
use warnings;
use utf8;

use Test::More;
use lib 'lib';

use CriptoFEP::Rot47 qw(rot47_cipher);

# --- Begin Tests ---

# Test 1: Basic ROT47 encryption with letters, numbers, and symbols
# FIX: The expected value has been corrected to match the program's correct output.
is( rot47_cipher('ABC 123 !@#'), 'pqr `ab PoR', "Encrypt: Should affect letters, numbers, and symbols" );

# Test 2: ROT47 Full Cycle Test (proves it is its own inverse)
my $original = "A Top Secret Message!! (v1.0)";
is( rot47_cipher(rot47_cipher($original)), $original, "Full cycle: Applying twice should return the original" );

# 3. Signal that all tests are done.
done_testing();
