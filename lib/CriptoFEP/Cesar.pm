#
# CriptoFEP::Cesar
#
# This module provides the implementation for the Caesar cipher,
# a simple substitution cipher. It includes functions for both encryption
# and decryption, as well as a self-documenting info function.
#

package CriptoFEP::Cesar;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;

# --- MODULE IMPORTS ---
# Add the parent 'lib' directory to Perl's search path to find our custom modules.
use lib 'lib';
# Import shared utilities: text normalization and alphabet mappings from the Utils module.
use CriptoFEP::Utils qw(normalize_text $alphabet_list_ref $alphabet_map_ref);

# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(cesar_encrypt cesar_decrypt info);


# --- CIPHER SUBROUTINES ---

=head2 cesar_encrypt
 
 Encrypts a given text using the Caesar cipher with a fixed shift.
 
 B<Parameters:>
   - $text (string): The plaintext to be encrypted.
   - $shift (integer, optional): The number of positions to shift. Defaults to 3.
 
 B<Returns:>
   - (string): The resulting ciphertext, normalized to uppercase letters.
 
=cut
sub cesar_encrypt {
    # Unpack function arguments.
    my ($text, $shift) = @_;
    # Default to a shift of 3 if not provided.
    $shift //= 3;

    # Sanitize the input text to uppercase A-Z characters only.
    my $normalized_text = normalize_text($text);
    my $ciphertext = "";

    # Iterate over each character of the normalized plaintext.
    foreach my $char (split //, $normalized_text) {
        # Convert the character to its 0-25 numeric representation (A=0, B=1, ...).
        my $index = $alphabet_map_ref->{$char};
        # Apply the encryption formula: E(x) = (x + b) mod 26.
        # The modulo operator (%) handles the alphabet wrap-around.
        my $new_index = ($index + $shift) % 26;
        # Convert the new numeric index back to a character and append it.
        $ciphertext .= $alphabet_list_ref->[$new_index];
    }
    
    return $ciphertext;
}

=head2 cesar_decrypt
 
 Decrypts a given text that was encrypted with the Caesar cipher.
 
 B<Parameters:>
   - $text (string): The ciphertext to be decrypted.
   - $shift (integer, optional): The number of positions to shift back. Defaults to 3.
 
 B<Returns:>
   - (string): The resulting plaintext, normalized to uppercase letters.
 
=cut
sub cesar_decrypt {
    # Unpack function arguments.
    my ($text, $shift) = @_;
    # Default to a shift of 3 if not provided.
    $shift //= 3;

    # Sanitize the input text.
    my $normalized_text = normalize_text($text);
    my $plaintext = "";

    # Iterate over each character of the normalized ciphertext.
    foreach my $char (split //, $normalized_text) {
        # Convert the character to its 0-25 numeric representation.
        my $index = $alphabet_map_ref->{$char};
        # Apply the decryption formula: D(y) = (y - b) mod 26.
        # Adding 26 before the modulo ensures the result is always positive,
        # correctly handling wrap-around for letters like A, B, C.
        my $new_index = ($index - $shift + 26) % 26;
        # Convert the new numeric index back to a character and append it.
        $plaintext .= $alphabet_list_ref->[$new_index];
    }
    
    return $plaintext;
}

=head2 info
 
 Returns a formatted string containing detailed information about the Caesar cipher.
 This serves as the dynamic help text for the '--info' command-line option.
 
 B<Parameters:> None
 
 B<Returns:>
   - (string): A multi-line help text.
 
=cut
sub info {
    # qq() is used for a clean, multi-line string that allows variable interpolation
    # and respects formatting, making the help text easy to read and maintain.
    return qq(CIPHER: Caesar Cipher

DESCRIPTION:
    One of the simplest and most widely known encryption techniques. It is a
    type of substitution cipher in which each letter in the plaintext is replaced
    by a letter some fixed number of positions down the alphabet.

MECHANISM (ENCRYPTION):
    - The CriptoFEP version uses a fixed shift of 3 positions.
    - Formula: E(x) = (x + 3) mod 26
    - The alphabet wraps around (e.g., encrypting 'Z' results in 'C').
    - Non-alphabetic characters are removed before encryption.
    - Example: 'ATTACK' becomes 'DWWDFN'.

MANUAL DECRYPTION:
    To decrypt a message by hand, you simply reverse the process: for each
    letter, you shift it back 3 positions in the alphabet.

    - Formula: D(y) = (y - 3) mod 26
    - Example: Let's decrypt 'D'.
        1. 'D' is the 4th letter, so its value (y) is 3 (since A=0).
        2. Apply the formula: (3 - 3) mod 26 = 0.
        3. The letter at position 0 is 'A'. So, 'D' decrypts to 'A'.
    - For wrap-around decryption (e.g., 'A'):
        1. 'A' has a value (y) of 0.
        2. Apply the formula: (0 - 3) mod 26 = -3 mod 26.
        3. In modular arithmetic, -3 is the same as 23 (-3 + 26).
        4. The letter at position 23 is 'X'. So, 'A' decrypts to 'X'.
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate that it has been
# loaded and compiled successfully.
1;