#
# CriptoFEP::Trifid
#
# This module provides the implementation for the Trifid cipher, an advanced
# fractionating cipher invented by Felix Delastelle. It extends the concept of
# the Bifid cipher into three dimensions using a 3x3x3 cube.
#

package CriptoFEP::Trifid;

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
our @EXPORT_OK = qw(trifid_encrypt trifid_decrypt info);


# --- MODULE-PRIVATE HELPER SUBROUTINES ---

=head2 _generate_cube
 
 Internal function to generate the 3x3x3 substitution cube and its coordinate maps.
 The cube uses 0-based indexing for layer, row, and column (0-2).
 
 B<Parameters:>
   - $key (string): The secret key used to construct the mixed-alphabet cube.
 
 B<Returns:>
   - A list containing two references:
     1. A reference to a hash mapping each character to its "layer-row-col" coordinate triplet.
     2. A reference to a hash mapping each coordinate triplet back to its character.
 
=cut
sub _generate_cube {
    my ($key) = @_;
    my %char_to_coords;
    my %coords_to_char;
    
    # The alphabet source for a 3x3x3 cube, including a '.' for the 27th position.
    my $alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ.";
    
    # Prepare the grid key: uppercase, remove non-alphabetic, and get unique characters.
    my $key_unique = uc($key);
    $key_unique =~ s/[^A-Z]//g;
    my %seen;
    $key_unique = join '', grep { !$seen{$_}++ } split //, $key_unique;
    
    # Create the full source string for the cube by prepending the key to the alphabet.
    my $source = $key_unique . $alphabet;
    %seen = (); # Reset 'seen' for the final pass.
    
    # Generate a flat list of 27 unique characters for the cube.
    my @flat_cube = grep { !$seen{$_}++ } split //, $source;

    # Populate the coordinate maps from the flat cube source.
    for my $i (0..26) {
        my $char = $flat_cube[$i];
        
        # Calculate the 3D coordinates from the linear index 'i'.
        my $layer = int($i / 9);       # Which of the three 3x3 grids.
        my $row   = int(($i % 9) / 3);  # The row within that grid.
        my $col   = $i % 3;            # The column within that grid.
        
        my $coord_triplet = "$layer$row$col";
        $char_to_coords{$char} = $coord_triplet;
        $coords_to_char{$coord_triplet} = $char;
    }
    return (\%char_to_coords, \%coords_to_char);
}


# --- PUBLIC CIPHER SUBROUTINES ---

=head2 trifid_encrypt
 
 Encrypts plaintext using the Trifid cipher.
 
 B<Parameters:>
   - $plaintext (string): The plaintext to be encrypted.
   - $key (string): The secret key for generating the cube.
 
 B<Returns:>
   - (string): The resulting ciphertext.
 
=cut
sub trifid_encrypt {
    my ($plaintext, $key) = @_;
    my ($char_map, $coord_map) = _generate_cube($key);
    my $norm_plain = normalize_text($plaintext);
    
    # --- Stage 1: Fractionation ---
    # Convert each character into its 3D coordinates and separate them into three strings.
    my ($layers_str, $rows_str, $cols_str) = ('', '', '');
    foreach my $char (split //, $norm_plain) {
        if (exists $char_map->{$char}) {
            my ($layer, $row, $col) = split //, $char_map->{$char};
            $layers_str .= $layer;
            $rows_str   .= $row;
            $cols_str   .= $col;
        }
    }

    # --- Stage 2: Transposition ---
    # Concatenate the layer, row, and column strings.
    my $combined = $layers_str . $rows_str . $cols_str;
    
    # --- Stage 3: Reassembly ---
    # Group the combined string into new coordinate triplets and convert back to letters.
    my $ciphertext = "";
    foreach my $triplet (unpack '(A3)*', $combined) {
        $ciphertext .= $coord_map->{$triplet} if exists $coord_map->{$triplet};
    }
    return $ciphertext;
}

=head2 trifid_decrypt
 
 Decrypts ciphertext that was encrypted with the Trifid cipher.
 
 B<Parameters:>
   - $ciphertext (string): The ciphertext to be decrypted.
   - $key (string): The secret key used for the original encryption.
 
 B<Returns:>
   - (string): The original plaintext.
 
=cut
sub trifid_decrypt {
    my ($ciphertext, $key) = @_;
    my ($char_map, $coord_map) = _generate_cube($key);
    my $norm_cipher = normalize_text($ciphertext);

    # --- Stage 1: De-fractionation ---
    # Convert the ciphertext back into a long string of coordinate digits.
    my $coord_str = "";
    foreach my $char (split //, $norm_cipher) {
        $coord_str .= $char_map->{$char} if exists $char_map->{$char};
    }

    # --- Stage 2: Splitting Layers, Rows, and Columns ---
    # Split the coordinate string into three equal parts.
    my $group_len = length($coord_str) / 3;
    my $layers_str = substr($coord_str, 0, $group_len);
    my $rows_str   = substr($coord_str, $group_len, $group_len);
    my $cols_str   = substr($coord_str, $group_len * 2);

    # --- Stage 3: Reassembly ---
    # Reconstruct the original coordinate triplets and convert back to letters.
    my $plaintext = "";
    for my $i (0 .. $group_len - 1) {
        my $layer = substr($layers_str, $i, 1);
        my $row   = substr($rows_str, $i, 1);
        my $col   = substr($cols_str, $i, 1);
        my $triplet = "$layer$row$col";
        $plaintext .= $coord_map->{$triplet} if exists $coord_map->{$triplet};
    }
    return $plaintext;
}

=head2 info
 
 Returns a formatted string with detailed information about the Trifid cipher.
 
=cut
sub info {
    return qq(CIPHER: Trifid Cipher

DESCRIPTION:
    A classic fractionating cipher invented by Felix Delastelle, and an evolution
    of his Bifid cipher. It uses a 3x3x3 cube to fractionate each character into
    three coordinate numbers, which are then transposed and reassembled.

MECHANISM:
    1. A 3x3x3 cube (27 cells) is created from a secret key and the alphabet
       plus one extra symbol (e.g., '.').
    2. The plaintext is converted into coordinates. The layer, row, and column
       coordinates are written on three separate lines.
    3. The three lines of numbers are concatenated (layers, then rows, then columns).
    4. This new sequence is regrouped into triplets.
    5. Each new triplet of coordinates is converted back into a character using
       the same cube to produce the ciphertext.

MANUAL DECRYPTION:
    1. Create the same 3x3x3 cube from the secret key.
    2. Convert the ciphertext into a long string of coordinates.
    3. Split this string into three equal parts: the 'layers', 'rows', and 'columns' strings.
    4. Reconstruct the original coordinates by taking the first digit from each of the three
       strings, then the second, and so on.
    5. Convert these original coordinate triplets back into characters.
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;
