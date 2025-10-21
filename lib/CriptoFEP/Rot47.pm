#
# CriptoFEP::Rot47
#
# This module provides the implementation for the ROT47 cipher.
# It is a reciprocal shift cipher that operates on the full range
# of printable ASCII characters, not just the alphabet.
#
package CriptoFEP::Rot47;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;
use utf8; # Ensures Perl handles Unicode strings correctly.

# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(rot47_cipher info);

# --- CIPHER LOGIC ---

=head2 rot47_cipher
 
 Performs the ROT47 substitution on a given text.
 Since ROT47 is a reciprocal (involutory) cipher, this single function
 handles both encryption and decryption.
 
 B<Parameters:>
   - $text (string): The text (or ciphertext) to be transformed.
 
 B<Returns:>
   - (string): The resulting transformed text.
 
=cut
sub rot47_cipher {
    my ($text) = @_;
    
    # IMPORTANT: Text is not normalized as ROT47 operates on all printable ASCII characters.
    
    # tr/// (transliteration) is the most efficient way to implement ROT47.
    # It "rotates" the 94 printable ASCII characters from ! (code 33) to ~ (code 126).
    # The range !-~ is mapped to P-~!-O, effectively shifting every
    # character by 47 positions within that range.
    $text =~ tr/\!-~/P-~\!-O/;
    
    return $text;
}

# --- DOCUMENTATION SUBROUTINE ---

=head2 info
 
 Returns a formatted string with detailed information about the ROT47 cipher.
 This serves as the dynamic help text for the '--info' command-line option.
 
 B<Parameters:> None
 
 B<Returns:>
   - (string): A multi-line help text.
 
=cut
sub info {
    return qq(CIPHER: ROT47 Cipher

DESCRIPTION:
    A variant of the Caesar cipher that operates on a larger set of characters.
    While ROT13 only affects letters, ROT47 applies a 47-position shift to all
    printable ASCII characters, from '!' (code 33) to '~' (code 126).

MECHANISM:
    - The mapping is fixed and requires no key.
    - It is a reciprocal cipher (its own inverse). The range of characters used
      is 94, and 2 * 47 = 94, making the operation perfectly symmetrical.
    - Unlike most classic ciphers, it affects letters (upper and lower case),
      numbers, and common symbols.
    - Example: 'CriptoFEP 2025!' becomes 'rC:A@~t6! a_a_P'.

MANUAL DECRYPTION:
    Because ROT47 is its own inverse, the decryption process is identical to
    the encryption process.

    - To decrypt a character, find its position within the printable ASCII range
      (from '!' to '~') and find the character that is 47 places after it,
      wrapping around if necessary.
    - Example: Let's decrypt 'r'.
        1. Find 'r' in the ASCII table.
        2. Count 47 characters forward (wrapping around from '~' back to '!').
        3. The 47th character after 'r' is 'C'. Therefore, 'r' decrypts to 'C'.
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;