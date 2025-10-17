#
# CriptoFEP::ADFGX
#
# This module provides the implementation for the ADFGX cipher, the original 5x5
# version of the famous World War I German field cipher. It is a two-stage
# fractionating transposition cipher.
#

package CriptoFEP::ADFGX;

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
our @EXPORT_OK = qw(adfgx_encrypt adfgx_decrypt info);


# --- MODULE-PRIVATE DATA ---
# The coordinate letters for the 5x5 grid.
my @coords_letters = qw(A D F G X);


# --- MODULE-PRIVATE HELPER SUBROUTINES ---

=head2 _generate_grid
 
 Internal function to generate the 5x5 substitution grid and its coordinate maps.
 
 B<Parameters:>
   - $grid_key (string): The secret key used to construct the mixed-alphabet grid.
 
 B<Returns:>
   - A list containing two references:
     1. A reference to a hash mapping each character to its "ADFGX" coordinate pair.
     2. A reference to a hash mapping each coordinate pair back to its character.
 
=cut
sub _generate_grid {
    my ($grid_key) = @_;
    my %char_to_coords;
    my %coords_to_char;
    
    # The alphabet source for a 5x5 grid, with 'I' and 'J' combined.
    my $alphabet_source = "ABCDEFGHIKLMNOPQRSTUVWXYZ";
    
    # Prepare the grid key: uppercase, remove non-alphanumeric, and treat J as I.
    my $key_unique = uc($grid_key);
    $key_unique =~ s/[^A-Z]//g;
    $key_unique =~ s/J/I/g;
    
    # Create a unique-character version of the key.
    my %seen_for_key;
    $key_unique = join '', grep { !$seen_for_key{$_}++ } split //, $key_unique;
    
    # Create the full source string for the grid by prepending the key to the alphabet.
    my $source = $key_unique . $alphabet_source;
    
    # Generate a flat list of 25 unique characters for the grid.
    my %seen_for_source;
    my @flat_grid = grep { !$seen_for_source{$_}++ } split //, $source;

    # Populate the coordinate maps from the flat grid.
    for my $row (0..4) {
        for my $col (0..4) {
            my $char = $flat_grid[$row * 5 + $col];
            my $coord_pair = $coords_letters[$row] . $coords_letters[$col];
            $char_to_coords{$char} = $coord_pair;
            $coords_to_char{$coord_pair} = $char;
        }
    }
    return (\%char_to_coords, \%coords_to_char);
}


# --- PUBLIC CIPHER SUBROUTINES ---

=head2 adfgx_encrypt
 
 Encrypts plaintext using the two-stage ADFGX cipher.
 
 B<Parameters:>
   - $plaintext (string): The plaintext to be encrypted.
   - $key_pair (array ref): A reference to an array containing the two keys:
     - [$grid_key, $transposition_key]
 
 B<Returns:>
   - (string): The resulting ciphertext.
 
=cut
sub adfgx_encrypt {
    my ($plaintext, $key_pair) = @_;
    my ($grid_key, $trans_key) = @$key_pair;

    my ($char_map) = _generate_grid($grid_key);
    my $norm_plain = normalize_text($plaintext);
    $norm_plain =~ s/J/I/g; # Ensure plaintext also treats J as I.

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
    
    # Write the intermediate text into columns.
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

=head2 adfgx_decrypt
 
 Decrypts ciphertext that was encrypted with the ADFGX cipher.
 
 B<Parameters:>
   - $ciphertext (string): The ciphertext to be decrypted.
   - $key_pair (array ref): A reference to an array containing the two keys:
     - [$grid_key, $transposition_key]
 
 B<Returns:>
   - (string): The original plaintext.
 
=cut
sub adfgx_decrypt {
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
 
 Returns a formatted string with detailed information about the ADFGX cipher.
 
=cut
sub info {
    return qq(CIPHER: ADFGX Cipher

DESCRIPTION:
    The original version of the famous WWI German field cipher, introduced in
    March 1918. It is a fractionating transposition cipher that combines a 5x5
    Polybius square with a columnar transposition, providing a high level of
    security for its time.

MECHANISM:
    This is a two-stage process requiring two keys: a 'grid key' and a 'transposition key'.

    1. Substitution Stage:
       - A 5x5 grid is created using the 'grid key', containing 25 letters
         (with I and J combined).
       - Each character of the plaintext is replaced by its two-letter coordinate
         using the letters A, D, F, G, X.
       - This produces a long intermediate ciphertext of coordinate letters.

    2. Transposition Stage:
       - The intermediate ciphertext is written into a new grid under the
         'transposition key'.
       - The columns are reordered alphabetically based on the key.
       - The final ciphertext is formed by reading down the columns in their new order.

MANUAL DECRYPTION:
    Decryption reverses the two stages. It is a complex process.

    1. Reverse Transposition: Reconstruct the transposition grid by calculating
       column lengths. "Pour" the ciphertext into the sorted columns, reorder
       them back to their original positions, and read row-by-row.
    2. Reverse Substitution: Take the resulting intermediate text, break it into
       pairs, and look up each pair in the substitution grid to find the
       original character.
);
}


# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;