#
# CriptoFEP::Digrafid
#
# This module provides an implementation for the Digrafid cipher, an advanced
# fractionating cipher operating on digraphs (pairs of letters) using a
# 25x25 keyed grid.
#
package CriptoFEP::Digrafid;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;

# --- MODULE IMPORTS ---
# Add the parent 'lib' directory to Perl's search path.
use lib 'lib';
# Import shared utilities for text normalization.
use CriptoFEP::Utils qw(normalize_text);

# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(digrafid_encrypt digrafid_decrypt info);

# --- Private Helper Function ---
=head2 _generate_grid
 
 Internal function to generate the large 25x25 (625-cell) grid and its
 associated forward and reverse lookup maps.
 
 B<Parameters:>
   - $key (string): The secret key used to shuffle the alphabet.
 
 B<Returns:>
   - A list containing two references:
     1. (hash ref): A map of {Digraph => "RRCC" coordinates}.
     2. (hash ref): A map of {"RRCC" coordinates => Digraph}.
 
=cut
# Generates the large 25x25 grid and its coordinate maps.
sub _generate_grid {
    my ($key) = @_;
    my %digraph_to_coords;
    my %coords_to_digraph;
    
    # 1. Create the base 25-letter alphabet (I/J combined).
    my @alphabet = ('A'..'H', 'I', 'K'..'Z');

    # 2. Create a shuffled 25-letter alphabet based on the key.
    my $key_unique = normalize_text($key);
    $key_unique =~ s/J/I/g; # Treat J as I
    my %seen_key;
    $key_unique = join '', grep { !$seen_key{$_}++ } split //, $key_unique;
    my $source_alphabet = $key_unique . join('', @alphabet);
    my %seen_alpha;
    my @shuffled_alphabet = grep { !$seen_alpha{$_}++ } split //, $source_alphabet;

    # 3. Generate all 625 possible digraphs in the new shuffled order.
    my @shuffled_digraphs;
    foreach my $l1 (@shuffled_alphabet) {
        foreach my $l2 (@shuffled_alphabet) {
            push @shuffled_digraphs, $l1 . $l2;
        }
    }
    
    # 4. Populate the forward and reverse coordinate maps.
    for my $i (0 .. $#shuffled_digraphs) {
        my $digraph = $shuffled_digraphs[$i];
        # Coordinates are two digits each (00-24) for row and col.
        my $row = sprintf("%02d", int($i / 25));
        my $col = sprintf("%02d", $i % 25);
        # A "quad" is the 4-digit "RRCC" coordinate pair.
        my $coord_quad = "$row$col";
        
        $digraph_to_coords{$digraph} = $coord_quad;
        $coords_to_digraph{$coord_quad} = $digraph;
    }
    return (\%digraph_to_coords, \%coords_to_digraph);
}

# --- PUBLIC CIPHER SUBROUTINES ---
=head2 digrafid_encrypt
 
 Encrypts plaintext using the Digrafid cipher.
 
 B<Parameters:>
   - $plaintext (string): The plaintext to be encrypted.
   - $key (string): The secret key for the grid.
 
 B<Returns:>
   - (string): The resulting ciphertext.
 
=cut
sub digrafid_encrypt {
    my ($plaintext, $key) = @_;
    # Generate the necessary lookup tables.
    my ($digraph_map, $coord_map) = _generate_grid($key);
    
    # --- 1. Preparation ---
    my $norm_plain = normalize_text($plaintext);
    $norm_plain =~ s/J/I/g; # Treat J as I
    # Ensure the text has an even number of letters (for digraphs).
    $norm_plain .= 'X' if length($norm_plain) % 2 != 0;

    # --- 2. Fractionation ---
    # Convert digraphs to coordinates, separating rows and columns.
    my ($rows_str, $cols_str) = ('', '');
    foreach my $pair (unpack '(A2)*', $norm_plain) {
        if (exists $digraph_map->{$pair}) {
            # Regex captures the "RR" (row) and "CC" (column) parts.
            my ($row, $col) = ($digraph_map->{$pair} =~ /(\d{2})(\d{2})/);
            $rows_str .= $row;
            $cols_str .= $col;
        }
    }

    # --- 3. Transposition & Reassembly ---
    # Concatenate all row coordinates, followed by all column coordinates.
    my $combined = $rows_str . $cols_str;
    my $ciphertext = "";
    # Re-group the combined string into 4-digit "RRCC" coordinates.
    foreach my $quad (unpack '(A4)*', $combined) {
        # Convert each new coordinate quad back into a ciphertext digraph.
        $ciphertext .= $coord_map->{$quad} // '';
    }
    return $ciphertext;
}

