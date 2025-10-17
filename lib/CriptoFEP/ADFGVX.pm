#
# CriptoFEP::ADFGVX
#
# This module provides the implementation for the ADFGVX cipher, a highly
# secure World War I German field cipher. It is a two-stage fractionating
# transposition cipher that combines a 6x6 Polybius-style square with a
# columnar transposition.
#

package CriptoFEP::ADFGVX;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;


# --- MODULE IMPORTS ---
# Add the parent 'lib' directory to Perl's search path to find our custom modules.
use lib 'lib';
# Import shared utilities for text normalization.
use CriptoFEP::Utils qw(normalize_text);


# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(adfgvx_encrypt adfgvx_decrypt info);


# --- MODULE-PRIVATE DATA ---
# The coordinate letters for the 6x6 grid.
my @coords_letters = qw(A D F G V X);


# --- MODULE-PRIVATE HELPER SUBROUTINES ---

=head2 _generate_grid
 
 Internal function to generate the 6x6 substitution grid and its coordinate maps.
 
 B<Parameters:>
   - $grid_key (string): The secret key used to construct the mixed-alphabet grid.
 
 B<Returns:>
   - A list containing two references:
     1. A reference to a hash mapping each character to its "ADFGVX" coordinate pair.
     2. A reference to a hash mapping each coordinate pair back to its character.
 
=cut
sub _generate_grid {
    my ($grid_key) = @_;
    my %char_to_coords;
    my %coords_to_char;
    
    # The alphabet source for a 6x6 grid, including all letters and digits.
    my $alphabet_source = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    # Prepare the grid key: uppercase, remove non-alphanumeric characters.
    my $key_unique = uc($grid_key);
    $key_unique =~ s/[^A-Z0-9]//g;
    
    # Create a unique-character version of the key.
    my %seen_for_key;
    $key_unique = join '', grep { !$seen_for_key{$_}++ } split //, $key_unique;
    
    # Create the full source string for the grid by prepending the key to the alphabet.
    my $source = $key_unique . $alphabet_source;
    
    # Generate a flat list of 36 unique characters for the grid.
    my %seen_for_source;
    my @flat_grid = grep { !$seen_for_source{$_}++ } split //, $source;

    # Populate the coordinate maps from the flat grid.
    for my $row (0..5) {
        for my $col (0..5) {
            my $char = $flat_grid[$row * 6 + $col];
            my $coord_pair = $coords_letters[$row] . $coords_letters[$col];
            $char_to_coords{$char} = $coord_pair;
            $coords_to_char{$coord_pair} = $char;
        }
    }
    return (\%char_to_coords, \%coords_to_char);
}


# --- PUBLIC CIPHER SUBROUTINES ---

=head2 adfgvx_encrypt
 
 Encrypts plaintext using the two-stage ADFGVX cipher.
 
 B<Parameters:>
   - $plaintext (string): The plaintext to be encrypted.
   - $key_pair (array ref): A reference to an array containing the two keys:
     - [$grid_key, $transposition_key]
 
 B<Returns:>
   - (string): The resulting ciphertext.
 
