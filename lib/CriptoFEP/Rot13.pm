package CriptoFEP::Rot13;

use strict;
use warnings;
use utf8;

# --- MODULE IMPORTS ---
use lib 'lib';
use CriptoFEP::Utils qw(normalize_text);

# --- EXPORTER CONFIGURATION ---
require Exporter;
our @ISA = qw(Exporter);
# Add 'info' to the list of functions that can be exported.
our @EXPORT_OK = qw(rot13_cipher info);

# --- CIPHER LOGIC ---

sub rot13_cipher {
    my ($text) = @_;
    my $normalized_text = normalize_text($text);
    
    # tr/// is the most efficient way to implement ROT13 in Perl.
    # It swaps the first half of the alphabet (A-M) with the second half (N-Z).
    $normalized_text =~ tr/A-Z/N-ZA-M/;
    
    return $normalized_text;
}

# --- DOCUMENTATION SUBROUTINE ---

sub info {
    return qq(CIPHER: ROT13 Cipher

DESCRIPTION:
    A simple substitution cipher that replaces a letter with the 13th letter
    after it in the alphabet. ROT13 is a special case of the Caesar cipher.
    It is not intended for security, but is often used in online forums to
    hide spoilers, punchlines, or puzzle solutions.

MECHANISM:
    - The mapping is fixed and requires no key.
    - It is a reciprocal cipher (its own inverse). Applying ROT13 twice to a
      piece of text will restore the original text. This works because the
      alphabet has 26 letters, and 2 * 13 = 26.
    - The alphabet is split into two halves (A-M and N-Z), which are swapped.
    - Example: 'HELLO' becomes 'URYYB'.

MANUAL DECRYPTION:
    Because ROT13 is its own inverse, the decryption process is identical to
    the encryption process.

    - To decrypt a letter, simply shift it 13 places forward in the alphabet.
    - Example: Let's decrypt 'U'.
        1. Find 'U' in the alphabet.
        2. Count 13 letters forward: V, W, X, Y, Z, A, B, C, D, E, F, G, H.
        3. The 13th letter is 'H'. Therefore, 'U' decrypts to 'H'.
);
}

# --- MODULE SUCCESS ---
1;