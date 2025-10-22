# --- Test Script for the Porta Cipher ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Function to be Tested
use CriptoFEP::Porta qw(porta_cipher);
use CriptoFEP::Utils qw(normalize_text);

# --- Begin Tests ---

my $plaintext = "WELCOMETOTHEWORLD";
my $key = "FORTUNE";
my $ciphertext = "HYTYESTEHLQODMCSY";


# Test 1: Basic encryption
is( 
    porta_cipher($plaintext, $key), 
    $ciphertext, 
    "Encrypt: Should produce the correct ciphertext 'HYTYESTEHLQODMCSY'" 
);

# Test 2: Basic decryption (proves symmetry)
is( 
    porta_cipher($ciphertext, $key),
    normalize_text($plaintext),
    "Decrypt: Applying the same function should return the original text"
);

# Test 3: Full Cycle Test
my $original = "THIS IS A TEST OF THE PORTA CIPHER";
my $test_key = "LEMON";
my $encrypted = porta_cipher($original, $test_key);
my $decrypted = porta_cipher($encrypted, $test_key); # Aplica a mesma função novamente
is( 
    $decrypted, 
    normalize_text($original),
    "Full cycle: Applying the cipher twice should return the original (normalized)" 
);

# 4. Signal that all tests are done.
done_testing();
