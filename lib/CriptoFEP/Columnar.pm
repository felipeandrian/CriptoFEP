#
# CriptoFEP::Columnar
#
# This module provides the implementation for the Columnar Transposition cipher,
# a classic transposition method that rearranges characters based on a keyword.
# It does not substitute any characters, only changes their order.
#

package CriptoFEP::Columnar;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;


# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(columnar_encrypt columnar_decrypt info);


# --- MODULE-PRIVATE HELPER SUBROUTINES ---

=head2 _get_key_order
 
 Internal function to determine the column read-out order based on a keyword.
 
 B<Parameters:>
   - $key (string): The keyword used for transposition.
 
 B<Returns:>
   - (array): A list of column indices (0-based) sorted according to the
     alphabetical order of the keyword's characters.
 
=cut
sub _get_key_order {
    my ($key) = @_;
    my @key_chars = split //, uc($key);
    # Sort the array indices (0, 1, 2...) based on the alphabetical value of the
    # characters at those indices in the key. The '|| $a <=> $b' is a crucial
    # tie-breaker that ensures stable sorting for keys with duplicate letters.
    my @sorted_indices = sort { $key_chars[$a] cmp $key_chars[$b] || $a <=> $b } 0..$#key_chars;
    return @sorted_indices;
}


# --- PUBLIC CIPHER SUBROUTINES ---

=head2 columnar_encrypt
 
 Encrypts plaintext using the Columnar Transposition cipher.
 
 B<Parameters:>
   - $plaintext (string): The plaintext to be encrypted.
   - $key (string): The transposition keyword.
 
 B<Returns:>
   - (string): The resulting ciphertext.
 
=cut
sub columnar_encrypt {
    my ($plaintext, $key) = @_;
    my $num_cols = length($key);
    # If the key is trivial (1 character or less), no transposition occurs.
    return $plaintext if $num_cols <= 1;

    my @key_order = _get_key_order($key);
    my @columns;
    
    # --- Step 1: Write plaintext into columns ---
    # Characters are dealt into columns cyclically, as if writing into a grid row by row.
    # This implementation does not use padding, resulting in an irregular grid.
    my $i = 0;
    foreach my $char (split //, $plaintext) {
        $columns[$i % $num_cols] .= $char;
        $i++;
    }

    # --- Step 2: Read columns in key order ---
    # Concatenate the content of each column according to the sorted key order.
    my $ciphertext = "";
    foreach my $col_idx (@key_order) {
        $ciphertext .= $columns[$col_idx] // ''; # Use defined-or for robustness.
    }
    return $ciphertext;
}

=head2 columnar_decrypt
 
 Decrypts ciphertext that was encrypted with the Columnar Transposition cipher.
 
 B<Parameters:>
   - $ciphertext (string): The ciphertext to be decrypted.
   - $key (string): The keyword used for the original encryption.
 
 B<Returns:>
   - (string): The original plaintext.
 
=cut
sub columnar_decrypt {
    my ($ciphertext, $key) = @_;
    my $num_cols = length($key);
    my $text_len = length($ciphertext);
    return $ciphertext if $num_cols <= 1 || $text_len == 0;
    
    my @key_order = _get_key_order($key);
    
    # --- Step 1: Calculate the dimensions of the original grid ---
    # Determine how many columns were "long" and how many were "short".
    my $base_col_len = int($text_len / $num_cols);
    my $long_cols_count = $text_len % $num_cols;
    
    # Create a map to know the correct length for each original column index.
    my @col_lengths;
    for my $i (0 .. $num_cols - 1) {
        # The first 'long_cols_count' columns in the *original write order* are the longer ones.
        $col_lengths[$i] = ($i < $long_cols_count) ? $base_col_len + 1 : $base_col_len;
    }
    
    # --- Step 2: "Pour" the ciphertext back into the correctly sized columns ---
    my @columns;
    my $pos = 0;
    # Iterate through the key in its ALPHABETICAL order to read the ciphertext chunks.
    foreach my $original_index (@key_order) {
        # Get the length corresponding to the column's ORIGINAL position.
        my $len = $col_lengths[$original_index];
        # Assign the chunk of ciphertext to its correct original column.
        $columns[$original_index] = substr($ciphertext, $pos, $len);
        $pos += $len;
    }
    
    # --- Step 3: Reconstruct the plaintext by reading the grid row-by-row ---
    my $plaintext = "";
    my $num_rows = int(($text_len + $num_cols - 1) / $num_cols);
    for my $row_idx (0 .. $num_rows - 1) {
        for my $col_idx (0 .. $num_cols - 1) {
            # Take one character from each column in sequence to rebuild the rows.
            my $char = substr($columns[$col_idx], $row_idx, 1);
            $plaintext .= $char if $char; # Append character if it exists.
        }
    }
    
    return $plaintext;
}

=head2 info
 
 Returns a formatted string with detailed information about the Columnar Transposition cipher.
 
=cut
sub info {
    return qq(CIPHER: Columnar Transposition Cipher

DESCRIPTION:
    A classic transposition cipher that rearranges the letters of a message
    based on a keyword. Unlike substitution ciphers, the letters themselves
    are not changed, only their positions.

MECHANISM (ENCRYPTION):
    - The message is written out in rows under a keyword. The number of columns
      is equal to the length of the keyword.
    - The columns of this grid are then reordered based on the alphabetical
      order of the letters in the keyword.
    - The ciphertext is formed by reading down the columns in their new order.
    - Example (Key: "ZEBRA"):
        - Plaintext: "WE ARE DISCOVERED FLEE AT ONCE"
        - Grid:
            Z E B R A
            - - - - -
            W E   A R
            E   D I S
            C O V E R
            E D   F L
            E E   A T
                  O N
                  C E
        - Sorted Key Order: A, B, E, R, Z
        - Ciphertext (reading columns in sorted order):
          "RSRDVE OEDAIEWECE" (spaces are preserved)

MANUAL DECRYPTION:
    To decrypt, you must know the keyword.

    1. Calculate the grid dimensions: The number of columns is the key length.
       The number of rows is calculated from the ciphertext length. Some columns
       will be one character longer than others.
    2. Determine the read-out order by sorting the key alphabetically.
    3. "Pour" the ciphertext into the columns of a new grid, filling the columns
       in the key's alphabetical order.
    4. Reorder the columns back to their original positions based on the keyword.
    5. The original message is revealed by reading the grid row by row.
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;