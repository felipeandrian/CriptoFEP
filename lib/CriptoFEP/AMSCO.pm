#
# CriptoFEP::AMSCO
#
# This module provides the implementation for the AMSCO cipher, a variation of
# the Columnar Transposition cipher that uses an irregular grid filling pattern
# based on single letters (monographs) and pairs of letters (digraphs).
#

package CriptoFEP::AMSCO;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;


# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(amsco_encrypt amsco_decrypt info);


# --- MODULE-PRIVATE HELPER SUBROUTINES ---

=head2 _get_key_order
 
 Internal function to determine the column read-out order based on a keyword.
 This is a shared utility function, identical to the one used in Columnar.pm.
 
 B<Parameters:>
   - $key (string): The keyword used for transposition.
 
 B<Returns:>
   - (array): A list of column indices (0-based) sorted according to the
     alphabetical order of the keyword's characters.
 
=cut
sub _get_key_order {
    my ($key) = @_;
    my @key_chars = split //, uc($key);
    # Sort the array indices based on the alphabetical value of the key's characters.
    # The '|| $a <=> $b' is a tie-breaker for keys with duplicate letters.
    my @sorted_indices = sort { $key_chars[$a] cmp $key_chars[$b] || $a <=> $b } 0..$#key_chars;
    return @sorted_indices;
}


# --- PUBLIC CIPHER SUBROUTINES ---

=head2 amsco_encrypt
 
 Encrypts plaintext using the AMSCO cipher.
 
 B<Parameters:>
   - $plaintext (string): The plaintext to be encrypted.
   - $key_pair (array ref): A reference to an array containing the two keys:
     - [$transposition_key, $pattern_key]
 
 B<Returns:>
   - (string): The resulting ciphertext.
 
=cut
sub amsco_encrypt {
    my ($plaintext, $key_pair) = @_;
    my ($trans_key, $pattern_key) = @$key_pair;

    my $num_cols = length($trans_key);
    return $plaintext if $num_cols <= 1;

    my @key_order = _get_key_order($trans_key);
    my @pattern = split //, $pattern_key;
    my $pattern_len = scalar @pattern;
    
    my @columns;
    my $pos = 0;
    my $pattern_idx = 0;
    
    # --- Step 1: Fill columns with alternating chunks of 1 or 2 characters ---
    while ($pos < length($plaintext)) {
        # Determine the size of the next chunk (1 or 2) from the repeating pattern.
        my $chunk_size = $pattern[$pattern_idx % $pattern_len];
        my $chunk = substr($plaintext, $pos, $chunk_size);
        
        # Append the chunk to the current column in the grid.
        $columns[$pattern_idx % $num_cols] .= $chunk;
        
        $pos += $chunk_size;
        $pattern_idx++;
    }

    # --- Step 2: Read columns in the order of the transposition key ---
    my $ciphertext = "";
    foreach my $col_idx (@key_order) {
        $ciphertext .= $columns[$col_idx] // '';
    }
    return $ciphertext;
}

=head2 amsco_decrypt
 
 Decrypts ciphertext that was encrypted with the AMSCO cipher.
 
 B<Parameters:>
   - $ciphertext (string): The ciphertext to be decrypted.
   - $key_pair (array ref): A reference to an array containing the two keys:
     - [$transposition_key, $pattern_key]
 
 B<Returns:>
   - (string): The original plaintext.
 
=cut
sub amsco_decrypt {
    my ($ciphertext, $key_pair) = @_;
    my ($trans_key, $pattern_key) = @$key_pair;
    
    my $num_cols = length($trans_key);
    my $text_len = length($ciphertext);
    return $ciphertext if $num_cols <= 1;

    my @key_order = _get_key_order($trans_key);
    my @pattern = split //, $pattern_key;
    my $pattern_len = scalar @pattern;

    # --- Step 1: Simulate the encryption process to calculate column lengths ---
    # This is the most critical part of the decryption.
    my @col_lengths;
    my $simulated_len = 0;
    my $pattern_idx = 0;
    while ($simulated_len < $text_len) {
        my $chunk_size = $pattern[$pattern_idx % $pattern_len];
        # Ensure the final chunk does not exceed the total text length.
        $chunk_size = $text_len - $simulated_len if $simulated_len + $chunk_size > $text_len;
        
        # Increment the length of the appropriate column.
        $col_lengths[$pattern_idx % $num_cols] += $chunk_size;
        
        $simulated_len += $chunk_size;
        $pattern_idx++;
    }

    # --- Step 2: "Pour" the ciphertext into the correctly sized columns ---
    my @columns;
    my $pos = 0;
    foreach my $col_idx (@key_order) {
        my $len = $col_lengths[$col_idx];
        $columns[$col_idx] = substr($ciphertext, $pos, $len);
        $pos += $len;
    }

    # --- Step 3: Read the grid in the original 1-2 pattern to get the plaintext ---
    my $plaintext = "";
    my $total_read = 0;
    $pattern_idx = 0;
    while ($total_read < $text_len) {
        my $chunk_size = $pattern[$pattern_idx % $pattern_len];
        $chunk_size = $text_len - $total_read if $total_read + $chunk_size > $text_len;
        
        # Determine which column to read from next.
        my $col_to_read = $pattern_idx % $num_cols;
        
        # Read and remove the next chunk from the start of the correct column.
        $plaintext .= substr($columns[$col_to_read], 0, $chunk_size, '');
        
        $total_read += $chunk_size;
        $pattern_idx++;
    }
    
    return $plaintext;
}

=head2 info
 
 Returns a formatted string with detailed information about the AMSCO cipher.
 
=cut
sub info {
    return qq(CIPHER: AMSCO Cipher

DESCRIPTION:
    An irregular columnar transposition cipher used by the American Military
    Services Company (hence AMSCO) during World War II. It enhances the
    security of a standard columnar transposition by breaking the plaintext
    into alternating single letters and pairs of letters (digraphs) before
    writing them into the grid.

MECHANISM:
    - This cipher requires two keys: a 'transposition key' (a word) and a
      'pattern key' (a repeating sequence of '1's and '2's).

    1. Grid Filling: The plaintext is written into a grid under the
       transposition key. However, instead of one letter per cell, chunks of
       1 or 2 letters are placed in each cell, following the repeating pattern.
       - Example (Key: "KEYWORD", Pattern: "121"):
           - Plaintext: "MEET AT THE FOUNTAIN"
           - Grid is filled with chunks: M, EE, T, AT, T, HE, F, O, UN, T, AI, N...

    2. Transposition: The columns of this irregular grid are then reordered
       alphabetically based on the transposition key, and the ciphertext is
       read out column by column.

MANUAL DECRYPTION:
    Decryption is complex and requires reversing the process.

    1. Calculate Column Lengths: First, you must simulate the encryption on a
       placeholder text of the same length to determine how many characters
       ended up in each column.
    2. Reconstruct Columns: Use the calculated lengths to "cut" the ciphertext
       into pieces and place them back into columns according to the key's
       alphabetical order.
    3. Reorder Columns: Arrange the columns back into their original order based
       on the transposition key.
    4. Read Plaintext: Read the grid by taking chunks of 1 or 2 letters from
       each cell in sequence, following the original pattern key.
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;