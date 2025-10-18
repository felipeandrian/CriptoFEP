#
# CriptoFEP::Nihilist
#
# This module provides an implementation for the Nihilist cipher, a classic
# superencipherment that combines a keyed Polybius square with a Vigenere-style
# key addition.
#

package CriptoFEP::Nihilist;

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
our @EXPORT_OK = qw(nihilist_encrypt nihilist_decrypt info);


# --- MODULE-PRIVATE HELPER SUBROUTINES ---

=head2 _generate_grid
 
 Internal function to generate the 5x5 Polybius square and its coordinate maps.
 This version uses 1-based indexing (coordinates 11-55) as is traditional for
 the Nihilist cipher.
 
 B<Parameters:>
   - $key (string): The secret key used to construct the mixed-alphabet grid.
 
 B<Returns:>
   - A list containing two references:
     1. A reference to a hash mapping each character to its two-digit coordinate.
     2. A reference to a hash mapping each coordinate back to its character.
 
=cut
sub _generate_grid {
    my ($key) = @_;
    my %char_to_coords;
    my %coords_to_char;
    
    # The alphabet source for a 5x5 grid, with 'I' and 'J' combined.
    my $alphabet = "ABCDEFGHIKLMNOPQRSTUVWXYZ";
    
    # Prepare the grid key: normalize, treat 'J' as 'I', and remove duplicates.
    my $key_unique = normalize_text($key);
    $key_unique =~ s/J/I/g;
    my %seen_key;
    $key_unique = join '', grep { !$seen_key{$_}++ } split //, $key_unique;
    
    # Create the full source string for the grid by prepending the key to the alphabet.
    my $source = $key_unique . $alphabet;
    
    # Generate a flat list of 25 unique characters for the grid.
    my %seen_source;
    my @flat_grid = grep { !$seen_source{$_}++ } split //, $source;

    # Populate the coordinate maps using 1-based indexing (rows 1-5, cols 1-5).
    my ($row, $col) = (1, 1);
    foreach my $char (@flat_grid) {
        my $coord_pair = "$row$col";
        $char_to_coords{$char} = $coord_pair;
        $coords_to_char{$coord_pair} = $char;

        $col++;
        # Move to the next row when the current one is full.
        if ($col > 5) {
            $col = 1;
            $row++;
            last if $row > 5; # Stop once the 5x5 grid is complete.
        }
    }
    return (\%char_to_coords, \%coords_to_char);
}


# --- PUBLIC CIPHER SUBROUTINES ---

=head2 nihilist_encrypt
 
 Encrypts plaintext using the Nihilist cipher.
 
 B<Parameters:>
   - $plaintext (string): The plaintext to be encrypted.
   - $key_pair (array ref): A reference to an array containing the two keys:
     - [$grid_key, $addition_key]
 
 B<Returns:>
   - (string): The resulting ciphertext, as a space-separated string of numbers.
 
=cut
sub nihilist_encrypt {
    my ($plaintext, $key_pair) = @_;
    my ($grid_key, $addition_key) = @$key_pair;

    my ($char_map) = _generate_grid($grid_key);
    
    # --- Stage 1: Convert both plaintext and addition key to coordinates ---
    my @plain_coords;
    my $norm_plain = normalize_text($plaintext);
    $norm_plain =~ s/J/I/g;
    foreach my $char (split //, $norm_plain) {
        push @plain_coords, $char_map->{$char} if exists $char_map->{$char};
    }
    
    my @key_coords;
    my $norm_key = normalize_text($addition_key);
    $norm_key =~ s/J/I/g;
    foreach my $char (split //, $norm_key) {
        push @key_coords, $char_map->{$char} if exists $char_map->{$char};
    }
    # Encryption is impossible without a valid addition key.
    return "" unless @key_coords;

    # --- Stage 2: Add the coordinate sequences ---
    my @cipher_numbers;
    for (my $i = 0; $i < @plain_coords; $i++) {
        # The key repeats cyclically, Vigenere-style.
        push @cipher_numbers, $plain_coords[$i] + $key_coords[$i % @key_coords];
    }
    
    return join(' ', @cipher_numbers);
}

=head2 nihilist_decrypt
 
 Decrypts ciphertext that was encrypted with the Nihilist cipher.
 
 B<Parameters:>
   - $ciphertext (string): The numeric, space-separated ciphertext.
   - $key_pair (array ref): A reference to the array of keys used for encryption.
 
 B<Returns:>
   - (string): The original plaintext.
 
=cut
sub nihilist_decrypt {
    my ($ciphertext, $key_pair) = @_;
    my ($grid_key, $addition_key) = @$key_pair;

    # Generate both forward and reverse maps, as they are both needed.
    my ($char_map, $coord_map) = _generate_grid($grid_key);
    
    # Convert the addition key into its coordinate sequence.
    my @key_coords;
    my $norm_key = normalize_text($addition_key);
    $norm_key =~ s/J/I/g;
    foreach my $char (split //, $norm_key) {
        push @key_coords, $char_map->{$char} if exists $char_map->{$char};
    }
    return "" unless @key_coords;

    # --- Stage 1: Subtract the key coordinates from the ciphertext numbers ---
    my @plain_coords;
    my @cipher_numbers = split / /, $ciphertext;
    for (my $i = 0; $i < @cipher_numbers; $i++) {
        push @plain_coords, $cipher_numbers[$i] - $key_coords[$i % @key_coords];
    }
    
    # --- Stage 2: Convert the resulting coordinates back to text ---
    my $plaintext = "";
    foreach my $coord (@plain_coords) {
        $plaintext .= $coord_map->{$coord} if exists $coord_map->{$coord};
    }
    return $plaintext;
}

=head2 info
 
 Returns a formatted string with detailed information about the Nihilist cipher.
 
=cut
sub info {
    return qq(CIPHER: Nihilist Cipher

DESCRIPTION:
    A historically significant cipher used by Russian Nihilists in the 19th century.
    It is a superencipherment, meaning it applies a second cryptographic process
    on top of a first one. It combines a Polybius square with a Vigenere-like
    key addition, resulting in a numeric ciphertext.

MECHANISM:
    - Requires two keys: a 'grid key' for the Polybius square and an 'addition key'.
    1. A 5x5 Polybius square is created from the 'grid key'.
    2. The plaintext is converted into a sequence of two-digit numbers (e.g., 11, 54)
       using this grid.
    3. The 'addition key' is also converted into a sequence of numbers using the same grid.
    4. The final ciphertext is produced by adding the plaintext numbers to the
       addition key numbers (repeating the key as necessary).
    - Example (grid key "NIHILIST", addition key "RUSSIAN"):
        - Plaintext "DYNAMITE" -> 25 54 11 22 35 12 21 31
        - Key "RUSSIAN"      -> 42 45 15 15 12 22 11
        - Result: 25+42, 54+45, ... -> "67 99 26 37 47 34 32 75"

MANUAL DECRYPTION:
    1. Generate the same Polybius grid from the 'grid key'.
    2. Convert the 'addition key' into its sequence of numbers.
    3. Subtract the key numbers from the ciphertext numbers (repeating the key as needed).
    4. Convert the resulting two-digit numbers back into letters using the grid.
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;