=cut
sub adfgvx_encrypt {
    my ($plaintext, $key_pair) = @_;
    my ($grid_key, $trans_key) = @$key_pair;

    my ($char_map) = _generate_grid($grid_key);
    
    # Sanitize the plaintext to match the grid alphabet (A-Z, 0-9).
    my $norm_plain = uc($plaintext);
    $norm_plain =~ s/[^A-Z0-9]//g;

    # --- Stage 1: Substitution ---
    # Convert the plaintext into a long string of coordinate letters.
    my $substituted_text = "";
    foreach my $char (split //, $norm_plain) {
        $substituted_text .= $char_map->{$char} if exists $char_map->{$char};
    }

    # --- Stage 2: Columnar Transposition ---
    my @trans_key_chars = split //, uc($trans_key);
    my $num_cols = scalar @trans_key_chars;
    return "" unless $num_cols > 0;
    
    # Write the intermediate text into columns cyclically.
    my @columns;
    my $i = 0;
    foreach my $char (split //, $substituted_text) {
        push @{$columns[$i % $num_cols]}, $char;
        $i++;
    }
    
    # Get the column read-out order by sorting the key alphabetically.
    # The '|| $a <=> $b' is a tie-breaker for keys with duplicate letters.
    my @sorted_indices = sort { $trans_key_chars[$a] cmp $trans_key_chars[$b] || $a <=> $b } 0..$num_cols-1;
    
    # Read the columns in the sorted order to produce the final ciphertext.
    my $ciphertext = "";
    foreach my $index (@sorted_indices) {
        $ciphertext .= join '', @{$columns[$index] // []};
    }

    return $ciphertext;
}

=head2 adfgvx_decrypt
 
 Decrypts ciphertext that was encrypted with the ADFGVX cipher.
 
 B<Parameters:>
   - $ciphertext (string): The ciphertext to be decrypted.
   - $key_pair (array ref): A reference to an array containing the two keys:
     - [$grid_key, $transposition_key]
 
 B<Returns:>
   - (string): The original plaintext.
 
=cut
sub adfgvx_decrypt {
    my ($ciphertext, $key_pair) = @_;
    my ($grid_key, $trans_key) = @$key_pair;
    my (undef, $coord_map) = _generate_grid($grid_key);
    
    # --- Stage 1: Reverse Columnar Transposition ---
    my @trans_key_chars = split //, uc($trans_key);
    my $num_cols = scalar @trans_key_chars;
    my $text_len = length($ciphertext);
    return "" unless $num_cols > 0 && $text_len > 0;

    # Calculate the dimensions of the transposition grid.
    my $base_col_len = int($text_len / $num_cols);
    my $long_cols_count = $text_len % $num_cols;
    my @sorted_indices = sort { $trans_key_chars[$a] cmp $trans_key_chars[$b] || $a <=> $b } 0..$num_cols-1;
    
    # "Pour" the ciphertext back into columns based on the key order.
    my @columns;
    my $pos = 0;
    for my $i (0..$num_cols-1) {
        my $original_index = $sorted_indices[$i];
        # Column lengths are determined by the original write order, not the sorted read order.
        my $col_len = ($original_index < $long_cols_count) ? $base_col_len + 1 : $base_col_len;
        $columns[$original_index] = substr($ciphertext, $pos, $col_len);
        $pos += $col_len;
    }

    # Reconstruct the intermediate text by reading the grid row-by-row.
    my $substituted_text = "";
    my $num_rows = int(($text_len + $num_cols - 1) / $num_cols);
    for my $row (0 .. $num_rows - 1) {
        for my $col (0 .. $num_cols - 1) {
            my $char = substr($columns[$col], $row, 1);
            $substituted_text .= $char if $char;
        }
    }

    # --- Stage 2: Reverse Substitution ---
    # Convert the coordinate pairs back to plaintext characters.
    my $plaintext = "";
    foreach my $pair (unpack '(A2)*', $substituted_text) {
        $plaintext .= $coord_map->{$pair} if exists $coord_map->{$pair};
    }
    
    return $plaintext;
}

=head2 info
 
 Returns a formatted string with detailed information about the ADFGVX cipher.
 
=cut
sub info {
    return qq(CIPHER: ADFGVX Cipher

DESCRIPTION:
    A highly secure field cipher used by the German Army during World War I.
    It is a fractionating transposition cipher that combines a 6x6 Polybius-style
    square with a columnar transposition, providing excellent security for its era.

MECHANISM:
    This is a two-stage process requiring two keys: a 'grid key' and a 'transposition key'.

    1. Substitution Stage:
       - A 6x6 grid is created using the 'grid key', containing all 26 letters
         and 10 digits (0-9) in a mixed order.
       - Each character of the plaintext is replaced by its two-letter coordinate
         using the letters A, D, F, G, V, X.
       - This produces a long intermediate ciphertext of coordinate letters.

    2. Transposition Stage:
       - The intermediate ciphertext is written into a new grid under the
         'transposition key'.
       - The columns are reordered alphabetically based on the key.
       - The final ciphertext is formed by reading down the columns in their new order.

MANUAL DECRYPTION:
    Decryption reverses the two stages, starting with the complex transposition reversal.

    1. Reverse Transposition: Reconstruct the transposition grid by calculating
       column lengths based on the key and ciphertext length. "Pour" the
       ciphertext into the sorted columns, reorder them back to their original
       positions, and read row-by-row to recover the intermediate ciphertext.
    2. Reverse Substitution: Take the resulting intermediate text, break it into
       pairs, and look up each pair in the substitution grid to find the
       original character.
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;