#
# CriptoFEP::Atbah
#
# This module provides the implementation for the Atbah cipher, a simple,
# keyless, reciprocal substitution cipher based on a specific, non-sequential
# mapping of the alphabet.
#
package CriptoFEP::Atbah;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;
use utf8;

# --- MODULE IMPORTS ---
# This module does not need Utils, as it normalizes text manually for its hash keys.
# However, let's import it for consistency in our project structure.
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
our @EXPORT_OK = qw(atbah_cipher info);

# --- CIPHER LOGIC ---

=head2 atbah_cipher
 
 Performs the Atbah substitution on a given text.
 Since Atbah is a reciprocal (involutory) cipher, this single function
 handles both encryption and decryption.
 
 B<Parameters:>
   - $text (string): The plaintext (or ciphertext) to be transformed.
 
 B<Returns:>
   - (string): The resulting ciphertext (or plaintext).
 
=cut
sub atbah_cipher {
    my ($text) = @_;
    # Sanitize the input to uppercase A-Z characters only.
    my $normalized_text = normalize_text($text);
    my $output = "";

    # The Atbah map is a fixed, keyless, reciprocal substitution.
    # Each pair of letters maps to each other (e.g., A->I and I->A).
    my %atbah_map = (
        'A' => 'I', 'B' => 'H', 'C' => 'G', 'D' => 'F', 'E' => 'N', 'F' => 'D',
        'G' => 'C', 'H' => 'B', 'I' => 'A', 'J' => 'R', 'K' => 'Q', 'L' => 'P',
        'M' => 'O', 'N' => 'E', 'O' => 'M', 'P' => 'L', 'Q' => 'K', 'R' => 'J',
        'S' => 'Z', 'T' => 'Y', 'U' => 'X', 'V' => 'W', 'W' => 'V', 'X' => 'U',
        'Y' => 'T', 'Z' => 'S',
    );

    # Iterate over each character of the normalized text.
    foreach my $char (split //, $normalized_text) {
        # Append the substituted character if it exists in the map.
        $output .= $atbah_map{$char} if exists $atbah_map{$char};
    }

    return $output;
}

# --- DOCUMENTATION SUBROUTINE ---

=head2 info
 
 Returns a formatted string with detailed information about the Atbah cipher.
 This serves as the dynamic help text for the '--info' command-line option.
 
 B<Parameters:> None
 
 B<Returns:>
   - (string): A multi-line help text.
 
=cut
sub info {
    return qq(CIPHER: Atbah Cipher

DESCRIPTION:
    A simple, keyless substitution cipher, similar in origin to Atbash,
    historically used for the Hebrew alphabet. It follows a specific,
    non-sequential mapping of letters.

MECHANISM:
    - The mapping is fixed and requires no key.
    - It is a reciprocal cipher, meaning it is its own inverse. The same
      function is used for both encryption and decryption.
    - The mapping pairs letters like so: A<=>I, B<=>H, C<=>G, D<=>F, E<=>N, etc.
    - Example: 'ATTACK' becomes 'IYYIXQ'.

MANUAL DECRYPTION:
    Because the Atbah cipher is its own inverse, the decryption process is
    identical to the encryption process.

    - To decrypt a letter, find its corresponding pair in the substitution table.
    - Example: Let's decrypt 'B'.
        1. In the Atbah mapping, the letter 'B' is paired with 'H'.
        2. Therefore, 'B' decrypts (and encrypts) to 'H'.
    - Example: Let's decrypt 'N'.
        1. In the Atbah mapping, the letter 'N' is paired with 'E'.
        2. Therefore, 'N' decrypts (and encrypts) to 'E'.
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;