=head2 digrafid_decrypt
 
 Decrypts ciphertext that was encrypted with the Digrafid cipher.
 
 B<Parameters:>
   - $ciphertext (string): The ciphertext to be decrypted.
   - $key (string): The secret key used for the original encryption.
 
 B<Returns:>
   - (string): The original plaintext.
 
=cut
sub digrafid_decrypt {
    my ($ciphertext, $key) = @_;
    my ($digraph_map, $coord_map) = _generate_grid($key);
    
    # --- 1. De-fractionate ---
    # Convert ciphertext digraphs back into one long string of coordinates.
    my $coord_str = "";
    foreach my $pair (unpack '(A2)*', $ciphertext) {
        $coord_str .= $digraph_map->{$pair} if exists $digraph_map->{$pair};
    }

    # --- 2. Split (Reverse Transposition) ---
    # Split the coordinate string exactly in half to get the original rows and columns.
    my $half_len = length($coord_str) / 2;
    my $rows_str = substr($coord_str, 0, $half_len);
    my $cols_str = substr($coord_str, $half_len);

    # --- 3. Reassembly ---
    # Re-pair the row and column coordinates to reconstruct the original quads.
    my $plaintext = "";
    my @row_coords = unpack '(A2)*', $rows_str;
    my @col_coords = unpack '(A2)*', $cols_str;
    for my $i (0 .. $#row_coords) {
        my $quad = $row_coords[$i] . $col_coords[$i];
        # Convert each original coordinate quad back into a plaintext digraph.
        $plaintext .= $coord_map->{$quad} if exists $coord_map->{$quad};
    }
    return $plaintext;
}

=head2 info
 
 Returns a formatted string with detailed information about the Digrafid cipher.
 This serves as the dynamic help text for the '--info' command-line option.
 
 B<Parameters:> None
 
 B<Returns:>
   - (string): A multi-line help text.
 
=cut
sub info {
    return qq(CIPHER: Digrafid Cipher

DESCRIPTION:
    An advanced fractionating cipher invented by Felix Delastelle, and a significant
    evolution of his Bifid cipher. It operates on pairs of letters (digraphs)
    instead of single letters, making it much more secure and complex.

MECHANISM:
    The cipher uses a large 25x25 grid (625 cells) to map every possible
    digraph (AA, AB, AC...) to a unique two-part coordinate (row, column), where
    each part is a two-digit number from 00 to 24.

    1. Grid Generation: A 25x25 grid is created. The 625 digraphs are written
       into this grid in an order shuffled by a secret key.

    2. Fractionation: The plaintext is broken into digraphs. Each digraph is
       replaced by its coordinates. The row coordinates are written on one
       line, and the column coordinates on a line below.
       - Example (for 'ATTACK'): Pairs are AT, TA, CK
         - AT -> row 00, col 19
         - TA -> row 19, col 00
         - CK -> row 02, col 10
       - Rows String: "001902"
       - Columns String: "190010"

    3. Transposition: The two lines of numbers are concatenated (rows first,
       then columns): "001902190010".

    4. Reassembly: This new sequence is regrouped into new coordinates, and each
       new coordinate is converted back into a digraph using the same grid to
       produce the ciphertext.
       - New Coords: "0019", "0219", "1900"
       - Result: "AT", "CU", "TA" -> Ciphertext: "ATCUTK" (using an ordered grid for example)

MANUAL DECRYPTION:
    1. Create the same 25x25 grid from the secret key.
    2. Convert the ciphertext digraphs into a long string of coordinates.
    3. Split this string exactly in half. The first half is the 'rows' string,
       the second is the 'columns' string.
    4. Reconstruct the original coordinates by taking the first two digits from the
       'rows' string and the first two digits from the 'columns' string. Repeat for all digits.
    5. Convert these original coordinate pairs back into plaintext digraphs.
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;