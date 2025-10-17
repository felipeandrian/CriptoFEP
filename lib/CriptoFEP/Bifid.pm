#
# CriptoFEP::Bifid
#
# This module provides the implementation for the Bifid cipher, a classic
# fractionating cipher that combines a Polybius square with a simple transposition.
#

package CriptoFEP::Bifid;

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
our @EXPORT_OK = qw(bifid_encrypt bifid_decrypt info);


# --- MODULE-PRIVATE HELPER SUBROUTINES ---

=head2 _generate_grid
 
 Internal function to generate the 5x5 Polybius-style grid and its coordinate maps.
 The grid uses 0-based indexing for rows and columns (0-4).
 
 B<Parameters:>
   - $key (string): The secret key used to construct the mixed-alphabet grid.
 
 B<Returns:>
   - A list containing two references:
     1. A reference to a hash mapping each character to its "row-col" coordinate string.
     2. A reference to a hash mapping each coordinate string back to its character.
 
=cut
sub _generate_grid {
    my ($key) = @_;
    my %char_to_coords;
    my %coords_to_char;
    
    # The standard alphabet source for a 5x5 grid, with 'I' and 'J' combined.
    my $alphabet = "ABCDEFGHIKLMNOPQRSTUVWXYZ";
    
    # Prepare the grid key: normalize, treat 'J' as 'I', and remove duplicates.
    my $key_unique = normalize_text($key);
    $key_unique =~ s/J/I/g;
    my %seen;
    $key_unique = join '', grep { !$seen{$_}++ } split //, $key_unique;
    
    # Create the full source string for the grid by prepending the key to the alphabet.
    my $source = $key_unique . $alphabet;
    %seen = (); # Reset 'seen' hash for the final pass.

    my ($row, $col) = (0, 0);
    # Populate the coordinate maps from the flat grid source.
    foreach my $char (split //, $source) {
        next if $seen{$char}; # Skip characters already processed.
        
        my $coord_pair = "$row$col";
        $char_to_coords{$char} = $coord_pair;
        $coords_to_char{$coord_pair} = $char;
        $seen{$char} = 1;

        $col++;
        # Move to the next row when the current one is full.
        if ($col == 5) {
            $col = 0; $row++;
            last if $row == 5;
        }
    }
    return (\%char_to_coords, \%coords_to_char);
}


# --- PUBLIC CIPHER SUBROUTINES ---

=head2 bifid_encrypt
 
 Encrypts plaintext using the Bifid cipher.
 
 B<Parameters:>
   - $plaintext (string): The plaintext to be encrypted.
   - $key (string): The secret key for generating the grid.
 
 B<Returns:>
   - (string): The resulting ciphertext.
 
=cut
sub bifid_encrypt {
    my ($plaintext, $key) = @_;
    my ($char_map, $coord_map) = _generate_grid($key);
    my $norm_plain = normalize_text($plaintext);
    $norm_plain =~ s/J/I/g;

    # --- Stage 1: Fractionation ---
    # Convert each character into its coordinates and separate them into two strings: one for rows, one for columns.
    my ($rows_str, $cols_str) = ('', '');
    foreach my $char (split //, $norm_plain) {
        if (exists $char_map->{$char}) {
            my ($row, $col) = split //, $char_map->{$char};
            $rows_str .= $row;
            $cols_str .= $col;
        }
    }

    # --- Stage 2: Transposition ---
    # Concatenate the row string and the column string.
    my $combined = $rows_str . $cols_str;
    
    # --- Stage 3: Reassembly ---
    # Group the combined string into new coordinate pairs and convert back to letters.
    my $ciphertext = "";
    foreach my $pair (unpack '(A2)*', $combined) {
        $ciphertext .= $coord_map->{$pair} if exists $coord_map->{$pair};
    }
    return $ciphertext;
}

=head2 bifid_decrypt
 
 Decrypts ciphertext that was encrypted with the Bifid cipher.
 
 B<Parameters:>
   - $ciphertext (string): The ciphertext to be decrypted.
   - $key (string): The secret key used for the original encryption.
 
 B<Returns:>
   - (string): The original plaintext.
 
=cut
sub bifid_decrypt {
    my ($ciphertext, $key) = @_;
    my ($char_map, $coord_map) = _generate_grid($key);
    my $norm_cipher = normalize_text($ciphertext);
    $norm_cipher =~ s/J/I/g;

    # --- Stage 1: De-fractionation ---
    # Convert the ciphertext back into a long string of coordinate digits.
    my $coord_str = "";
    foreach my $char (split //, $norm_cipher) {
        $coord_str .= $char_map->{$char} if exists $char_map->{$char};
    }

    # --- Stage 2: Splitting Rows and Columns ---
    # Split the coordinate string exactly in half to separate the row and column components.
    my $half_len = length($coord_str) / 2;
    my $rows_str = substr($coord_str, 0, $half_len);
    my $cols_str = substr($coord_str, $half_len);

    # --- Stage 3: Reassembly ---
    # Reconstruct the original coordinate pairs by taking one digit from the row string
    # and one from the column string, then convert back to letters.
    my $plaintext = "";
    for my $i (0 .. $half_len - 1) {
        my $row = substr($rows_str, $i, 1);
        my $col = substr($cols_str, $i, 1);
        my $pair = "$row$col";
        $plaintext .= $coord_map->{$pair} if exists $coord_map->{$pair};
    }
    return $plaintext;
}

=head2 info
 
 Returns a formatted string with detailed information about the Bifid cipher.
 
=cut
sub info {
    return qq(CIPHER: Bifid Cipher

DESCRIPTION:
    A classic fractionating cipher invented by Felix Delastelle. It combines
    Polybius square substitution with transposition to obscure letter frequencies
    far more effectively than a simple substitution cipher.

MECHANISM:
    1. A 5x5 Polybius square is created from a secret key.
    2. The plaintext is converted into coordinates. The row coordinates are written
       on one line, and the column coordinates on a line below.
       - Example (for 'HI'): Rows -> 22, Columns -> 34
    3. The two lines of numbers are concatenated (rows first, then columns).
       - Example: 2234
    4. This new sequence of numbers is regrouped into pairs.
       - Example: 22, 34
    5. Each new pair of coordinates is converted back into a letter using the
       same grid to produce the ciphertext.
       - Example: 22 -> G, 34 -> P. Ciphertext is "GP".

MANUAL DECRYPTION:
    1. Create the same 5x5 grid from the secret key.
    2. Convert the ciphertext into a long string of coordinates.
    3. Split this string exactly in half. The first half is the 'rows' string,
       the second is the 'columns' string.
    4. Reconstruct the original coordinates by taking the first digit from the
       'rows' string and the first digit from the 'columns' string. Repeat for all digits.
    5. Convert these original coordinate pairs back into letters.
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;
