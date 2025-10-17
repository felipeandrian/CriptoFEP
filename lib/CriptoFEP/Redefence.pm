#
# CriptoFEP::Redefence
#
# This module provides the implementation for the Redefence cipher, a simple
# route transposition cipher. It rearranges characters by writing them into
# a grid column-by-column and reading them back row-by-row.
#

package CriptoFEP::Redefence;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;


# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(redefence_encrypt redefence_decrypt info);


# --- PUBLIC CIPHER SUBROUTINES ---

=head2 redefence_encrypt
 
 Encrypts plaintext using the Redefence transposition cipher.
 
 B<Parameters:>
   - $plaintext (string): The plaintext to be encrypted.
   - $key (integer): The number of columns to use for the grid.
 
 B<Returns:>
   - (string): The resulting ciphertext.
 
=cut
sub redefence_encrypt {
    my ($plaintext, $key) = @_;
    my $num_cols = int($key);
    # If the key is trivial (1 column or less), no transposition occurs.
    return $plaintext if $num_cols <= 1;

    my $text_len = length($plaintext);
    # Calculate the number of rows required to fit the entire text.
    # This is equivalent to the ceiling of (length / columns).
    my $num_rows = int(($text_len + $num_cols - 1) / $num_cols);
    
    # Pad the plaintext with spaces to form a perfect rectangular grid.
    $plaintext .= ' ' x (($num_cols * $num_rows) - $text_len);
    my @chars = split //, $plaintext;

    # --- Step 1: Write the plaintext into a grid, column by column ---
    my @grid;
    for my $c (0 .. $num_cols - 1) {
        for my $r (0 .. $num_rows - 1) {
            # Calculate the index from the flat array to fill the grid vertically.
            $grid[$r][$c] = $chars[$c * $num_rows + $r];
        }
    }
    
    # --- Step 2: Read the grid row by row to form the ciphertext ---
    my $ciphertext = "";
    for my $r (0 .. $num_rows - 1) {
        for my $c (0 .. $num_cols - 1) {
            $ciphertext .= $grid[$r][$c];
        }
    }
    return $ciphertext;
}

=head2 redefence_decrypt
 
 Decrypts ciphertext that was encrypted with the Redefence cipher.
 
 B<Parameters:>
   - $ciphertext (string): The ciphertext to be decrypted.
   - $key (integer): The number of columns used for the original encryption.
 
 B<Returns:>
   - (string): The original plaintext.
 
=cut
sub redefence_decrypt {
    my ($ciphertext, $key) = @_;
    my $num_cols = int($key);
    my $text_len = length($ciphertext);
    return $ciphertext if $num_cols <= 1 || $text_len == 0;

    # Because encryption always creates a perfect rectangle, the number of rows
    # can be calculated with a simple division.
    my $num_rows = int($text_len / $num_cols);
    
    my @chars = split //, $ciphertext;
    my @grid;

    # --- Step 1: "Pour" the ciphertext into a grid, row by row ---
    for my $r (0 .. $num_rows - 1) {
        for my $c (0 .. $num_cols - 1) {
            # Calculate the index from the flat array to fill the grid horizontally.
            $grid[$r][$c] = $chars[$r * $num_cols + $c];
        }
    }
    
    # --- Step 2: Read the grid column by column to get the plaintext ---
    my $plaintext = "";
    for my $c (0 .. $num_cols - 1) {
        for my $r (0 .. $num_rows - 1) {
            $plaintext .= $grid[$r][$c];
        }
    }

    # Remove any trailing spaces that were added as padding during encryption.
    $plaintext =~ s/\s+$//;
    
    return $plaintext;
}

=head2 info
 
 Returns a formatted string with detailed information about the Redefence cipher.
 
=cut
sub info {
    return qq(CIPHER: Redefence Cipher

DESCRIPTION:
    A transposition cipher, also known as a type of Route Cipher. It works by
    writing the plaintext into a grid based on a numeric key and then reading
    it out in a different order.

MECHANISM:
    - The key is a number that specifies the number of columns in a grid.
    - Encryption: The plaintext is written into the grid COLUMN BY COLUMN, from
      top to bottom, left to right.
    - The ciphertext is then formed by reading the grid ROW BY ROW.
    - Example (Key: 4):
        - Plaintext: "ATTACK AT DAWN"
        - Grid (4 columns, 3 rows):
            A T D
            T   A
            A K W
            C   N
        - Ciphertext (read by rows): "ATD T A AKW C N"

MANUAL DECRYPTION:
    To decrypt, you must know the key (the number of columns).

    1. Calculate the grid dimensions: cols = key, rows = length(ciphertext) / key.
    2. "Pour" the ciphertext into a new grid, filling it ROW BY ROW.
    3. The original message is revealed by reading the grid COLUMN BY COLUMN.
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;
