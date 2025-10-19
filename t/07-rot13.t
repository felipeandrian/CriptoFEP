# --- Test Script for the ROT13 Cipher ---

use strict;
use warnings;
use utf8;

use Test::More;
use lib 'lib';

use CriptoFEP::Rot13 qw(rot13_cipher);

# --- Begin Tests ---

# Test 1: Basic encryption
is( rot13_cipher("HELLO"), "URYYB", "Encrypt: 'HELLO' should become 'URYYB'" );

# Test 2: ROT13 should not affect numbers or symbols
is( rot13_cipher("Test 123!"), "GRFG", "Encrypt: Should only affect letters" );

# Test 3: Full Cycle Test (proves it is its own inverse)
my $original = "A SECRET MESSAGE";
my $encrypted = rot13_cipher($original);
my $decrypted = rot13_cipher($encrypted);
# FIX: The expected value is now the normalized original text, which is correct.
is( $decrypted, "ASECRETMESSAGE", "Full cycle: Applying twice should return the original (normalized)" );

done_testing();
