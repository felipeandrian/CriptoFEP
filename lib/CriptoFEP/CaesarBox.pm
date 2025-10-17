#
# CriptoFEP::CaesarBox
#
# This module provides the implementation for the Caesar Box cipher.
# It functions as an intelligent wrapper, translating the Caesar Box logic
# into a specific case of the more general Columnar Transposition cipher.
#

package CriptoFEP::CaesarBox;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;


# --- MODULE IMPORTS ---
# IMPORTANT: This module is a composition and depends entirely on the robust
# logic from the Columnar module. This is a prime example of code reuse.
use CriptoFEP::Columnar qw(columnar_encrypt columnar_decrypt);


# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(caesar_box_encrypt caesar_box_decrypt info);


# --- PUBLIC CIPHER SUBROUTINES ---

=head2 caesar_box_encrypt
 
 Encrypts plaintext using the Caesar Box transposition cipher.
 It achieves this by converting the numeric key into a simple alphabetic
 key and then delegating the work to the Columnar cipher module.
 
 B<Parameters:>
   - $plaintext (string): The plaintext to be encrypted.
   - $key (integer): The width of the box (number of columns).
 
 B<Returns:>
   - (string): The resulting ciphertext.
 
=cut
sub caesar_box_encrypt {
    my ($plaintext, $key) = @_;
    my $num_cols = int($key);

    # Generate a simple, sequential alphabetic key (e.g., 4 -> "ABCD").
    # This simulates a columnar transposition where columns are read in their natural order.
    my @letters = ('A'..'Z');
    my $columnar_key = join '', @letters[0 .. $num_cols - 1];
    
    # Delegate the actual encryption work to the already-tested Columnar module.
    return columnar_encrypt($plaintext, $columnar_key);
}

=head2 caesar_box_decrypt
 
 Decrypts ciphertext that was encrypted with the Caesar Box cipher.
 Like the encryption function, it acts as a wrapper for the Columnar module.
 
 B<Parameters:>
   - $ciphertext (string): The ciphertext to be decrypted.
   - $key (integer): The width of the box used for the original encryption.
 
 B<Returns:>
   - (string): The original plaintext.
 
=cut
sub caesar_box_decrypt {
    my ($ciphertext, $key) = @_;
    my $num_cols = int($key);

    # Generate the identical sequential key used for encryption.
    my @letters = ('A'..'Z');
    my $columnar_key = join '', @letters[0 .. $num_cols - 1];
    
    # Delegate the actual decryption work to the Columnar module.
    return columnar_decrypt($ciphertext, $columnar_key);
}

=head2 info
 
 Returns a formatted string with detailed information about the Caesar Box cipher.
 
=cut
sub info {
    return qq(CIPHER: Caesar Box Cipher

DESCRIPTION:
    A simple transposition cipher, also known as a "box cipher" or "square cipher".
    Despite its name, it is NOT related to the Caesar substitution cipher. It
    rearranges the letters of a message by writing them into a grid and then
    reading them out in a different order.

MECHANISM (ENCRYPTION):
    - The key is a number that specifies the width of the box (number of columns).
    - The plaintext is written into the grid, row by row.
    - The ciphertext is formed by reading the grid column by column, from left to right.
    - Implementation Note: This is a special case of the Columnar Transposition
      cipher where the keyword is simply the alphabet in order (e.g., "ABCD" for a key of 4).
    - Example (with key=4):
        - Plaintext: "ATTACK AT DAWN"
        - Grid (4 columns):
            A T T A
            C K   A
            T   D A
            W N
        - Ciphertext (read by columns): "ACTW TK N T DAAA " (padding may be added)

MANUAL DECRYPTION:
    To decrypt, you must know the key (the number of columns).

    1. Calculate the grid dimensions:
       - cols = key
       - rows = ceil(length(ciphertext) / key)
    2. "Pour" the ciphertext into a new grid, filling it column by column.
    3. The original message is revealed by reading the grid row by row.
    - Example (with key=4):
        - Ciphertext: "ACTWTK N T DAA  "
        - Pour into 4 columns to reconstruct the grid above.
        - Read across the rows to get "ATTACK AT DAWN".
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;