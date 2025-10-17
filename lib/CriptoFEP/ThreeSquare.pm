#
# CriptoFEP::ThreeSquare
#
# This module provides the implementation for the Three-Square cipher, a polygraphic
# substitution cipher that encrypts pairs of letters using three distinct keyed grids.
#

package CriptoFEP::ThreeSquare;

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
our @EXPORT_OK = qw(three_square_encrypt three_square_decrypt info);


# --- MODULE-PRIVATE HELPER SUBROUTINES ---

=head2 _generate_grid
 
 Internal function to generate a 5x5 Polybius-style grid and a coordinate map.
 This logic is reused from the Playfair/TwoSquare cipher implementations.
 
 B<Parameters:>
   - $key (string): The secret key used to construct the grid.
 
 B<Returns:>
   - A list containing two references:
     1. A reference to the 2D array representing the grid.
     2. A reference to a hash mapping each character to its [row, col] coordinates.
 
=cut
sub _generate_grid {
    my ($key) = @_;
    my @grid;
    my %coords;
    my %seen;
    my $alphabet = "ABCDEFGHIKLMNOPQRSTUVWXYZ";
    
    # Prepare the key: normalize, treat 'J' as 'I', and remove duplicates.
    my $key_unique = normalize_text($key);
    $key_unique =~ s/J/I/g;
    $key_unique = join '', grep { !$seen{$_}++ } split //, $key_unique;
    
    # Create the final source string for the grid by combining the key and alphabet.
    my $source = $key_unique . $alphabet;
    %seen = (); # Reset 'seen' hash for the final pass.

    my ($row, $col) = (0, 0);
    # Populate the grid and coordinate map.
    foreach my $char (split //, $source) {
        next if $seen{$char}; # Skip characters already in the grid.
        
        $grid[$row][$col] = $char;
        $coords{$char} = [$row, $col];
        $seen{$char} = 1;

        $col++;
        # Move to the next row when the current one is full.
        if ($col == 5) {
            $col = 0;
            $row++;
            last if $row == 5; # Stop once the 5x5 grid is complete.
        }
    }
    return (\@grid, \%coords);
}


# --- PUBLIC CIPHER SUBROUTINES ---

=head2 three_square_encrypt
 
 Encrypts plaintext using the Three-Square cipher.
 
 B<Parameters:>
   - $plaintext (string): The plaintext to be encrypted.
   - $key_pair (array ref): A reference to an array containing the three keys:
     - [$key1, $key2, $key3]
 
 B<Returns:>
   - (string): The resulting ciphertext.
 
=cut
sub three_square_encrypt {
    my ($plaintext, $key_pair) = @_;
    my ($key1, $key2, $key3) = @$key_pair;

    # Generate the three separate grids and their coordinate maps.
    my ($grid1, $coords1) = _generate_grid($key1); # Top grid
    my ($grid2, $coords2) = _generate_grid($key2); # Middle grid
    my ($grid3, $coords3) = _generate_grid($key3); # Bottom grid

    # Prepare the plaintext: normalize, treat J as I, and pad if necessary.
    my $norm_plain = normalize_text($plaintext);
    $norm_plain =~ s/J/I/g;
    $norm_plain .= 'X' if length($norm_plain) % 2 != 0;

    my $ciphertext = "";
    # Process the plaintext as a series of two-character pairs (digraphs).
    foreach my $pair (unpack '(A2)*', $norm_plain) {
        my ($l1, $l2) = split //, $pair;
        
        # Ensure both letters exist in their respective grids before processing.
        next unless exists $coords1->{$l1} && exists $coords3->{$l2};

        # Find coordinates of the first letter in the top grid (grid 1).
        my ($r1, $c1) = @{ $coords1->{$l1} };
        # Find coordinates of the second letter in the bottom grid (grid 3).
        my ($r2, $c2) = @{ $coords3->{$l2} };
        
        # Apply the encryption rule: find ciphertext letters in the middle grid (grid 2)
        # by swapping the column coordinates.
        $ciphertext .= $grid2->[$r1][$c2]; # Row from l1, Column from l2
        $ciphertext .= $grid2->[$r2][$c1]; # Row from l2, Column from l1
    }
    return $ciphertext;
}

=head2 three_square_decrypt
 
 Decrypts ciphertext that was encrypted with the Three-Square cipher.
 
 B<Parameters:>
   - $ciphertext (string): The ciphertext to be decrypted.
   - $key_pair (array ref): A reference to the array of keys used for encryption.
 
 B<Returns:>
   - (string): The original plaintext.
 
=cut
sub three_square_decrypt {
    my ($ciphertext, $key_pair) = @_;
    my ($key1, $key2, $key3) = @$key_pair;
    
    # Generate all three grids, as they are all needed for decryption.
    my ($grid1, $coords1) = _generate_grid($key1);
    my ($grid2, $coords2) = _generate_grid($key2);
    my ($grid3, $coords3) = _generate_grid($key3);

    my $norm_cipher = normalize_text($ciphertext);
    $norm_cipher =~ s/J/I/g;

    my $plaintext = "";
    foreach my $pair (unpack '(A2)*', $norm_cipher) {
        my ($c1_char, $c2_char) = split //, $pair;

        # Ensure both ciphertext letters exist in the middle grid.
        next unless exists $coords2->{$c1_char} && exists $coords2->{$c2_char};
        
        # Find the coordinates of the ciphertext letters in the middle grid (grid 2).
        my ($r1, $col_c1) = @{ $coords2->{$c1_char} };
        my ($r2, $col_c2) = @{ $coords2->{$c2_char} };
        
        # Apply the decryption rule (the inverse of encryption).
        # Find the plaintext letters in the top and bottom grids by swapping columns.
        $plaintext .= $grid1->[$r1][$col_c2]; # Row from c1, Column from c2
        $plaintext .= $grid3->[$r2][$col_c1]; # Row from c2, Column from c1
    }
    return $plaintext;
}

=head2 info
 
 Returns a formatted string with detailed information about the Three-Square cipher.
 
=cut
sub info {
    return qq(CIPHER: Three-Square Cipher

DESCRIPTION:
    A polygraphic substitution cipher that uses three 5x5 Polybius squares to
    encrypt pairs of letters (digraphs). It is a variation of the more common
    Two-Square and Four-Square ciphers.

MECHANISM:
    - Three 5x5 grids are generated, each from a different secret key (Key 1, Key 2, Key 3).
    - The plaintext is broken into pairs of letters.
    - For each pair (e.g., "HI"):
        1. Find the first letter ('H') in the top grid (Grid 1).
        2. Find the second letter ('I') in the bottom grid (Grid 3).
        3. The ciphertext letters are found in the middle grid (Grid 2) by
           swapping column coordinates:
           - First ciphertext letter: same row as 'H', same column as 'I'.
           - Second ciphertext letter: same row as 'I', same column as 'H'.
    - Decryption is the inverse process: find the ciphertext pair in the middle
      grid and use their coordinates to find the plaintext letters in the top
      and bottom grids.
);
}


# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;
