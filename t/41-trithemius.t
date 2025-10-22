# --- Test Script for the Trithemius Cipher ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::Trithemius qw(trithemius_encrypt trithemius_decrypt);
use CriptoFEP::Utils qw(normalize_text);

# --- Begin Tests ---

# Exemplo clássico
my $plaintext = "CAT";
# C + 0 = C
# A + 1 = B
# T + 2 = V
my $ciphertext = "CBV";


# Test 1: Basic encryption
is( 
    trithemius_encrypt($plaintext), 
    $ciphertext, 
    "Encrypt: 'CAT' should become 'CBV'" 
);

# Test 2: Basic decryption
is( 
    trithemius_decrypt($ciphertext),
    normalize_text($plaintext),
    "Decrypt: 'CBV' should become 'CAT'"
);

# Test 3: Full Cycle Test (com wrap-around do shift)
my $original = "THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG"; # Texto longo
my $encrypted = trithemius_encrypt($original);
my $decrypted = trithemius_decrypt($encrypted);
is( 
    $decrypted, 
    normalize_text($original),
    "Full cycle: Encrypt then Decrypt should return the original (normalized)" 
);

# 4. Signal that all tests are done.
done_testing();
