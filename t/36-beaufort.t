# --- Test Script for the Beaufort Cipher ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Function to be Tested
use CriptoFEP::Beaufort qw(beaufort_cipher);
use CriptoFEP::Utils qw(normalize_text);

# --- Begin Tests ---

my $plaintext = "ATTACK";
my $key = "LEMON";
# C = (K - P) mod 26
# (L-A)=11(L), (E-T)=-15=11(L), (M-T)=-7=19(T), (O-A)=14(O), (N-C)=11(L), (L-K)=1(B)
my $ciphertext = "LLTOLB";

# Test 1: Basic encryption
is( 
    beaufort_cipher($plaintext, $key), 
    $ciphertext, 
    "Encrypt: Should produce the correct ciphertext 'LLTOLB'" 
);

# Test 2: Basic decryption (proves symmetry)
# A função é a sua própria inversa
is( 
    beaufort_cipher($ciphertext, $key),
    normalize_text($plaintext),
    "Decrypt: Applying the same function should return the original text"
);

# Test 3: Full Cycle Test
my $original = "This is a much longer test for the Beaufort cipher";
my $test_key = "SECRETKEY";
my $encrypted = beaufort_cipher($original, $test_key);
my $decrypted = beaufort_cipher($encrypted, $test_key); # Aplica a mesma função novamente
is( 
    $decrypted, 
    normalize_text($original),
    "Full cycle: Applying the cipher twice should return the original (normalized)" 
);

# 4. Signal that all tests are done.
done_testing();
