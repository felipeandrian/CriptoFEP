#
# CriptoFEP::Hill
#
# This module implements the Hill cipher (2x2 variant). It is a
# polygraphic substitution cipher that uses linear algebra (matrices)
# to encrypt blocks of text, making it highly resistant to simple
# frequency analysis.
#
package CriptoFEP::Hill;

# --- CORE PRAGMAS ---
use strict;
use warnings;
use utf8;

# --- MODULE IMPORTS ---
# Import shared utilities for text normalization and alphabet mappings.
use lib 'lib';
use CriptoFEP::Utils qw(normalize_text $alphabet_list_ref $alphabet_map_ref mod_inverse);
# Import our custom-built matrix "engine".
use CriptoFEP::Matrix qw(matrix_multiply_vector matrix_inverse matrix_determinant_mod26);

# --- EXPORTER CONFIGURATION ---
require Exporter;
our @ISA = qw(Exporter);
# Export the cipher functions and the new key validation utility.
our @EXPORT_OK = qw(hill_encrypt hill_decrypt info hill_validate_key);

# --- Private Helper Function ---
=head2 _key_to_matrix
 
 Internal helper function to convert a 4-letter key string (e.g., "HILL")
 into a 2x2 matrix of its corresponding numeric values (e.g., [[7, 8], [11, 11]]).
 
 B<Parameters:>
   - $key (string): The 4-letter key string.
 
 B<Returns:>
   - (array ref): A 2x2 matrix (an array of array references).
 
