# --- Test Script for the Matrix.pm module ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;
# We are NOT using Test::Deep!

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::Matrix qw(
    matrix_determinant_mod26
    matrix_multiply_vector
    matrix_inverse
);
# We also need this for our full cycle test
use CriptoFEP::Utils qw($alphabet_map_ref);

# --- Begin Tests ---

# --- Test Scenario 1: A VALID Key ("HILL") ---
# H=7, I=8, L=11, L=11
my $valid_matrix = [ [7, 8], [11, 11] ];

# Test 1: Validate Determinant Calculation
# (7*11 - 8*11) = 77 - 88 = -11. (-11 % 26) = 15
is(
    matrix_determinant_mod26($valid_matrix),
    15,
    "matrix_determinant_mod26: Correctly calculates determinant for 'HILL' (15)"
);

# Test 2: Validate Matrix-Vector Multiplication
# Vector for "HE" = [7, 4]
# Expected result [3, 17]
my $vector_HE = [ $alphabet_map_ref->{'H'}, $alphabet_map_ref->{'E'} ]; # [7, 4]
my $result_vec_DR_ref = matrix_multiply_vector($valid_matrix, $vector_HE);
# We convert the result [3, 17] to a string "3,17" for the test
is(
    join(',', @$result_vec_DR_ref),
    "3,17",
    "matrix_multiply_vector: Correctly multiplies 'HILL' * 'HE' to get 'DR' (3,17)"
);

# Test 3: Validate Matrix Inversion
# Expected result [[25, 22], [1, 23]]
my $inverse_matrix_ref = matrix_inverse($valid_matrix);
# We convert the matrix to a string "25,22;1,23" for the test
my $inverse_str = join(';', 
    join(',', @{$inverse_matrix_ref->[0]}), 
    join(',', @{$inverse_matrix_ref->[1]})
);
is(
    $inverse_str,
    "25,22;1,23",
    "matrix_inverse: Correctly calculates the inverse for 'HILL'"
);

# Test 4: Full Cycle Test (The Final Proof)
# K_inv * (K * P) should equal P
# We use the results from the previous tests: $inverse_matrix_ref and $result_vec_DR_ref
my $result_vec_HE_ref = matrix_multiply_vector($inverse_matrix_ref, $result_vec_DR_ref);
# We convert the result [7, 4] to a string "7,4"
is(
    join(',', @$result_vec_HE_ref),
    "7,4",
    "Full Cycle: Inverse_Matrix * Cipher_Vector returns Plaintext_Vector (7,4)"
);


# --- Test Scenario 2: An INVALID Key ("ABCD") ---
my $invalid_matrix = [ [0, 1], [2, 3] ];

# Test 5: Validate Determinant for the invalid key
# (0*3 - 1*2) = -2. (-2 % 26) = 24
is(
    matrix_determinant_mod26($invalid_matrix),
    24,
    "matrix_determinant_mod26: Correctly calculates determinant for 'ABCD' (24)"
);

# Test 6: Validate Matrix Inversion failure
# det=24. mod_inverse(24, 26) does not exist.
is(
    matrix_inverse($invalid_matrix),
    undef,
    "matrix_inverse: Correctly returns 'undef' for a non-invertible matrix"
);

# 7. Signal that all tests are done.
done_testing();
