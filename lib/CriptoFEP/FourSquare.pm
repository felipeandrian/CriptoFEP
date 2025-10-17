#
# CriptoFEP::FourSquare
#
# This module provides the implementation for the Four-Square cipher, a symmetric
# polygraphic substitution cipher that encrypts pairs of letters using four grids.
#

package CriptoFEP::FourSquare;

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
our @EXPORT_OK = qw(four_square_encrypt four_square_decrypt info);


# --- MODULE-PRIVATE HELPER SUBROUTINES ---

=head2 _generate_grid
 
 Internal function to generate a 5x5 Polybius-style grid and a coordinate map.
 This logic is reused from the Playfair cipher implementation. A blank key
 results in a standard, ordered alphabet grid.
 
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
    # The defined-or operator ensures we handle an undefined/blank key gracefully.
    my $key_unique = normalize_text($key // "");
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

=head2 four_square_encrypt
 
 Encrypts plaintext using the Four-Square cipher.
 
 B<Parameters:>
   - $plaintext (string): The plaintext to be encrypted.
   - $key_pair (array ref): A reference to an array containing the two keys:
     - [$key1, $key2]
 
 B<Returns:>
   - (string): The resulting ciphertext.
 
=cut
sub four_square_encrypt {
    my ($plaintext, $key_pair) = @_;
    my ($key1, $key2) = @$key_pair;

    # Generate the four required grids and their coordinate maps.
    my ($plain_grid, $plain_coords) = _generate_grid("");   # Top-left and bottom-right grids
    my ($key_grid1, $key_coords1)   = _generate_grid($key1); # Top-right grid
    my ($key_grid2, $key_coords2)   = _generate_grid($key2); # Bottom-left grid

    # Prepare the plaintext: normalize, treat J as I, and pad if necessary.
    my $norm_plain = normalize_text($plaintext);
    $norm_plain =~ s/J/I/g;
    $norm_plain .= 'X' if length($norm_plain) % 2 != 0;

    my $ciphertext = "";
    # Process the plaintext as a series of two-character pairs (digraphs).
    foreach my $pair (unpack '(A2)*', $norm_plain) {
        my ($l1, $l2) = split //, $pair;
        
        # Ensure both letters exist in the plain alphabet grid before processing.
        next unless exists $plain_coords->{$l1} && exists $plain_coords->{$l2};

        # Find coordinates of the first letter in the top-left plain grid.
        my ($r1, $c1) = @{ $plain_coords->{$l1} };
        # Find coordinates of the second letter in the bottom-right plain grid.
        my ($r2, $c2) = @{ $plain_coords->{$l2} };
        
        # Apply the rectangle rule to find the ciphertext letters in the keyed grids.
        $ciphertext .= $key_grid1->[$r1][$c2]; # Top-right grid: row from l1, col from l2
        $ciphertext .= $key_grid2->[$r2][$c1]; # Bottom-left grid: row from l2, col from l1
    }
    return $ciphertext;
}

=head2 four_square_decrypt
 
 Decrypts ciphertext that was encrypted with the Four-Square cipher.
 
 B<Parameters:>
   - $ciphertext (string): The ciphertext to be decrypted.
   - $key_pair (array ref): A reference to the array of keys used for encryption.
 
 B<Returns:>
   - (string): The original plaintext.
 
=cut
sub four_square_decrypt {
    my ($ciphertext, $key_pair) = @_;
    my ($key1, $key2) = @$key_pair;

    # Generate all four grids, as they are all needed for decryption.
    my ($plain_grid, $plain_coords) = _generate_grid("");
    my ($key_grid1, $key_coords1)   = _generate_grid($key1);
    my ($key_grid2, $key_coords2)   = _generate_grid($key2);
    
    my $norm_cipher = normalize_text($ciphertext);
    $norm_cipher =~ s/J/I/g;

    my $plaintext = "";
    foreach my $pair (unpack '(A2)*', $norm_cipher) {
        my ($c1_char, $c2_char) = split //, $pair;

        # Ensure both ciphertext letters exist in their respective keyed grids.
        next unless exists $key_coords1->{$c1_char} && exists $key_coords2->{$c2_char};
        
        # Find coordinates of the first letter in the top-right key grid.
        my ($r1, $c1) = @{ $key_coords1->{$c1_char} };
        # Find coordinates of the second letter in the bottom-left key grid.
        my ($r2, $c2) = @{ $key_coords2->{$c2_char} };
        
        # Apply the inverse rectangle rule to find the plaintext letters in the plain grids.
        $plaintext .= $plain_grid->[$r1][$c2]; # Top-left grid: row from c1, col from c2
        $plaintext .= $plain_grid->[$r2][$c1]; # Bottom-right grid: row from c2, col from c1
    }
    return $plaintext;
}

=head2 info
 
 Returns a formatted string with detailed information about the Four-Square cipher.
 
=cut
sub info {
    return qq(CIPHER: Four-Square Cipher

DESCRIPTION:
    A polygraphic substitution cipher that improves on Playfair and Two-Square
    by using four 5x5 grids. It is significantly more secure as it avoids
    the weakness of common digraphs (like 'TH') encrypting to their reverse ('HT').

MECHANISM:
    - Four 5x5 grids are arranged in a large square. The top-left and
      bottom-right grids contain the standard alphabet. The top-right and
      bottom-left grids are generated from two different secret keys.
    - The plaintext is broken into pairs of letters.
    - For each pair (e.g., "HI"):
        1. Find 'H' in the top-left (plain) grid.
        2. Find 'I' in the bottom-right (plain) grid.
        3. These form the corners of a rectangle. The ciphertext letters are
           the other two corners:
           - First letter: from the top-right (key 1) grid at (row of 'H', col of 'I').
           - Second letter: from the bottom-left (key 2) grid at (row of 'I', col of 'H').
    - Decryption is the inverse process, starting from the keyed grids to find
      the letters in the plain grids.
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;
