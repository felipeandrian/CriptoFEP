#
# CriptoFEP::Playfair
#
# This module provides the implementation for the Playfair cipher, a classic
# polygraphic substitution cipher that encrypts pairs of letters (digraphs).
#

package CriptoFEP::Playfair;

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
our @EXPORT_OK = qw(playfair_encrypt playfair_decrypt info);


# --- MODULE-PRIVATE HELPER SUBROUTINES ---

=head2 _generate_grid
 
 Internal function to generate the 5x5 Playfair grid and a coordinate map.
 
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
    my %seen; # Helper hash to track used characters.

    # The standard Playfair alphabet source, with 'J' omitted.
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
            # Stop once the 5x5 grid is complete.
            last if $row == 5;
        }
    }
    return (\@grid, \%coords);
}

=head2 _prepare_text
 
 Internal function to prepare plaintext for Playfair encryption.
 It converts the text into a list of valid digraphs (letter pairs).
 
 B<Parameters:>
   - $text (string): The raw plaintext.
 
 B<Returns:>
   - A reference to a list of digraphs (e.g., [ ['H','E'], ['L','X'], ['L','O'] ]).
 
=cut
sub _prepare_text {
    my ($text) = @_;
    my $prepared = normalize_text($text);
    $prepared =~ s/J/I/g;

    # Rule 1: Insert an 'X' between any two identical letters.
    # The 'while' loop ensures this works for sequences like 'LLLL' -> 'LXLXLX'.
    while ($prepared =~ s/(.)\1/$1X$1/g) {}

    # Rule 2: If the text has an odd number of letters, append an 'X'.
    if (length($prepared) % 2 != 0) {
        $prepared .= 'X';
    }
    
    # Use unpack to efficiently split the string into a list of two-character strings.
    return [ unpack '(A2)*', $prepared ];
}


# --- PUBLIC CIPHER SUBROUTINES ---

=head2 playfair_encrypt
 
 Encrypts plaintext using the Playfair cipher.
 
 B<Parameters:>
   - $plaintext (string): The plaintext to be encrypted.
   - $key (string): The secret key.
 
 B<Returns:>
   - (string): The resulting ciphertext.
 
=cut
sub playfair_encrypt {
    my ($plaintext, $key) = @_;
    my ($grid, $coords) = _generate_grid($key);
    my $digraphs = _prepare_text($plaintext);
    
    my $ciphertext = "";
    foreach my $pair_str (@$digraphs) {
        my ($l1, $l2) = split //, $pair_str;
        my ($r1, $c1) = @{ $coords->{$l1} };
        my ($r2, $c2) = @{ $coords->{$l2} };

        if ($r1 == $r2) { # Rule 1: Same row
            $ciphertext .= $grid->[$r1][($c1 + 1) % 5];
            $ciphertext .= $grid->[$r2][($c2 + 1) % 5];
        } elsif ($c1 == $c2) { # Rule 2: Same column
            $ciphertext .= $grid->[($r1 + 1) % 5][$c1];
            $ciphertext .= $grid->[($r2 + 1) % 5][$c2];
        } else { # Rule 3: Rectangle
            $ciphertext .= $grid->[$r1][$c2];
            $ciphertext .= $grid->[$r2][$c1];
        }
    }
    return $ciphertext;
}

=head2 playfair_decrypt
 
 Decrypts ciphertext using the Playfair cipher.
 
 B<Parameters:>
   - $ciphertext (string): The ciphertext to be decrypted.
   - $key (string): The secret key used for the original encryption.
 
 B<Returns:>
   - (string): The original plaintext, which may include padding 'X' characters.
 
=cut
sub playfair_decrypt {
    my ($ciphertext, $key) = @_;
    my ($grid, $coords) = _generate_grid($key);
    
    my @digraphs = unpack '(A2)*', normalize_text($ciphertext);
    my $plaintext = "";

    foreach my $pair (@digraphs) {
        my ($l1, $l2) = split //, $pair;
        # Defensive check in case of invalid ciphertext characters.
        next unless exists $coords->{$l1} && exists $coords->{$l2};

        my ($r1, $c1) = @{ $coords->{$l1} };
        my ($r2, $c2) = @{ $coords->{$l2} };

        if ($r1 == $r2) { # Rule 1: Same row (move left)
            $plaintext .= $grid->[$r1][($c1 - 1 + 5) % 5];
            $plaintext .= $grid->[$r2][($c2 - 1 + 5) % 5];
        } elsif ($c1 == $c2) { # Rule 2: Same column (move up)
            $plaintext .= $grid->[($r1 - 1 + 5) % 5][$c1];
            $plaintext .= $grid->[($r2 - 1 + 5) % 5][$c2];
        } else { # Rule 3: Rectangle (symmetrical operation)
            $plaintext .= $grid->[$r1][$c2];
            $plaintext .= $grid->[$r2][$c1];
        }
    }
    return $plaintext;
}

=head2 info
 
 Returns a formatted string with detailed information about the Playfair cipher.
 
=cut
sub info {
    return qq(CIPHER: Playfair Cipher

DESCRIPTION:
    A classic polygraphic substitution cipher invented by Charles Wheatstone in
    1854. It was the first cipher to encrypt pairs of letters (digraphs)
    instead of single letters, making it significantly more secure against
    frequency analysis.

MECHANISM (ENCRYPTION):
    1. Grid Generation: A 5x5 grid is created from a secret key. The key's
       unique letters are filled in first, followed by the remaining letters
       of the alphabet (with I and J treated as the same letter).

    2. Text Preparation: The plaintext is processed into pairs of letters.
       - If a pair consists of two identical letters (e.g., 'LL'), an 'X' is
         inserted between them ('LXL').
       - If the text has an odd number of letters, an 'X' is appended.
       - Example: "HELLO" becomes pairs "HE", "LX", "LO".

    3. Encryption Rules: Each pair is encrypted based on its position in the grid.
       - Same Row: Replace each letter with the one to its immediate right (wraps around).
       - Same Column: Replace each letter with the one immediately below it (wraps around).
       - Rectangle: Replace each letter with the one on the same row but at the
         other corner of the rectangle formed by the pair.

MANUAL DECRYPTION:
    Decryption is the exact inverse of the encryption rules.

    1. Prepare Grid: Generate the same 5x5 grid using the secret key.
    2. Group Ciphertext: Break the ciphertext into pairs of letters.
    3. Decryption Rules: For each pair:
       - Same Row: Replace each letter with the one to its immediate LEFT.
       - Same Column: Replace each letter with the one immediately ABOVE it.
       - Rectangle: This rule is symmetrical. Apply it exactly as in encryption.
    4. Post-processing: The decrypted text may contain extra 'X' characters that
       were inserted during preparation. These are typically removed by the human
       reader based on context.
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;