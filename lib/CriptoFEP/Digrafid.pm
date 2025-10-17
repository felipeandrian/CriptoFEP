package CriptoFEP::Digrafid;

use strict;
use warnings;

use lib 'lib';
use CriptoFEP::Utils qw(normalize_text);

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(digrafid_encrypt digrafid_decrypt info);

# --- Private Helper Function ---
# Generates the large 25x25 grid and its coordinate maps.
sub _generate_grid {
    my ($key) = @_;
    my %digraph_to_coords;
    my %coords_to_digraph;
    
    # 1. Create the base 25-letter alphabet (I/J combined).
    my @alphabet = ('A'..'H', 'I', 'K'..'Z');

    # 2. Create a shuffled alphabet based on the key.
    my $key_unique = normalize_text($key);
    $key_unique =~ s/J/I/g;
    my %seen_key;
    $key_unique = join '', grep { !$seen_key{$_}++ } split //, $key_unique;
    my $source_alphabet = $key_unique . join('', @alphabet);
    my %seen_alpha;
    my @shuffled_alphabet = grep { !$seen_alpha{$_}++ } split //, $source_alphabet;

    # 3. Generate all 625 digraphs in the new shuffled order.
    my @shuffled_digraphs;
    foreach my $l1 (@shuffled_alphabet) {
        foreach my $l2 (@shuffled_alphabet) {
            push @shuffled_digraphs, $l1 . $l2;
        }
    }
    
    # 4. Populate the forward and reverse coordinate maps.
    for my $i (0 .. $#shuffled_digraphs) {
        my $digraph = $shuffled_digraphs[$i];
        # Coordinates are two digits each (00-24).
        my $row = sprintf("%02d", int($i / 25));
        my $col = sprintf("%02d", $i % 25);
        my $coord_quad = "$row$col";
        
        $digraph_to_coords{$digraph} = $coord_quad;
        $coords_to_digraph{$coord_quad} = $digraph;
    }
    return (\%digraph_to_coords, \%coords_to_digraph);
}

# --- Cipher Logic ---
sub digrafid_encrypt {
    my ($plaintext, $key) = @_;
    my ($digraph_map, $coord_map) = _generate_grid($key);
    
    my $norm_plain = normalize_text($plaintext);
    $norm_plain =~ s/J/I/g;
    $norm_plain .= 'X' if length($norm_plain) % 2 != 0;

    # Fractionate: convert digraphs to coordinates, separating rows and columns.
    my ($rows_str, $cols_str) = ('', '');
    foreach my $pair (unpack '(A2)*', $norm_plain) {
        if (exists $digraph_map->{$pair}) {
            my ($row, $col) = ($digraph_map->{$pair} =~ /(\d{2})(\d{2})/);
            $rows_str .= $row;
            $cols_str .= $col;
        }
    }

    # Transpose and reassemble.
    my $combined = $rows_str . $cols_str;
    my $ciphertext = "";
    foreach my $quad (unpack '(A4)*', $combined) {
        $ciphertext .= $coord_map->{$quad} // '';
    }
    return $ciphertext;
}

sub digrafid_decrypt {
    my ($ciphertext, $key) = @_;
    my ($digraph_map, $coord_map) = _generate_grid($key);
    
    # De-fractionate: convert ciphertext back into a long coordinate string.
    my $coord_str = "";
    foreach my $pair (unpack '(A2)*', $ciphertext) {
        $coord_str .= $digraph_map->{$pair} if exists $digraph_map->{$pair};
    }

    # Split rows and columns.
    my $half_len = length($coord_str) / 2;
    my $rows_str = substr($coord_str, 0, $half_len);
    my $cols_str = substr($coord_str, $half_len);

    # Reassemble original coordinates and convert back to plaintext.
    my $plaintext = "";
    my @row_coords = unpack '(A2)*', $rows_str;
    my @col_coords = unpack '(A2)*', $cols_str;
    for my $i (0 .. $#row_coords) {
        my $quad = $row_coords[$i] . $col_coords[$i];
        $plaintext .= $coord_map->{$quad} if exists $coord_map->{$quad};
    }
    return $plaintext;
}

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

1;
