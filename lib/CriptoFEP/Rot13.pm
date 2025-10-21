#
# CriptoFEP::Rot13
#
# This module provides the implementation for the ROT13 cipher. It is a
# simple, reciprocal Caesar cipher with a fixed shift of 13.
#
package CriptoFEP::Rot13;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;
use utf8; # Ensures Perl handles Unicode strings correctly.

# --- MODULE IMPORTS ---
# Add the parent 'lib' directory to Perl's search path.
use lib 'lib';
# Import shared utilities for text normalization.
use CriptoFEP::Utils qw(normalize_text);

# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Add 'info' to the list of functions that can be exported.
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(rot13_cipher info);

# --- CIPHER LOGIC ---

=head2 rot13_cipher
 
 Performs the ROT13 substitution on a given text.
 Since ROT13 is a reciprocal (involutory) cipher, this single function
 handles both encryption and decryption.
 
 B<Parameters:>
   - $text (string): The plaintext (or ciphertext) to be transformed.
 
 B<Returns:>
   - (string): The resulting ciphertext (or plaintext).
 
=cut
sub rot13_cipher {
    my ($text) = @_;
    # Sanitize the input to uppercase A-Z characters only.
    my $normalized_text = normalize_text($text);
    
    # tr/// is the most efficient way to implement ROT13 in Perl.
    # It transliterates (swaps) characters from the first set (A-Z)
    # to the corresponding character in the second set (N-ZA-M).
    # A-M are mapped to N-Z.
    # N-Z are mapped back to A-M.
    $normalized_text =~ tr/A-Z/N-ZA-M/;
    
    return $normalized_text;
}

# --- DOCUMENTATION SUBROUTINE ---

=head2 info
 
 Returns a formatted string with detailed information about the ROT13 cipher.
 This serves as the dynamic help text for the '--info' command-line option.
 
 B<Parameters:> None
 
 B<Returns:>
   - (string): A multi-line help text.
 
=cut
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
# Every Perl module must end with a true value to indicate successful loading.
1;