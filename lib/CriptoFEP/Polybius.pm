#
# CriptoFEP::Polybius
#
# This module provides the implementation for the Polybius Square cipher, a classic
# substitution method that maps alphabetic characters to numeric coordinates.
#

package CriptoFEP::Polybius;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;
# Ensure that the source code can contain and process UTF-8 characters.
use utf8;


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
our @EXPORT_OK = qw(polybius_encrypt polybius_decrypt info);


# --- MODULE-PRIVATE DATA ---

# Defines the standard 5x5 Polybius square, mapping each letter to its
# 'row-column' coordinate pair. 'K' is included, but 'J' is omitted.
my %polybius_map = (
    'A' => '11', 'B' => '12', 'C' => '13', 'D' => '14', 'E' => '15',
    'F' => '21', 'G' => '22', 'H' => '23', 'I' => '24', 'K' => '25',
    'L' => '31', 'M' => '32', 'N' => '33', 'O' => '34', 'P' => '35',
    'Q' => '41', 'R' => '42', 'S' => '43', 'T' => '44', 'U' => '45',
    'V' => '51', 'W' => '52', 'X' => '53', 'Y' => '54', 'Z' => '55',
);

# Creates the reverse map for efficient decryption by swapping keys and values.
my %polybius_reverse_map = reverse %polybius_map;


# --- CIPHER SUBROUTINES ---

=head2 polybius_encrypt
 
 Encrypts plaintext by substituting each character with its corresponding
 Polybius Square coordinate pair.
 
 B<Parameters:>
   - $text (string): The plaintext to be encrypted.
 
 B<Returns:>
   - (string): The resulting ciphertext, as a continuous string of digits.
 
=cut
sub polybius_encrypt {
    my ($text) = @_;

    # Sanitize the input to uppercase A-Z characters only.
    my $normalized_text = normalize_text($text);
    # Per the Polybius standard, 'J' is treated as 'I' to fit the alphabet
    # into the 25 cells of a 5x5 grid.
    $normalized_text =~ s/J/I/g;
    
    my $output = "";
    # Iterate over each character of the normalized plaintext.
    foreach my $char (split //, $normalized_text) {
        # Append the corresponding coordinate pair if the character exists in the map.
        $output .= $polybius_map{$char} if exists $polybius_map{$char};
    }
    
    return $output;
}

=head2 polybius_decrypt
 
 Decrypts a string of Polybius coordinates back into plaintext.
 
 B<Parameters:>
   - $text (string): The ciphertext, consisting of pairs of digits.
 
 B<Returns:>
   - (string): The original plaintext (in uppercase).
 
=cut
sub polybius_decrypt {
    my ($text) = @_;

    # Sanitize the input to ensure it only contains digits.
    $text =~ s/[^0-9]//g;
    my $output = "";
    
    # Use unpack with the '(A2)*' template to efficiently split the string
    # into a list of non-overlapping pairs of two characters (e.g., "231531" -> "23", "15", "31").
    foreach my $pair (unpack '(A2)*', $text) {
        # Look up the pair in the reverse map and append the corresponding character.
        $output .= $polybius_reverse_map{$pair} if exists $polybius_reverse_map{$pair};
    }
    
    return $output;
}

=head2 info
 
 Returns a formatted string containing detailed information about the Polybius Square cipher.
 
 B<Parameters:> None
 
 B<Returns:>
   - (string): A multi-line help text.
 
=cut
sub info {
    # qq() is used for a clean, multi-line string that respects formatting.
    return qq(CIPHER: Polybius Square Cipher

DESCRIPTION:
    An ancient cipher created by the Greek historian Polybius. It is a simple
    substitution cipher that converts letters into pairs of numbers using a
    5x5 grid, known as the Polybius Square.

MECHANISM (ENCRYPTION):
    - A 5x5 grid is filled with the letters of the alphabet, typically combining
      'I' and 'J' in the same cell to fit all 26 letters into 25 spaces.
    - Each letter is then represented by its coordinates (row and column).
    - The CriptoFEP version uses the standard grid where 'A' is at (1,1), 'B' at (1,2), etc.,
      and 'I' takes the place of 'J'.
    - Example: 'HELLO' becomes "2315313134".

MANUAL DECRYPTION:
    To decrypt, you simply reverse the process.

    - Take the ciphertext and break it into pairs of numbers.
    - For each pair, find the corresponding letter in the 5x5 grid.
    - Example: Let's decrypt "2315313134".
        1. Break into pairs: 23, 15, 31, 31, 34.
        2. Look up each pair in the grid:
           - 23 -> Row 2, Col 3 -> 'H'
           - 15 -> Row 1, Col 5 -> 'E'
           - 31 -> Row 3, Col 1 -> 'L'
           - 31 -> Row 3, Col 1 -> 'L'
           - 34 -> Row 3, Col 4 -> 'O'
        3. The result is "HELLO".
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate that it has been
# loaded and compiled successfully.
1;