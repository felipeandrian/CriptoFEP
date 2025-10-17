#
# CriptoFEP::TurningGrille
#
# This module provides an implementation for the Turning Grille cipher, a classic
# transposition cipher that uses a rotating stencil (grille) to reorder characters.
# This version correctly handles plaintext of any length by processing it in blocks.
#

package CriptoFEP::TurningGrille;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;
# Ensure that the source code can contain and process UTF-8 characters.
use utf8;


# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(turning_grille_encrypt turning_grille_decrypt info);


# --- MODULE-PRIVATE CONSTANTS AND DATA ---

# The size of the grid (6x6) is fixed for this implementation.
use constant GRID_SIZE => 6;

# A mathematically valid hole pattern for a 6x6 grille. This specific pattern ensures
# that each of the 36 cells is exposed exactly once over four 90-degree rotations.
# Coordinates are 0-based [row, column].
my @HOLES = (
    [0,0], [0,1], [0,2],
    [1,0], [1,1], [1,2],
    [2,0], [2,1], [2,2]
);


# --- MODULE-PRIVATE HELPER SUBROUTINES ---

=head2 _rotate_coord
 
 Internal function that simulates a 90-degree clockwise rotation of a single
 coordinate within the grid.
 
 B<Parameters:>
   - $r (integer): The current row coordinate.
   - $c (integer): The current column coordinate.
 
 B<Returns:>
   - A list containing the new ($row, $col) coordinates after rotation.
 
=cut
sub _rotate_coord {
    my ($r, $c) = @_;
    # The mathematical formula for a 90-degree clockwise rotation in a square grid.
    my $new_r = $c;
    my $new_c = (GRID_SIZE - 1) - $r;
    return ($new_r, $new_c);
}


# --- PUBLIC CIPHER SUBROUTINES ---

=head2 turning_grille_encrypt
 
 Encrypts plaintext using the Turning Grille cipher, processing in blocks.
 
 B<Parameters:>
   - $plaintext (string): The plaintext to be encrypted.
 
 B<Returns:>
   - (string): The resulting ciphertext.
 
=cut
sub turning_grille_encrypt {
    my ($plaintext) = @_;
    my $size = GRID_SIZE;
    my $grid_area = $size * $size;
    my $ciphertext = "";

    # Process the plaintext in blocks of 36 characters.
    foreach my $block (unpack("(A$grid_area)*", $plaintext)) {
        my @holes = @HOLES; # Reset hole pattern for each block
        
        # Pad the current block with spaces if it's shorter than 36.
        $block .= ' ' x ($grid_area - length($block));
        my @chars = split //, $block;
        
        my @grid;
        # Initialize grid to prevent "uninitialized value" warnings.
        for my $r (0..$size-1) { for my $c (0..$size-1) { $grid[$r][$c] = ''; } }

        my $char_pos = 0;
        # Perform the four rotations to fill the grid.
        for (1..4) {
            # Sort holes to ensure a consistent, predictable write order.
            my @sorted_holes = sort { $a->[0] <=> $b->[0] || $a->[1] <=> $b->[1] } @holes;
            
            foreach my $hole (@sorted_holes) {
                my ($r, $c) = @$hole;
                $grid[$r][$c] = $chars[$char_pos++];
            }
            
            # Calculate the new hole positions for the next rotation.
            my @new_holes;
            foreach my $hole (@holes) {
                push @new_holes, [ _rotate_coord(@$hole) ];
            }
            @holes = @new_holes;
        }
        
        # Read the filled grid row by row and append to the final ciphertext.
        for my $r (0..$size-1) { $ciphertext .= join '', @{$grid[$r]}; }
    }
    return $ciphertext;
}

=head2 turning_grille_decrypt
 
 Decrypts ciphertext that was encrypted with the Turning Grille cipher.
 
 B<Parameters:>
   - $ciphertext (string): The ciphertext block(s) to be decrypted.
 
 B<Returns:>
   - (string): The original plaintext.
 
=cut
sub turning_grille_decrypt {
    my ($ciphertext) = @_;
    my $size = GRID_SIZE;
    my $grid_area = $size * $size;
    my $plaintext = "";

    # Process the ciphertext in blocks of 36 characters.
    foreach my $block (unpack("(A$grid_area)*", $ciphertext)) {
        my @holes = @HOLES; # Reset hole pattern for each block
        
        # Pad the block if the ciphertext length is not a multiple of 36.
        $block .= ' ' x ($grid_area - length($block));
        my @chars = split //, $block;
        
        # "Pour" the ciphertext block into a grid for easy lookup.
        my @grid;
        for my $r (0..$size-1) { for my $c (0..$size-1) { $grid[$r][$c] = shift @chars; } }

        # Read from the grid by simulating the grille rotations.
        for (1..4) {
            # Sort holes to ensure a consistent read order, matching encryption.
            my @sorted_holes = sort { $a->[0] <=> $b->[0] || $a->[1] <=> $b->[1] } @holes;
            
            foreach my $hole (@sorted_holes) {
                my ($r, $c) = @$hole;
                $plaintext .= $grid[$r][$c];
            }
            
            # Calculate new hole positions for the next rotation.
            my @new_holes;
            foreach my $hole (@holes) {
                push @new_holes, [ _rotate_coord(@$hole) ];
            }
            @holes = @new_holes;
        }
    }
    
    # Remove any trailing spaces that were added as padding.
    $plaintext =~ s/\s+$//;
    return $plaintext;
}

=head2 info
 
 Returns a formatted string with detailed information about the Turning Grille cipher.
 
=cut
sub info {
    return qq(CIPHER: Turning Grille Cipher

DESCRIPTION:
    A classic transposition cipher that uses a stencil or "grille" (a sheet with
    holes) to encrypt a message. The grille is placed on a grid, letters are
    written in the holes, and the grille is rotated to fill the entire grid.

MECHANISM:
    - This implementation is keyless and uses a fixed 6x6 grid (36 characters).
    - Text longer than 36 characters is processed in separate blocks.
    - The grille has a valid pattern of holes, ensuring that each cell of the grid
      is exposed exactly once during four 90-degree clockwise rotations.
    - Encryption: The plaintext is written through the holes, rotating the
      grille by 90 degrees after each pass. This is repeated for each block.
    - The ciphertext is the final block(s) of jumbled text, read row by row.

MANUAL DECRYPTION:
    1. Break the ciphertext into 36-character blocks.
    2. For each block, place the grille over the grid of ciphertext.
    3. Read the letters visible through the holes in a fixed order (e.g., top-to-bottom).
    4. Rotate the grille 90 degrees clockwise and repeat until the full
       plaintext for that block is recovered.
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;
