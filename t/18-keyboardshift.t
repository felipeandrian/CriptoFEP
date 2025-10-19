# --- Test Script for the Keyboard Shift Cipher ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::KeyboardShift qw(keyboard_shift_encrypt keyboard_shift_decrypt);

# --- Begin Tests ---

# Test 1: Basic encryption with a known value
is(
    keyboard_shift_encrypt("HELLO"),
    "JRAAP",
    "Encrypt: 'HELLO' should become 'JRAAP'"
);

# Test 2: Encryption should preserve case, spaces, and symbols
# FIX: The expected value has been corrected to match the program's correct output.
is(
    keyboard_shift_encrypt("Hello World 123!"),
    "Jraap Eptaf 123!",
    "Encrypt: Should preserve case, spaces, and non-mappable characters"
);

# Test 3: Basic decryption
is(
    keyboard_shift_decrypt("JRAAP"),
    "HELLO",
    "Decrypt: 'JRAAP' should become 'HELLO'"
);

# Test 4: Full Cycle Test
my $original = "A quick brown fox jumps over the lazy dog.";
my $encrypted = keyboard_shift_encrypt($original);
my $decrypted = keyboard_shift_decrypt($encrypted);
is(
    $decrypted,
    $original,
    "Full cycle: Encrypt then Decrypt should return the original text perfectly"
);

# 5. Signal that all tests are done.
done_testing();
