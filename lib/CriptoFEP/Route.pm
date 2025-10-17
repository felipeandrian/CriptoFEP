#
# CriptoFEP::Route
#
# This module provides an implementation for the Route Cipher, a type of
# transposition cipher where the plaintext is written into a grid following a
# specific path. This version uses a clockwise inward spiral.
#

package CriptoFEP::Route;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;


# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(route_encrypt route_decrypt info);


# --- PUBLIC CIPHER SUBROUTINES ---

=head2 route_encrypt
 
 Encrypts plaintext using a clockwise inward spiral Route Cipher.
 
 B<Parameters:>
   - $plaintext (string): The plaintext to be encrypted.
   - $key (integer): The number of columns in the grid.
 
 B<Returns:>
   - (string): The resulting ciphertext.
 
=cut
sub route_encrypt {
    my ($plaintext, $key) = @_;
    my $num_cols = int($key);
    # If the key is trivial, no transposition occurs.
    return $plaintext if $num_cols <= 1;

    my $text_len = length($plaintext);
    # Calculate the number of rows required to fit the entire text.
    my $num_rows = int(($text_len + $num_cols - 1) / $num_cols);
    
    # Pad the plaintext with spaces to form a perfect rectangular grid.
    $plaintext .= ' ' x (($num_cols * $num_rows) - $text_len);
    my @chars = split //, $plaintext;
    
    my @grid;
    # Initialize grid with placeholders to prevent warnings.
    for my $r (0..$num_rows-1) { for my $c (0..$num_cols-1) { $grid[$r][$c] = ''; } }

    # --- Spiral Navigation Logic for Writing ---
    # These variables track the boundaries of the spiral path.
    my ($row, $col) = (0, 0);
    my ($min_row, $max_row) = (0, $num_rows - 1);
    my ($min_col, $max_col) = (0, $num_cols - 1);
    my $direction = 'right';

    # Iterate over each character and place it in the grid according to the spiral path.
    foreach my $char (@chars) {
        $grid[$row][$col] = $char;

        # State machine to control the spiral movement.
        if ($direction eq 'right') {
            # When we hit the right wall, change direction to 'down' and shrink the boundary.
            if ($col == $max_col) { $direction = 'down'; $min_row++; $row++; }
            else { $col++; }
        } elsif ($direction eq 'down') {
            if ($row == $max_row) { $direction = 'left'; $max_col--; $col--; }
            else { $row++; }
        } elsif ($direction eq 'left') {
            if ($col == $min_col) { $direction = 'up'; $max_row--; $row--; }
            else { $col--; }
        } elsif ($direction eq 'up') {
            if ($row == $min_row) { $direction = 'right'; $min_col++; $col++; }
            else { $row--; }
        }
    }
    
    # Read the grid normally (row by row) to get the final ciphertext.
    my $ciphertext = "";
    for my $r (0..$num_rows-1) { $ciphertext .= join '', @{$grid[$r]}; }
    return $ciphertext;
}

=head2 route_decrypt
 
 Decrypts ciphertext that was encrypted with the spiral Route Cipher.
 
 B<Parameters:>
   - $ciphertext (string): The ciphertext to be decrypted.
   - $key (integer): The number of columns used for the original encryption.
 
 B<Returns:>
   - (string): The original plaintext.
 
=cut
sub route_decrypt {
    my ($ciphertext, $key) = @_;
    my $num_cols = int($key);
    my $text_len = length($ciphertext);
    return $ciphertext if $num_cols <= 1 || $text_len == 0;

    # Because encryption always creates a perfect rectangle, the number of rows is a simple division.
    my $num_rows = int($text_len / $num_cols);
    my @chars = split //, $ciphertext;
    
    # --- Step 1: "Pour" the ciphertext into the grid row by row ---
    my @grid;
    for my $r (0..$num_rows-1) {
        for my $c (0..$num_cols-1) {
            $grid[$r][$c] = $chars[$r * $num_cols + $c];
        }
    }

    # --- Step 2: Read the grid following the same spiral path as encryption ---
    my $plaintext = "";
    # Initialize the same boundary and state variables as in the encryption function.
    my ($row, $col) = (0, 0);
    my ($min_row, $max_row) = (0, $num_rows - 1);
    my ($min_col, $max_col) = (0, $num_cols - 1);
    my $direction = 'right';

    # Read characters from the grid by traversing the spiral path.
    for (1..$text_len) {
        $plaintext .= $grid[$row][$col];
        
        # The state machine for movement is identical to the encryption function.
        if ($direction eq 'right') {
            if ($col == $max_col) { $direction = 'down'; $min_row++; $row++; }
            else { $col++; }
        } elsif ($direction eq 'down') {
            if ($row == $max_row) { $direction = 'left'; $max_col--; $col--; }
            else { $row++; }
        } elsif ($direction eq 'left') {
            if ($col == $min_col) { $direction = 'up'; $max_row--; $row--; }
            else { $col--; }
        } elsif ($direction eq 'up') {
            if ($row == $min_row) { $direction = 'right'; $min_col++; $col++; }
            else { $row--; }
        }
    }
    
    # Remove any trailing spaces that were added as padding during encryption.
    $plaintext =~ s/\s+$//;
    return $plaintext;
}

=head2 info
 
 Returns a formatted string with detailed information about the Route cipher.
 
=cut
sub info {
    return qq(CIPHER: Route Cipher (Clockwise Inward Spiral)

DESCRIPTION:
    A transposition cipher where the plaintext is written into a grid following a
    specific path, or "route". The ciphertext is then read from the grid in a
    standard row-by-row order. Many different routes are possible; this version
    implements a clockwise inward spiral.

MECHANISM (CriptoFEP Version):
    - The key is a number specifying the number of columns in the grid.
    - Encryption Path: The plaintext is written into the grid starting at the
      top-left corner and spiraling inwards in a clockwise direction.
    - Ciphertext Reading: The ciphertext is formed by reading the filled grid
      from left-to-right, top-to-bottom.

MANUAL DECRYPTION:
    1. Calculate grid dimensions: cols = key, rows = length(ciphertext) / key.
    2. "Pour" the ciphertext into a new grid, filling it ROW BY ROW.
    3. The original message is revealed by reading the characters from the grid
       following the same clockwise inward spiral path used for encryption.
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;
