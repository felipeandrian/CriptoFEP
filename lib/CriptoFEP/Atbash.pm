#
# CriptoFEP::Atbash
#
# This module provides the implementation for the Atbash cipher, a simple
# reciprocal substitution cipher that reverses the alphabet.
#
package CriptoFEP::Atbash;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;

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
our @EXPORT_OK = qw(atbash_cipher info);

# --- CIPHER LOGIC ---

=head2 atbash_cipher
 
 Performs the Atbash substitution on a given text.
 Since Atbash is a reciprocal (involutory) cipher, this single function
 handles both encryption and decryption.
 
 B<Parameters:>
   - $text (string): The plaintext (or ciphertext) to be transformed.
 
 B<Returns:>
   - (string): The resulting ciphertext (or plaintext).
 
=cut
sub atbash_cipher {
    my ($text) = @_;
    # Sanitize the input to uppercase A-Z characters only.
    my $normalized_text = normalize_text($text);
    
    # This is a highly efficient way to reverse the alphabet.
    # The tr/// (transliteration) operator is a built-in Perl function
    # that swaps characters from the first set (A-Z) to the
    # corresponding character in the second set (Z-A) in a single operation.
    $normalized_text =~ tr/ABCDEFGHIJKLMNOPQRSTUVWXYZ/ZYXWVUTSRQPONMLKJIHGFEDCBA/;
    
    return $normalized_text;
}

# --- DOCUMENTATION SUBROUTINE ---

=head2 info
 
 Returns a formatted string with detailed information about the Atbash cipher.
 This serves as the dynamic help text for the '--info' command-line option.
 
 B<Parameters:> None
 
 B<Returns:>
   - (string): A multi-line help text.
 
=cut
sub info {
    return qq(CIPHER: Atbash Cipher

DESCRIPTION:
    An ancient and simple substitution cipher originally used for the Hebrew
    alphabet. It works by reversing the alphabet, effectively creating a
    "mirror" image of the plaintext.

MECHANISM:
    - The mapping is fixed and requires no key.
    - The first letter ('A') is swapped with the last ('Z'), the second ('B')
      with the second-to-last ('Y'), and so on.
    - It is its own inverse, meaning the exact same process is used for both
      encryption and decryption. Applying the cipher twice returns the original text.
    - Example: 'WIZARD' becomes 'DRAZIW'.

MANUAL DECRYPTION:
    Because the Atbash cipher is its own inverse, the decryption process is
    identical to the encryption process.

    - To decrypt a letter, simply find its reverse counterpart.
    - Example: Let's decrypt 'S'.
        1. 'S' is the 19th letter of the alphabet.
        2. The 19th letter from the *end* of the alphabet is 'H'.
        3. Therefore, 'S' decrypts (and encrypts) to 'H'.

CURIOSITY:
    On Unix-like systems, you can simulate the Atbash cipher using the 'tr' command
    by mapping the alphabet to its reverse explicitly. For example:
        echo "WIZARD" | tr "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz" \\
        "ZYXWVUTSRQPONMLKJIHGFEDCBAzyxwvutsrqponmlkjihgfedcba"
    Output: DRAZIW
    Running the same command again on 'DRAZIW' returns the original 'WIZARD',
    since Atbash is its own inverse.
);

}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;