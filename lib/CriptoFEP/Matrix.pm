#
# CriptoFEP::Matrix
#
# This module provides the mathematical backend for ciphers that rely on
# linear algebra, specifically the Hill Cipher. It implements 2x2 matrix
# operations modulo 26.
#
package CriptoFEP::Matrix;

# --- CORE PRAGMAS ---
use strict;
use warnings;
use utf8;

# --- MODULE IMPORTS ---
# Import the modular multiplicative inverse function, which is the core
# component needed for finding a matrix inverse.
use lib 'lib';
use CriptoFEP::Utils qw(mod_inverse);

# --- EXPORTER CONFIGURATION ---
require Exporter;
our @ISA = qw(Exporter);
# Define the functions this module will provide to other modules.
our @EXPORT_OK = qw(
    matrix_multiply_vector
    matrix_inverse
    matrix_determinant_mod26
);

# --- 2x2 Matrix Functions ---

=head2 matrix_determinant_mod26
 
 Calculates the determinant of a 2x2 matrix, modulo 26.
 
 B<Parameters:>
   - $matrix (array ref): A 2x2 matrix, e.g., [ [a, b], [c, d] ]
 
 B<Returns:>
   - (integer): The determinant (ad - bc) mod 26.
 
=cut
sub matrix_determinant_mod26 {
    my ($matrix) = @_;
    
    # Get the values [ a, b ]
    #                [ c, d ]
    my $a = $matrix->[0][0];
    my $b = $matrix->[0][1];
    my $c = $matrix->[1][0];
    my $d = $matrix->[1][1];

    # Calculate the determinant: (ad - bc)
    my $det = ($a * $d - $b * $c) % 26;
    
    # Ensure the result is positive (e.g., -11 mod 26 is 15)
    $det = ($det + 26) % 26; 
    return $det;
}

=head2 matrix_multiply_vector
 
 Multiplies a 2x2 matrix by a 2x1 vector (a digraph), modulo 26.
 
 B<Formula:>
   [ a b ] * [ p1 ] = [ (a*p1 + b*p2) % 26 ]
   [ c d ]   [ p2 ]   [ (c*p1 + d*p2) % 26 ]
 
 B<Parameters:>
   - $matrix (array ref): The 2x2 key matrix.
   - $vector (array ref): The 2x1 plaintext vector [p1, p2].
 
 B<Returns:>
   - (array ref): The resulting 2x1 ciphertext vector.
 
=cut
sub matrix_multiply_vector {
    my ($matrix, $vector) = @_;
    
    # C1 = (a*p1 + b*p2) % 26
    my $c1 = ($matrix->[0][0] * $vector->[0] + $matrix->[0][1] * $vector->[1]) % 26;
    # C2 = (c*p1 + d*p2) % 26
    my $c2 = ($matrix->[1][0] * $vector->[0] + $matrix->[1][1] * $vector->[1]) % 26;
    
    return [$c1, $c2];
}

=head2 matrix_inverse
 
 Calculates the modular multiplicative inverse of a 2x2 matrix, modulo 26.
 This is the core function required for decryption.
 
 B<Parameters:>
   - $matrix (array ref): The 2x2 key matrix to invert.
 
 B<Returns:>
   - (array ref): The 2x2 inverse matrix, if it exists.
   - (undef): If the matrix is not invertible (determinant is not coprime with 26).
 
=cut
sub matrix_inverse {
    my ($matrix) = @_;
    
    # --- 1. Find the Determinant ---
    my $det = matrix_determinant_mod26($matrix);
    
    # --- 2. Find the Modular Multiplicative Inverse of the Determinant ---
    # This is the most critical step. We use our trusted Utils function.
    my $det_inv = mod_inverse($det, 26);
    
    # If the inverse doesn't exist, the key is invalid. Stop here.
    return undef unless defined $det_inv;

    # --- 3. Calculate the Adjugate Matrix (mod 26) ---
    # For a 2x2 matrix K = [ a b ], Adj(K) = [  d  -b ]
    #                       [ c d ]           [ -c   a ]
    my $a = $matrix->[0][0];
    my $b = $matrix->[0][1];
    my $c = $matrix->[1][0];
    my $d = $matrix->[1][1];
    
    my @adjugate;
    $adjugate[0][0] = ($d + 26) % 26;
    $adjugate[0][1] = (-$b + 26) % 26;
    $adjugate[1][0] = (-$c + 26) % 26;
    $adjugate[1][1] = ($a + 26) % 26;
    
    # --- 4. Calculate the Inverse Matrix ---
    # The inverse matrix is (det_inv * Adjugate) mod 26
    my @inverse_matrix;
    $inverse_matrix[0][0] = ($det_inv * $adjugate[0][0]) % 26;
    $inverse_matrix[0][1] = ($det_inv * $adjugate[0][1]) % 26;
    $inverse_matrix[1][0] = ($det_inv * $adjugate[1][0]) % 26;
    $inverse_matrix[1][1] = ($det_inv * $adjugate[1][1]) % 26;

    return \@inverse_matrix;
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;