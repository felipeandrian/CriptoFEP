#
# CriptoFEP::RailFence
#
# This module provides the implementation for the Rail Fence (or Zig-Zag) cipher,
# a classic transposition cipher that rearranges characters without substitution.
#

package CriptoFEP::RailFence;

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
our @EXPORT_OK = qw(rail_fence_encrypt rail_fence_decrypt info);


# --- CIPHER SUBROUTINES ---

=head2 rail_fence_encrypt
 
 Encrypts plaintext using the Rail Fence cipher. The text is written in a
 zig-zag pattern across a specified number of rails and then read off rail by rail.
 
 B<Parameters:>
   - $text (string): The plaintext to be encrypted.
   - $key (integer): The number of rails to use for the transposition.
 
 B<Returns:>
   - (string): The resulting ciphertext.
 
=cut
sub rail_fence_encrypt {
    my ($text, $key) = @_;
    my $num_rails = int($key);

    # A single rail does not change the text, so return early.
    return $text if $num_rails <= 1;

    # Initialize an array of strings, one for each rail.
    my @rails;
    $rails[$_] = '' for 0..$num_rails-1;

    my $current_rail = 0;
    my $direction = 1; # 1 for moving down, -1 for moving up.

    # Iterate over each character of the plaintext.
    foreach my $char (split //, $text) {
        # Append the character to the current rail.
        $rails[$current_rail] .= $char;
        
        # Reverse direction when the top or bottom rail is reached.
        if ($current_rail == 0) {
            $direction = 1;
        } elsif ($current_rail == $num_rails - 1) {
            $direction = -1;
        }
        
        # Move to the next rail.
        $current_rail += $direction;
    }

    # Join all rails together to form the final ciphertext.
    return join '', @rails;
}

=head2 rail_fence_decrypt
 
 Decrypts ciphertext that was encrypted with the Rail Fence cipher.
 
 B<Parameters:>
   - $ciphertext (string): The ciphertext to be decrypted.
   - $key (integer): The number of rails used during encryption.
 
 B<Returns:>
   - (string): The original plaintext.
 
=cut
sub rail_fence_decrypt {
    my ($ciphertext, $key) = @_;
    my $num_rails = int($key);
    my $len = length($ciphertext);

    # A single rail does not change the text, so return early.
    return $ciphertext if $num_rails <= 1;
    
    # --- Step 1: Simulate the encryption path to determine rail lengths ---
    # Create a dummy grid to map out where each character would fall.
    my @rail_matrix;
    my $current_rail = 0;
    my $direction = 1;
    for my $i (0..$len-1) {
        # Mark the position in the grid with a placeholder (1).
        $rail_matrix[$current_rail][$i] = 1;
        
        # Reverse direction at the top and bottom rails.
        if ($current_rail == 0) {
            $direction = 1;
        } elsif ($current_rail == $num_rails - 1) {
            $direction = -1;
        }
        $current_rail += $direction;
    }

    # --- Step 2: "Pour" the ciphertext into the marked grid slots ---
    # Fill the grid rail by rail with the characters from the ciphertext.
    my $index = 0;
    for my $r (0..$num_rails-1) {
        for my $c (0..$len-1) {
            if (defined $rail_matrix[$r][$c] && $rail_matrix[$r][$c] == 1) {
                $rail_matrix[$r][$c] = substr($ciphertext, $index, 1);
                $index++;
            }
        }
    }

    # --- Step 3: Read the grid in a zig-zag pattern to get the plaintext ---
    my $plaintext = '';
    $current_rail = 0;
    $direction = 1;
    for (my $i = 0; $i < $len; $i++) {
        # Read the character from the current position in the zig-zag path.
        $plaintext .= $rail_matrix[$current_rail][$i];
        
        # Move along the zig-zag path.
        if ($current_rail == 0) {
            $direction = 1;
        } elsif ($current_rail == $num_rails - 1) {
            $direction = -1;
        }
        $current_rail += $direction;
    }
    
    return $plaintext;
}

=head2 info
 
 Returns a formatted string with detailed information about the Rail Fence cipher.
 
=cut
sub info {
    return qq(CIPHER: Rail Fence Cipher (Zig-Zag Cipher)

DESCRIPTION:
    A classic transposition cipher that jumbles the letters of a message by
    writing them in a zig-zag pattern across a number of imaginary "rails".

MECHANISM (ENCRYPTION):
    - The key is a number that specifies how many rails to use.
    - The plaintext is written downwards and upwards in a zig-zag motion across
      the rails.
    - The ciphertext is formed by reading all the letters from the top rail first,
      then the second rail, and so on.
    - Example (with key=3):
        - Plaintext: "WE ARE DISCOVERED"
        - Zig-zag pattern:
            W . . . E . . . C . . . R . .
            . E . R . D . S . O . E . E .
            . . A . . . I . . . V . . . D
        - Ciphertext (reading rail by rail): "WECRERDSOEEAIVD"

MANUAL DECRYPTION:
    To decrypt, you must know the key (number of rails). The process involves
    reconstructing the rails.

    1. Simulate the encryption path on an empty grid of the same length as the
       ciphertext to determine how many letters belong to each rail.
    2. "Cut" the ciphertext into pieces corresponding to the calculated rail lengths.
    3. You now have the original rails. Reconstruct the message by reading the
       rails in a zig-zag pattern, taking one letter from each rail in sequence.
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;