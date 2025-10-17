#
# CriptoFEP::TwoSquare
#
# This module provides the implementation for the Two-Square cipher, a polygraphic
# substitution cipher that encrypts pairs of letters using two distinct keyed grids.
#

package CriptoFEP::TwoSquare;

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
our @EXPORT_OK = qw(two_square_encrypt two_square_decrypt info);


# --- MODULE-PRIVATE HELPER SUBROUTINES ---

=head2 _generate_grid
 
 Internal function to generate a 5x5 Polybius-style grid and a coordinate map.
 This logic is reused from the Playfair cipher implementation.
 
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

=head2 two_square_encrypt
 
 Encrypts plaintext using the Two-Square cipher.
 
 B<Parameters:>
   - $plaintext (string): The plaintext to be encrypted.
   - $key_pair (array ref): A reference to an array containing the two keys:
     - [$key1, $key2]
 
 B<Returns:>
   - (string): The resulting ciphertext.
 
=cut
sub two_square_encrypt {
    my ($plaintext, $key_pair) = @_;
    my ($key1, $key2) = @$key_pair;

    # Generate the two separate grids and their coordinate maps.
    my ($grid1, $coords1) = _generate_grid($key1);
    my ($grid2, $coords2) = _generate_grid($key2);

    # Prepare the plaintext: normalize, treat J as I, and pad if necessary.
    my $norm_plain = normalize_text($plaintext);
    $norm_plain =~ s/J/I/g;
    $norm_plain .= 'X' if length($norm_plain) % 2 != 0;

    my $ciphertext = "";
    # Process the plaintext as a series of two-character pairs (digraphs).
    foreach my $pair (unpack '(A2)*', $norm_plain) {
        my ($l1, $l2) = split //, $pair;
        
        # Ensure both letters exist in their respective grids before processing.
        next unless exists $coords1->{$l1} && exists $coords2->{$l2};

        # Find the coordinates of the first letter in grid 1 and the second in grid 2.
        my ($r1, $c1) = @{ $coords1->{$l1} };
        my ($r2, $c2) = @{ $coords2->{$l2} };
        
        # Apply the rectangle rule: the ciphertext letters are at the opposite corners.
        # First ciphertext letter: same row as l1, same column as l2.
        $ciphertext .= $grid1->[$r1][$c2];
        # Second ciphertext letter: same row as l2, same column as l1.
        $ciphertext .= $grid2->[$r2][$c1];
    }
    return $ciphertext;
}

=head2 two_square_decrypt
 
 Decrypts ciphertext that was encrypted with the Two-Square cipher.
 The algorithm is symmetrical, so this function is an alias for the encryption function.
 
 B<Parameters:>
   - $ciphertext (string): The ciphertext to be decrypted.
   - $key_pair (array ref): A reference to the array of keys used for encryption.
 
 B<Returns:>
   - (string): The original plaintext.
 
=cut
sub two_square_decrypt {
    # The Two-Square cipher is reciprocal; the same process encrypts and decrypts.
    # This elegant solution avoids code duplication by delegating directly.
    return two_square_encrypt(@_);
}

=head2 info
 
 Returns a formatted string with detailed information about the Two-Square cipher.
 
=cut
sub info {
    return qq(CIPHER: Two-Square Cipher (Double Playfair)

DESCRIPTION:
    A polygraphic substitution cipher that improves on the Playfair cipher by
    using two 5x5 grids instead of one, which makes it more secure. It operates
    on pairs of letters (digraphs).

MECHANISM:
    - Two 5x5 grids are generated, each from a different secret key (Key 1 and Key 2).
    - The plaintext is broken into pairs of letters.
    - For each pair (e.g., "HI"):
        1. Find the first letter ('H') in the first grid.
        2. Find the second letter ('I') in the second grid.
        3. These two letters form the corners of a rectangle that can span both grids.
        4. The ciphertext letters are the other two corners of the rectangle:
           - The first ciphertext letter is on the same row as 'H' and the same column as 'I'.
           - The second ciphertext letter is on the same row as 'I' and the same column as 'H'.
    - Decryption is the exact same process, making the cipher symmetrical.
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;
