#
# CriptoFEP::Trithemius
#
# This module provides an implementation for the Trithemius cipher,
# a polyalphabetic cipher that uses a progressively increasing
# Caesar shift (0, 1, 2, 3...) and is the precursor to the
# Vigenere cipher.
#
package CriptoFEP::Trithemius;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;
use utf8;

# --- MODULE IMPORTS ---
# Add the parent 'lib' directory to Perl's search path.
use lib 'lib';
# Import shared utilities: text normalization and alphabet mappings.
use CriptoFEP::Utils qw(normalize_text $alphabet_list_ref $alphabet_map_ref);

# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(trithemius_encrypt trithemius_decrypt info);

# --- Cipher Logic ---

=head2 trithemius_encrypt
 
 Encrypts a given text using the keyless Trithemius cipher.
 
 B<Parameters:>
   - $plaintext (string): The plaintext to be encrypted.
 
 B<Returns:>
   - (string): The resulting ciphertext.
 
=cut
sub trithemius_encrypt {
    my ($plaintext) = @_; # This classic implementation is keyless.
    # Sanitize the input text to uppercase A-Z only.
    my $norm_plain = normalize_text($plaintext);
    my $ciphertext = "";
    # Initialize the progressive shift. 0 corresponds to 'A'.
    my $shift = 0; 

    # Iterate over each character of the normalized text.
    foreach my $char (split //, $norm_plain) {
        # Get the numeric index of the plaintext character (e.g., 'C' -> 2).
        my $p_idx = $alphabet_map_ref->{$char};
        
        # Apply the Trithemius formula: C = (P + K) mod 26, where K = 0, 1, 2...
        my $c_idx = ($p_idx + $shift) % 26;
        # Convert the new index back to a letter and append it.
        $ciphertext .= $alphabet_list_ref->[$c_idx];
        
        # Increment the shift for the *next* letter.
        $shift = ($shift + 1) % 26; # Wraps around 26
    }
    return $ciphertext;
}

=head2 trithemius_decrypt
 
 Decrypts a given text that was encrypted with the Trithemius cipher.
 
 B<Parameters:>
   - $ciphertext (string): The ciphertext to be decrypted.
 
 B<Returns:>
   - (string): The original plaintext.
 
=cut
sub trithemius_decrypt {
    my ($ciphertext) = @_; # This classic implementation is keyless.
    # Sanitize the input ciphertext.
    my $norm_cipher = normalize_text($ciphertext);
    my $plaintext = "";
    # Initialize the progressive shift, must be identical to the encryption process.
    my $shift = 0; 

    # Iterate over each character of the normalized ciphertext.
    foreach my $char (split //, $norm_cipher) {
        # Get the numeric index of the ciphertext character.
        my $c_idx = $alphabet_map_ref->{$char};
        
        # Apply the decryption formula: P = (C - K + 26) mod 26.
        # Adding 26 handles potential negative results (e.g., 0 - 1 = -1).
        my $p_idx = ($c_idx - $shift + 26) % 26;
        # Convert the original index back to a letter.
        $plaintext .= $alphabet_list_ref->[$p_idx];
        
        # Increment the shift for the *next* letter, perfectly matching the encryption.
        $shift = ($shift + 1) % 26;
    }
    return $plaintext;
}

=head2 info
 
 Returns a formatted string with detailed information about the Trithemius cipher.
 This serves as the dynamic help text for the '--info' command-line option.
 
 B<Parameters:> None
 
 B<Returns:>
   - (string): A multi-line help text.
 
=cut
sub info {
    return qq(CIPHER: Trithemius Cipher

DESCRIPTION:
    A foundational polyalphabetic substitution cipher, invented by Johannes Trithemius.
    It is considered the precursor to the Vigenere cipher and introduces the 
    concept of using multiple cipher alphabets in a systematic way.

MECHANISM:
    - It uses the standard Tabula Recta (Vigenere square).
    - It does *not* require a keyword in its basic form.
    - The "key" is the sequence of the alphabet itself: A, B, C, D...
    - The first letter of the plaintext is encrypted using a Caesar shift of 0 (key A).
    - The second letter is encrypted using a Caesar shift of 1 (key B).
    - The third letter is encrypted using a Caesar shift of 2 (key C).
    - ...and so on, wrapping around Z back to A.
    - Formula: Ci = (Pi + i) mod 26 (where i is the 0-based position).
    - Example: "CAT"
        - 'C' (pos 0): C + 0 = C
        - 'A' (pos 1): A + 1 = B
        - 'T' (pos 2): T + 2 = V
        - Ciphertext: "CBV"

MANUAL DECRYPTION:
    To decrypt, you reverse the process, subtracting the progressive shift.
    - Formula: Pi = (Ci - i + 26) mod 26.
    - Example: Decrypt "CBV"
        - 'C' (pos 0): C - 0 = C
        - 'B' (pos 1): B - 1 = A
        - 'V' (pos 2): V - 2 = T
        - Plaintext: "CAT"

VARIANTS:
    There are variants where the starting letter (e.g., 'G' instead of 'A') or a keyword 
    determines the sequence of shifts, making it closer to Vigenere. The CriptoFEP
    implementation uses the classic, keyless version.
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;