=cut
sub _key_to_matrix {
    my ($key) = @_;
    # Convert the key string "abcd" to a list of numbers (a, b, c, d).
    my @nums = map { $alphabet_map_ref->{$_} } (split //, $key);
    # Arrange the numbers into a 2x2 matrix.
    my @matrix = (
        [$nums[0], $nums[1]], # [a, b]
        [$nums[2], $nums[3]]  # [c, d]
    );
    return \@matrix;
}

# --- PUBLIC CIPHER SUBROUTINES ---

=head2 hill_encrypt
 
 Encrypts plaintext using the Hill 2x2 cipher.
 
 B<Parameters:>
   - $plaintext (string): The plaintext to be encrypted.
   - $key (string): The 4-letter secret key.
 
 B<Returns:>
   - (string): The resulting ciphertext.
 
=cut
sub hill_encrypt {
    my ($plaintext, $key) = @_;
    my $norm_key = normalize_text($key);
    die "Invalid key for 2x2 Hill Cipher. Key must have exactly 4 letters.\n" if length($norm_key) != 4;

    # Convert the 4-letter key into its 2x2 matrix form.
    my $key_matrix = _key_to_matrix($norm_key);
    
    my $norm_plain = normalize_text($plaintext);
    # Pad the text with 'X' if its length is odd to ensure it's made of pairs.
    $norm_plain .= 'X' if length($norm_plain) % 2 != 0;
    
    my $ciphertext = "";
    # Process the plaintext in 2-letter blocks (digraphs).
    foreach my $pair (unpack '(A2)*', $norm_plain) {
        # Convert the digraph (e.g., "HE") into a 2x1 vector (e.g., [7, 4]).
        my @vector = map { $alphabet_map_ref->{$_} } (split //, $pair);
        
        # Call our matrix engine to perform the C = (K * P) mod 26 operation.
        my $cipher_vector_ref = matrix_multiply_vector($key_matrix, \@vector);
        
        # Convert the resulting numeric vector back to letters.
        $ciphertext .= $alphabet_list_ref->[ $cipher_vector_ref->[0] ];
        $ciphertext .= $alphabet_list_ref->[ $cipher_vector_ref->[1] ];
    }
    return $ciphertext;
}

=head2 hill_decrypt
 
 Decrypts ciphertext using the Hill 2x2 cipher.
 
 B<Parameters:>
   - $ciphertext (string): The ciphertext to be decrypted.
   - $key (string): The 4-letter secret key used for encryption.
 
 B<Returns:>
   - (string): The original plaintext.
 
=cut
sub hill_decrypt {
    my ($ciphertext, $key) = @_;
    my $norm_key = normalize_text($key);
    die "Invalid key for 2x2 Hill Cipher. Key must have exactly 4 letters.\n" if length($norm_key) != 4;

    my $key_matrix = _key_to_matrix($norm_key);
    
    # --- 1. The Decryption "Magic" ---
    # Call our matrix engine to find the modular inverse of the key matrix.
    my $inverse_matrix_ref = matrix_inverse($key_matrix);
    # If the inverse doesn't exist, the key is invalid and we cannot decrypt.
    die "Key is invalid: The key matrix is not invertible (determinant is 0 or not coprime with 26).\n" 
        unless defined $inverse_matrix_ref;

    my $norm_cipher = normalize_text($ciphertext);
    my $plaintext = "";

    # --- 2. The Rest of the Process ---
    # The process is identical to encryption, but uses the INVERSE matrix.
    foreach my $pair (unpack '(A2)*', $norm_cipher) {
        my @vector = map { $alphabet_map_ref->{$_} } (split //, $pair);
        
        # Call the matrix engine with the INVERSE matrix: P = (K_inv * C) mod 26.
        my $plain_vector_ref = matrix_multiply_vector($inverse_matrix_ref, \@vector);
        
        $plaintext .= $alphabet_list_ref->[ $plain_vector_ref->[0] ];
        $plaintext .= $alphabet_list_ref->[ $plain_vector_ref->[1] ];
    }
    return $plaintext;
}

=head2 hill_validate_key
 
 A utility function to check if a key is valid for the 2x2 Hill cipher.
 
 B<Parameters:>
   - $key (string): The 4-letter key to validate.
 
 B<Returns:>
   - (string): A formatted report on the key's validity and mathematical properties.
 
=cut
sub hill_validate_key {
    my ($key) = @_;
    my $norm_key = normalize_text($key);
    
    # Check for correct length.
    if (length($norm_key) != 4) {
        return "--- Key Validation Report for '$key' ---\n" .
               "Status: Key is INVALID.\n" .
               "Error: A 2x2 Hill Cipher key must have exactly 4 letters.\n";
    }
    
    # Check its mathematical properties.
    my $key_matrix = _key_to_matrix($norm_key);
    my $det = matrix_determinant_mod26($key_matrix);
    my $det_inv = mod_inverse($det, 26);
    
    my $output = "--- Key Validation Report for '$key' ---\n";
    $output .= "Key Matrix:\n";
    $output .= sprintf("  [ %2d  %2d ]\n", $key_matrix->[0][0], $key_matrix->[0][1]);
    $output .= sprintf("  [ %2d  %2d ]\n", $key_matrix->[1][0], $key_matrix->[1][1]);
    $output .= "Determinant (mod 26): $det\n";

    if (defined $det_inv) {
        # The key is valid!
        $output .= "Multiplicative Inverse of Determinant: $det_inv\n";
        $output .= "Status: Key is VALID.\n";
    } else {
        # The key is invalid; find out why.
        my $error = ($det == 0) ? "is 0" : 
                    ($det % 2 == 0) ? "is divisible by 2" : "is divisible by 13";
        $output .= "Multiplicative Inverse of Determinant: None\n";
        $output .= "Status: Key is INVALID.\n";
        $output .= "Error: Determinant ($det) is not coprime with 26 (it $error).\n";
    }
    return $output;
}

=head2 info
 
 Returns a formatted string with detailed information about the Hill cipher.
 
=cut
sub info {
    return qq(CIPHER: Hill Cipher (2x2)

DESCRIPTION:
    A landmark polygraphic substitution cipher invented by Lester S. Hill in 1929.
    It was the first classic cipher to use advanced linear algebra (matrices)
    to encrypt blocks of letters, which makes it very strong against simple
    frequency analysis.

MECHANISM:
    - It operates on blocks of 2 letters (digraphs).
    - The key is a 4-letter string that forms a 2x2 matrix.
    - Encryption: The numeric vector for a plaintext digraph [P1, P2] is
      matrix-multiplied by the 2x2 key matrix [K] to produce a
      ciphertext vector [C1, C2].
    - Formula: C = (K * P) mod 26
    - Decryption: Requires finding the modular inverse of the key matrix [K_inv].
    - Formula: P = (K_inv * C) mod 26
    
    - Example Key: "HILL" -> [[7, 8], [11, 11]]
    - Plaintext: "HELP" -> "HE", "LP" -> [7, 4], [11, 15]
    - Encrypt("HE"): [[7, 8], [11, 11]] * [7, 4] = [81, 121] mod 26 = [3, 17] -> "DR"
    - Encrypt("LP"): [[7, 8], [11, 11]] * [11, 15] = [197, 286] mod 26 = [15, 0] -> "PA"
    - Result: "DRPA"

KEY VALIDITY:
    - Not all keys are valid!
    - A key is only valid if its matrix is invertible modulo 26.
    - This means the determinant of the matrix must be coprime with 26
      (i.e., it cannot be 0, 13, or any even number).
    - Valid Key: "HILL" (det=15)
    - Invalid Key: "ABCD" (det=24)
);
}

# --- MODULE SUCCESS ---
1;