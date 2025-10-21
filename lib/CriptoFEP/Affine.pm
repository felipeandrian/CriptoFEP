#
# CriptoFEP::Affine
#
# This module provides the implementation for the Affine cipher.
# It is a mathematical substitution cipher using the formula (ax + b) mod 26.
# This version has been refactored to use the central mod_inverse
# function from CriptoFEP::Utils for decryption.
#
package CriptoFEP::Affine;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;
use utf8;

# --- MODULE IMPORTS ---
# Add the parent 'lib' directory to Perl's search path.
use lib 'lib';
# Import shared utilities: text normalization, alphabet mappings,
# and now our new, centralized modular inverse function!
use CriptoFEP::Utils qw(normalize_text $alphabet_list_ref $alphabet_map_ref mod_inverse);

# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(affine_encrypt affine_decrypt info);

# --- PUBLIC CIPHER SUBROUTINES ---

=head2 affine_encrypt
 
 Encrypts plaintext using the Affine cipher.
 
 B<Parameters:>
   - $plaintext (string): The plaintext to be encrypted.
   - $key_str (string): The key, formatted as "a,b".
 
 B<Returns:>
   - (string): The resulting ciphertext.
 
=cut
sub affine_encrypt {
    my ($plaintext, $key_str) = @_;
    # Parse the key string "a,b" into its two integer components.
    my ($a, $b) = split /,/, $key_str;
    
    my $norm_plain = normalize_text($plaintext);
    my $ciphertext = "";

    # Iterate over each character of the normalized text.
    foreach my $char (split //, $norm_plain) {
        # Get the numeric index of the character (e.g., 'A' -> 0).
        my $p_idx = $alphabet_map_ref->{$char};
        # Apply the Affine encryption formula: E(p) = (a*p + b) mod 26.
        my $c_idx = ($a * $p_idx + $b) % 26;
        # Convert the new index back to a letter.
        $ciphertext .= $alphabet_list_ref->[$c_idx];
    }
    return $ciphertext;
}

=head2 affine_decrypt
 
 Decrypts ciphertext that was encrypted with the Affine cipher.
 
 B<Parameters:>
   - $ciphertext (string): The ciphertext to be decrypted.
   - $key_str (string): The key ("a,b") used for the original encryption.
 
 B<Returns:>
   - (string): The original plaintext.
 
=cut
sub affine_decrypt {
    my ($ciphertext, $key_str) = @_;
    my ($a, $b) = split /,/, $key_str;
    
    # --- THE CRITICAL STEP ---
    # Instead of a brute-force loop, we now use our professional math tool
    # to find the modular multiplicative inverse of 'a'.
    my $a_inv = mod_inverse($a, 26);
    # This 'die' is a crucial security and stability check.
    # If no inverse exists, decryption is impossible, and we stop.
    die "Invalid 'a' key: $a has no modular inverse mod 26.\n" unless defined $a_inv;

    my $norm_cipher = normalize_text($ciphertext);
    my $plaintext = "";

    # Iterate over each character of the normalized ciphertext.
    foreach my $char (split //, $norm_cipher) {
        # Get the numeric index of the character (e.g., 'C' -> 2).
        my $c_idx = $alphabet_map_ref->{$char};
        # Apply the Affine decryption formula: D(c) = a_inv * (c - b) mod 26.
        # Adding 26 before the modulo handles potential negative results.
        my $p_idx = ($a_inv * ($c_idx - $b + 26)) % 26;
        # Convert the original index back to a letter.
        $plaintext .= $alphabet_list_ref->[$p_idx];
    }
    return $plaintext;
}

=head2 info
 
 Returns a formatted string with detailed information about the Affine cipher.
 
=cut
sub info {
    return qq(CIPHER: Affine Cipher

DESCRIPTION:
    A type of monoalphabetic substitution cipher, which is a generalization
    of the Caesar cipher. It uses a mathematical formula involving both
    multiplication and addition to map letters.

MECHANISM (ENCRYPTION):
    - The key is a pair of integers (a, b).
    - Formula: E(x) = (a*x + b) mod 26, where 'x' is the numeric value of the letter (A=0, B=1...).
    - Crucial Constraint: The 'a' value MUST be coprime with 26 for the cipher
      to be reversible. This means their only common divisor is 1.
    - Valid 'a' values are: 1, 3, 5, 7, 9, 11, 15, 17, 19, 21, 23, 25.
    - The 'b' value can be any integer from 0 to 25.
    - Example (key="5,8"): 'AFFINE' becomes "IHHWVC".

MANUAL DECRYPTION:
    To decrypt, you must find the modular multiplicative inverse of 'a' (notated as a⁻¹).
    This is the number such that (a * a⁻¹) mod 26 = 1.

    - Formula: D(y) = a⁻¹ * (y - b) mod 26
    - Example: Let's decrypt 'I' with key="5,8".
        1. Find the inverse of a=5: We need a number 'z' where (5 * z) mod 26 = 1.
           By testing, we find (5 * 21) = 105, and 105 mod 26 = 1. So, a⁻¹ = 21.
        2. 'I' is the 9th letter, so its value (y) is 8. 'b' is 8.
        3. Apply the formula: 21 * (8 - 8) mod 26 = 21 * 0 mod 26 = 0.
        4. The letter at position 0 is 'A'. So, 'I' decrypts to 'A'.
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;