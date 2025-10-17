#
# CriptoFEP::Affine
#
# This module provides the implementation for the Affine cipher, a monoalphabetic
# substitution cipher that uses a linear function for its mapping.
#

package CriptoFEP::Affine;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;
# Ensure that the source code can contain and process UTF-8 characters.
use utf8;


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
our @EXPORT_OK = qw(affine_encrypt affine_decrypt info);


# --- MODULE-PRIVATE HELPER SUBROUTINES ---

=head2 _modInverse
 
 Internal function to calculate the modular multiplicative inverse of 'a' modulo 'm'.
 This is essential for the decryption process.
 
 B<Parameters:>
   - $a (integer): The number to find the inverse of.
   - $m (integer): The modulus.
 
 B<Returns:>
   - (integer|undef): The modular inverse if it exists, otherwise undef.
 
=cut
sub _modInverse {
    my ($a, $m) = @_;
    $a = $a % $m;
    # Brute-force search for the inverse 'x' such that (a * x) % m == 1.
    # This is efficient enough for a small modulus like 26.
    for my $x (1 .. $m - 1) {
        return $x if (($a * $x) % $m == 1);
    }
    return undef; # Inverse does not exist (a and m are not coprime).
}

=head2 _parse_and_validate_key
 
 Internal function to parse the key string "a,b" and validate its components.
 It ensures 'a' is a valid multiplier (coprime with 26).
 
 B<Parameters:>
   - $key (string): The key string, expected in "a,b" format.
 
 B<Returns:>
   - A list containing ($a, $b, $a_inverse) on success.
   - The script will die with an error message on failure.
 
=cut
sub _parse_and_validate_key {
    my ($key) = @_;
    
    # Ensure the key matches the required "number,number" format.
    unless ($key =~ /^(\d+),(\d+)$/) {
        # This validation is also in criptofep.pl for a faster failure,
        # but kept here for module robustness and independent testing.
        die "ERROR: Invalid key format for Affine cipher. Expected 'a,b' (e.g., -k \"5,8\").\n";
    }
    my ($a, $b) = ($1, $2);

    # Calculate the modular inverse of 'a' to check if it's a valid key.
    my $a_inv = _modInverse($a, 26);
    unless (defined $a_inv) {
        die "ERROR: Invalid key 'a' for Affine cipher. 'a' value ($a) is not coprime with 26.\n";
    }

    return ($a, $b, $a_inv);
}


# --- PUBLIC CIPHER SUBROUTINES ---

=head2 affine_encrypt
 
 Encrypts plaintext using the Affine cipher.
 
 B<Parameters:>
   - $plaintext (string): The plaintext to be encrypted.
   - $key (string): The key in "a,b" format (e.g., "5,8").
 
 B<Returns:>
   - (string): The resulting ciphertext.
 
=cut
sub affine_encrypt {
    my ($plaintext, $key) = @_;
    # Parse and validate the key, getting 'a' and 'b'.
    my ($a, $b) = _parse_and_validate_key($key);
    
    my $norm_plain = normalize_text($plaintext);
    my $ciphertext = "";

    foreach my $char (split //, $norm_plain) {
        # Convert character to numeric value (A=0, B=1...).
        my $x = $alphabet_map_ref->{$char};
        # Apply encryption formula: E(x) = (a*x + b) mod 26.
        my $e_x = ($a * $x + $b) % 26;
        # Convert numeric value back to a character.
        $ciphertext .= $alphabet_list_ref->[$e_x];
    }
    return $ciphertext;
}

=head2 affine_decrypt
 
 Decrypts ciphertext that was encrypted with the Affine cipher.
 
 B<Parameters:>
   - $ciphertext (string): The ciphertext to be decrypted.
   - $key (string): The key in "a,b" format used for encryption.
 
 B<Returns:>
   - (string): The original plaintext.
 
=cut
sub affine_decrypt {
    my ($ciphertext, $key) = @_;
    # Parse and validate the key, getting 'a', 'b', and the pre-calculated inverse of 'a'.
    my ($a, $b, $a_inv) = _parse_and_validate_key($key);
    
    my $norm_cipher = normalize_text($ciphertext);
    my $plaintext = "";

    foreach my $char (split //, $norm_cipher) {
        # Convert character to numeric value (A=0, B=1...).
        my $y = $alphabet_map_ref->{$char};
        # Apply decryption formula: D(y) = a⁻¹ * (y - b) mod 26.
        # Add 26 to (y - b) to prevent negative results from the modulo operation.
        my $d_y = ($a_inv * ($y - $b + 26)) % 26;
        # Convert numeric value back to a character.
        $plaintext .= $alphabet_list_ref->[$d_y];
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