#
# CriptoFEP::Albam
#
# This module provides the implementation for the Albam cipher, a simple
# reciprocal substitution cipher that swaps the two halves of the alphabet.
# It is functionally identical to the ROT13 cipher.
#
package CriptoFEP::Albam;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;
use utf8;

# --- MODULE IMPORTS ---
# Add the parent 'lib' directory to Perl's search path to find our custom modules.
use lib 'lib';
# Import shared utilities for text normalization.
use CriptoFEP::Utils qw(normalize_text);

# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Add 'info' to the list of functions that can be exported.
our @EXPORT_OK = qw(albam_cipher info);

# --- CIPHER LOGIC ---

=head2 albam_cipher
 
 Performs the Albam substitution on a given text.
 Since Albam is a reciprocal (involutory) cipher, this single function
 handles both encryption and decryption.
 
 B<Parameters:>
   - $text (string): The plaintext (or ciphertext) to be transformed.
 
 B<Returns:>
   - (string): The resulting ciphertext (or plaintext).
 
=cut
sub albam_cipher {
    my ($text) = @_;
    # Sanitize the input to uppercase A-Z characters only.
    my $normalized_text = normalize_text($text);
    my $output = "";

    # The Albam map is a fixed, keyless substitution.
    # It maps the first half of the alphabet (A-M) to the second (N-Z)
    # and vice-versa. This is identical to a ROT13 operation.
    my %albam_map = (
        'A' => 'N', 'B' => 'O', 'C' => 'P', 'D' => 'Q', 'E' => 'R', 'F' => 'S',
        'G' => 'T', 'H' => 'U', 'I' => 'V', 'J' => 'W', 'K' => 'X', 'L' => 'Y',
        'M' => 'Z', 'N' => 'A', 'O' => 'B', 'P' => 'C', 'Q' => 'D', 'R' => 'E',
        'S' => 'F', 'T' => 'G', 'U' => 'H', 'V' => 'I', 'W' => 'J', 'X' => 'K',
        'Y' => 'L', 'Z' => 'M',
    );

    # Iterate over each character and substitute it using the map.
    foreach my $char (split //, $normalized_text) {
        $output .= $albam_map{$char} if exists $albam_map{$char};
    }

    return $output;
}

# --- DOCUMENTATION SUBROUTINE ---

=head2 info
 
 Returns a formatted string with detailed information about the Albam cipher.
 This serves as the dynamic help text for the '--info' command-line option.
 
 B<Parameters:> None
 
 B<Returns:>
   - (string): A multi-line help text.
 
=cut
sub info {
    return qq(CIPHER: Albam Cipher

DESCRIPTION:
    An ancient, keyless substitution cipher, similar in origin to Atbash. It is
    named based on its mapping pattern for the first few letters of the Hebrew
    alphabet.

MECHANISM:
    - The mapping is fixed and requires no key.
    - The alphabet is split into two halves (A-M and N-Z). The first half is
      swapped with the second half.
    - 'A' becomes 'N', 'B' becomes 'O', ... and conversely, 'N' becomes 'A'.
    - Like Atbash, it is a reciprocal cipher (its own inverse). The same process
      is used for both encryption and decryption.
    - Example: 'HELLO' becomes 'URYYB'.

MANUAL DECRYPTION:
    Because the Albam cipher is its own inverse, the decryption process is
    identical to the encryption process.

    - To decrypt a letter, find its corresponding pair by shifting it 13 places
      in the alphabet.
    - Example: Let's decrypt 'U'.
        1. 'U' is in the second half of the alphabet.
        2. Shifting it back 13 places ('U' -> 'T' -> ... -> 'H') reveals 'H'.
        3. Therefore, 'U' decrypts (and encrypts) to 'H'.
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;