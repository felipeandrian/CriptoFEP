#
# CriptoFEP::Scytale
#
# This module provides the implementation for the Scytale cipher, a classic
# transposition cipher. It rearranges the order of letters without substituting
# them, based on a fixed-width grid.
#

package CriptoFEP::Scytale;

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
our @EXPORT_OK = qw(scytale_encrypt scytale_decrypt info);


# --- CIPHER SUBROUTINES ---

=head2 scytale_encrypt
 
 Encrypts a given text using the Scytale transposition cipher.
 The plaintext is written into a grid row-by-row and read out column-by-column.
 
 B<Parameters:>
   - $text (string): The plaintext to be encrypted.
 
 B<Returns:>
   - (string): The resulting ciphertext. Spaces may be added for padding.
 
=cut
sub scytale_encrypt {
    # Unpack function arguments.
    my ($text) = @_;
    # The "key" or diameter of the rod, hardcoded to 5 rows for this implementation.
    my $rows = 5;

    my @chars = split //, $text;
    return "" unless @chars; # Return an empty string if input is empty.

    # Calculate the number of columns required to fit the entire text.
    # This is equivalent to the ceiling of (length / rows).
    my $cols = int((@chars + $rows - 1) / $rows);
    my $padded_length = $cols * $rows;

    # Pad the character array with spaces to form a perfect rectangle.
    push @chars, ' ' while @chars < $padded_length;

    my $ciphertext = "";
    # Read the grid column by column to generate the ciphertext.
    for my $c (0 .. $cols - 1) {
        for my $r (0 .. $rows - 1) {
            # Calculate the index of the character in the flat array.
            my $index = $r * $cols + $c;
            $ciphertext .= $chars[$index];
        }
    }
    
    return $ciphertext;
}

=head2 scytale_decrypt
 
 Decrypts a given text that was encrypted with the Scytale cipher.
 The ciphertext is written into a grid column-by-column and read out row-by-row.
 
 B<Parameters:>
   - $text (string): The ciphertext to be decrypted.
 
 B<Returns:>
   - (string): The original plaintext.
 
=cut
sub scytale_decrypt {
    # Unpack function arguments.
    my ($text) = @_;
    my $rows = 5;

    my @chars = split //, $text;
    return "" unless @chars;

    # Calculate the number of columns from the ciphertext length.
    my $cols = int((@chars + $rows - 1) / $rows);

    my $plaintext = "";
    # Read the grid row by row to reconstruct the plaintext.
    for my $r (0 .. $rows - 1) {
        for my $c (0 .. $cols - 1) {
            # The decryption formula is the inverse of the encryption index calculation.
            my $index = $c * $rows + $r;
            $plaintext .= $chars[$index] if defined $chars[$index];
        }
    }
    
    # Remove any trailing spaces that were added as padding during encryption.
    $plaintext =~ s/\s+$//;
    
    return $plaintext;
}

=head2 info
 
 Returns a formatted string containing detailed information about the Scytale cipher.
 This serves as the dynamic help text for the '--info' command-line option.
 
 B<Parameters:> None
 
 B<Returns:>
   - (string): A multi-line help text.
 
=cut
sub info {
    # qq() is used for a clean, multi-line string that respects formatting.
    return qq(CIPHER: Scytale Cipher

DESCRIPTION:
    One of the oldest known cryptographic devices, used by the ancient Greeks,
    particularly the Spartans. It is a transposition cipher that rearranges the
    letters of a message using a cylinder (the "scytale").

MECHANISM (ENCRYPTION):
    The message is written down a long strip of parchment wrapped around a
    cylinder of a specific diameter. When unwrapped, the letters on the strip
    appear jumbled. In computing terms:

    - The message is written into a grid, row by row.
    - The "key" is the number of rows, corresponding to the cylinder's diameter.
      (The CriptoFEP version uses a fixed key of 5 rows).
    - The ciphertext is formed by reading the grid column by column.
    - Example (with a key of 3 for clarity):
        - Plaintext: "ATTACK AT DAWN"
        - Grid (5 rows, 3 columns):
            ATT
            ACK
             AT
             DA
            WN
        - Ciphertext (read by columns): "AA  WTCADNTKTA "

MANUAL DECRYPTION:
    To decrypt, you must know the original key (the number of rows).

    - Calculate the grid dimensions: rows = key, cols = length(ciphertext) / key.
    - "Pour" the ciphertext into a new grid, filling it column by column.
    - The original message is revealed by reading the grid row by row.
    - Example (with key=3):
        - Ciphertext: "AKD T A TAN CTW AN"
        - Pour into 3 rows, column by column, to reconstruct the grid above.
        - Read across the rows to get "ATTACK AT DAWN".
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate that it has been
# loaded and compiled successfully.
1;