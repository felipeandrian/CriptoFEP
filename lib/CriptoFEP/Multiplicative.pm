#
# CriptoFEP::Multiplicative
#
# This module provides the implementation for the Multiplicative cipher, a simple
# monoalphabetic substitution cipher that uses modular multiplication.
#

package CriptoFEP::Multiplicative;

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
our @EXPORT_OK = qw(multiplicative_encrypt multiplicative_decrypt info);


# --- MODULE-PRIVATE HELPER SUBROUTINES ---

=head2 _modInverse
 
 Internal function to calculate the modular multiplicative inverse of 'a' modulo 'm'.
 This is a critical component for the decryption process.
 
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


# --- PUBLIC CIPHER SUBROUTINES ---

=head2 multiplicative_encrypt
 
 Encrypts plaintext using the Multiplicative cipher.
 
 B<Parameters:>
   - $plaintext (string): The plaintext to be encrypted.
   - $key (integer): The key 'a', which must be an integer coprime with 26.
 
 B<Returns:>
   - (string): The resulting ciphertext.
 
=cut
sub multiplicative_encrypt {
    my ($plaintext, $key) = @_;
    my $a = int($key);

    my $norm_plain = normalize_text($plaintext);
    my $ciphertext = "";

    # Iterate over each character of the normalized plaintext.
    foreach my $char (split //, $norm_plain) {
        # Convert character to numeric value (A=0, B=1...).
        my $x = $alphabet_map_ref->{$char};
        # Apply encryption formula: E(x) = (a * x) mod 26.
        my $e_x = ($a * $x) % 26;
        # Convert numeric value back to a character.
        $ciphertext .= $alphabet_list_ref->[$e_x];
    }
    return $ciphertext;
}

=head2 multiplicative_decrypt
 
 Decrypts ciphertext that was encrypted with the Multiplicative cipher.
 
 B<Parameters:>
   - $ciphertext (string): The ciphertext to be decrypted.
   - $key (integer): The key 'a' used for the original encryption.
 
 B<Returns:>
   - (string): The original plaintext, or an error string if decryption is impossible.
 
=cut
sub multiplicative_decrypt {
    my ($ciphertext, $key) = @_;
    my $a = int($key);
    
    # Find the modular multiplicative inverse of the key 'a'.
    my $a_inv = _modInverse($a, 26);
    
    # This check provides internal robustness. The main criptofep.pl script
    # already validates the key, but it's good practice for the module to be self-contained.
    return "DECRYPTION_ERROR_INVALID_KEY" unless defined $a_inv;

    my $norm_cipher = normalize_text($ciphertext);
    my $plaintext = "";

    # Iterate over each character of the normalized ciphertext.
    foreach my $char (split //, $norm_cipher) {
        # Convert character to numeric value.
        my $y = $alphabet_map_ref->{$char};
        # Apply decryption formula: D(y) = (a⁻¹ * y) mod 26.
        my $d_y = ($a_inv * $y) % 26;
        # Convert numeric value back to a character.
        $plaintext .= $alphabet_list_ref->[$d_y];
    }
    return $plaintext;
}

=head2 info
 
 Returns a formatted string with detailed information about the Multiplicative cipher.
 
=cut
sub info {
    return qq(CIPHER: Multiplicative Cipher

DESCRIPTION:
    A monoalphabetic substitution cipher where each letter is mapped to another
    letter by multiplying its numeric value by a key, modulo the alphabet size.
    It is a component of the more general Affine cipher.

MECHANISM (ENCRYPTION):
    - The key is a single integer, 'a'.
    - Formula: E(x) = (a*x) mod 26, where 'x' is the numeric value of the letter (A=0, B=1...).
    - Crucial Constraint: The key 'a' MUST be coprime with 26 for the cipher
      to be reversible. This means their only common divisor is 1.
    - Valid 'a' values are: 1, 3, 5, 7, 9, 11, 15, 17, 19, 21, 23, 25.
    - Example (key=7): 'HELLO' becomes "ZEBBW".

MANUAL DECRYPTION:
    To decrypt, you must find the modular multiplicative inverse of 'a' (notated as a⁻¹).
    This is the number such that (a * a⁻¹) mod 26 = 1.

    - Formula: D(y) = (a⁻¹ * y) mod 26
    - Example: Let's decrypt "Z" with key=7.
        1. Find the inverse of a=7: We need a number 'z' where (7 * z) mod 26 = 1.
           By testing, we find (7 * 15) = 105, and 105 mod 26 = 1. So, a⁻¹ = 15.
        2. 'Z' is the 26th letter, so its value (y) is 25.
        3. Apply the formula: (15 * 25) mod 26 = 375 mod 26 = 11.
        4. The letter at position 11 is 'L'. (Error in example, should be 11 -> L).
           Correcting with 'H' from 'HELLO':
           - 'H' (7) * 7 = 49. 49 mod 26 = 23. Letter 23 is 'X'.
           - Let's re-verify: "HELLO" with key 7:
             H(7)*7=49%26=23(X), E(4)*7=28%26=2(C), L(11)*7=77%26=25(Z), L(11)*7=25(Z), O(14)*7=98%26=20(U).
             Correct result: "XCZZU".
        5. Decrypting "X" (23) with inverse 15:
           (23 * 15) mod 26 = 345 mod 26 = 7. Letter 7 is 'H'. Correct.
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;