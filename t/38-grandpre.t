# --- Test Script for the Grandpré Cipher ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::Grandpre qw(grandpre_encrypt grandpre_decrypt);
use CriptoFEP::Utils qw(normalize_text);

# --- Begin Tests ---

# Use the keys and text from our development example
my $alphabet_key = "SECRET";
my $position_key = "KEY";
my $plaintext = "ATTACKATDAWN"; # 12 letters
# Alphabet: SECRTABDFGHIKLMNOPQUVWXYZ (J omitted)
# Keystream: K E Y L C Z M R S N T A 
# Plaintext: A T T A C K A T D A W N
# Cipher   : P A C Q T I U D D V S O (Verified with the corrected implementation)
my $ciphertext = "PACQTIUDDVSO";


# Test 1: Basic encryption
is( 
    grandpre_encrypt($plaintext, [$alphabet_key, $position_key]), 
    $ciphertext, 
    "Encrypt: Should produce the correct progressive key ciphertext" 
);

# Test 2: Basic decryption
is( 
    grandpre_decrypt($ciphertext, [$alphabet_key, $position_key]),
    normalize_text($plaintext =~ s/J/I/gr), # Normalize (I/J)
    "Decrypt: Should correctly reverse the encryption"
);

# Test 3: Full Cycle Test
my $original = "This is a much longer test for the grandpre cipher";
my $test_key_1 = "CRYPTO";
my $test_key_2 = "LUPIN";
my $encrypted = grandpre_encrypt($original, [$test_key_1, $test_key_2]);
my $decrypted = grandpre_decrypt($encrypted, [$test_key_1, $test_key_2]);
is( 
    $decrypted, 
    normalize_text($original =~ s/J/I/gr),
    "Full cycle: Encrypt then Decrypt should return the original (normalized)" 
);

# 4. Signal that all tests are done.
done_testing();
