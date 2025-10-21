#
# CriptoFEP::Beaufort
#
# This module provides an implementation for the Beaufort cipher.
# It is a polyalphabetic substitution cipher, similar to the standard Vigenere,
# but it is reciprocal (its own inverse) due to its C = (K - P) formula.
#
package CriptoFEP::Beaufort;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;
use utf8;

# --- MODULE IMPORTS ---
# Add the parent 'lib' directory to Perl's search path.
use lib 'lib';
# Import shared utilities: text normalization and alphabet mappings.
use CriptoFEP::Utils qw(normalize_text $alphabet_list_ref $alphabet_map_ref);

# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Note that we only need to export ONE cipher function!
# 'beaufort_cipher' handles both encryption and decryption.
our @EXPORT_OK = qw(beaufort_cipher info);

# --- CIPHER LOGIC ---

=head2 beaufort_cipher
 
 Performs the Beaufort substitution on a given text.
 Since the Beaufort cipher is reciprocal (its own inverse), this
 single function handles both encryption and decryption.
 
 B<Parameters:>
   - $text (string): The text to be encrypted (or decrypted).
   - $key (string): The secret keyword.
 
 B<Returns:>
   - (string): The resulting ciphertext (or plaintext).
 
=cut
sub beaufort_cipher {
    my ($text, $key) = @_;
    # Sanitize the input text and key.
    my $norm_text = normalize_text($text);
    my $norm_key  = normalize_text($key);
    # Return the normalized text if the key is empty.
    return $norm_text unless length($norm_key);
    
    my $output = "";
    my @text_chars = split //, $norm_text;
    my @key_chars  = split //, $norm_key;
    
    # Iterate over each character of the normalized text.
    for (my $i = 0; $i < @text_chars; $i++) {
        # Get the numeric index of the plaintext/ciphertext character.
        my $p_idx = $alphabet_map_ref->{ $text_chars[$i] };
        
        # The key repeats cyclically (same as standard Vigenere).
        # The modulo operator ensures the key wraps around.
        my $k_idx = $alphabet_map_ref->{ $key_chars[$i % @key_chars] };
        
        # --- THE CRUCIAL DIFFERENCE: The mathematical formula ---
        # Vigenere was: ($p_idx + $k_idx) % 26
        # Beaufort is:  ($k_idx - $p_idx) % 26
        # We add 26 to handle potential negative results (e.g., 'E'-'T' = 4-19 = -15).
        my $c_idx = ($k_idx - $p_idx + 26) % 26;
        
        # Convert the new index back to a letter and append it.
        $output .= $alphabet_list_ref->[$c_idx];
    }
    return $output;
}

=head2 info
 
 Returns a formatted string with detailed information about the Beaufort cipher.
 This serves as the dynamic help text for the '--info' command-line option.
 
 B<Parameters:> None
 
 B<Returns:>
   - (string): A multi-line help text.
 
=cut
sub info {
    return qq(CIPHER: Beaufort Cipher

DESCRIPTION:
    A polyalphabetic substitution cipher, similar to Vigenere, but which uses
    a different mathematical formula.

MECHANISM:
    - It uses a repeating keyword, just like the standard Vigenere cipher.
    - The key difference is the formula: C = (K - P) mod 26.
    - A key property of this cipher is that it is reciprocal (its own inverse).
      The exact same algorithm is used to encrypt and decrypt.
    - Encrypt: C = (K - P) mod 26
    - Decrypt: P = (K - C) mod 26
    - Example (Key: "LEMON"):
        - Plaintext: "ATTACK"
        - Running Key: "LEMONL"
        - 'L'-'A' (11-0)=11 -> L
        - 'E'-'T' (4-19)=-15=11 -> L
        - 'M'-'T' (12-19)=-7=19 -> T
        - Result: "LLTOLB"
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.

1;
