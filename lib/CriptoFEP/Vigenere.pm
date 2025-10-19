#
# CriptoFEP::Vigenere
#
# This module provides an implementation for the Vigenere cipher, specifically
# the more secure "Autokey" variant. It is a polyalphabetic substitution cipher
# that uses a running key composed of a keyword and the plaintext itself.
#

package CriptoFEP::Vigenere;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;
use utf8;

# --- MODULE IMPORTS ---
# Add the parent 'lib' directory to Perl's search path to find our custom modules.
use lib 'lib';
# Import shared utilities: text normalization and alphabet mappings from the Utils module.
use CriptoFEP::Utils qw(normalize_text $alphabet_list_ref $alphabet_map_ref);


# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(vigenere_encrypt vigenere_decrypt info);


# --- PUBLIC CIPHER SUBROUTINES ---

=head2 vigenere_encrypt
 
 Encrypts plaintext using the Autokey Vigenere cipher.
 
 B<Parameters:>
   - $plaintext (string): The plaintext to be encrypted.
   - $key (string): The secret keyword.
 
 B<Returns:>
   - (string): The resulting ciphertext.
 
=cut
sub vigenere_encrypt {
    my ($plaintext, $key) = @_;
    
    my $norm_plain = normalize_text($plaintext);
    my $norm_key   = normalize_text($key);
    my $ciphertext = "";

    my @plain_chars = split //, $norm_plain;
    my @key_chars   = split //, $norm_key;

    # Iterate over each character of the normalized plaintext.
    for (my $i = 0; $i < @plain_chars; $i++) {
        my $p_idx = $alphabet_map_ref->{ $plain_chars[$i] };
        
        # --- Autokey Logic ---
        # The running key is the initial keyword, followed by the plaintext itself.
        my $k_idx;
        if ($i < @key_chars) {
            # For the first part, use the characters from the keyword.
            $k_idx = $alphabet_map_ref->{ $key_chars[$i] };
        } else {
            # After the keyword is exhausted, use the preceding plaintext characters as the key.
            my $autokey_char_index = $i - @key_chars;
            $k_idx = $alphabet_map_ref->{ $plain_chars[$autokey_char_index] };
        }
        
        # Apply the Vigenere encryption formula: E(p) = (p + k) mod 26.
        my $c_idx = ($p_idx + $k_idx) % 26;
        $ciphertext .= $alphabet_list_ref->[$c_idx];
    }
    return $ciphertext;
}

=head2 vigenere_decrypt
 
 Decrypts ciphertext that was encrypted with the Autokey Vigenere cipher.
 
 B<Parameters:>
   - $ciphertext (string): The ciphertext to be decrypted.
   - $key (string): The secret keyword used for the original encryption.
 
 B<Returns:>
   - (string): The original plaintext.
 
=cut
sub vigenere_decrypt {
    my ($ciphertext, $key) = @_;
    
    my $norm_cipher = normalize_text($ciphertext);
    my $norm_key    = normalize_text($key);
    my $plaintext = "";

    my @cipher_chars = split //, $norm_cipher;
    my @key_chars    = split //, $norm_key;

    # Iterate over each character of the normalized ciphertext.
    for (my $i = 0; $i < @cipher_chars; $i++) {
        my $c_idx = $alphabet_map_ref->{ $cipher_chars[$i] };
        
        # --- Autokey Logic ---
        # The running key for decryption is built dynamically.
        my $k_idx;
        if ($i < @key_chars) {
            # For the first part, use the characters from the keyword.
            $k_idx = $alphabet_map_ref->{ $key_chars[$i] };
        } else {
            # After the keyword is exhausted, use the previously *decrypted*
            # plaintext characters to continue the key.
            my $autokey_char_index = $i - @key_chars;
            my $prev_plain_char = substr($plaintext, $autokey_char_index, 1);
            $k_idx = $alphabet_map_ref->{$prev_plain_char};
        }
        
        # Apply the Vigenere decryption formula: D(c) = (c - k) mod 26.
        # Adding 26 before the modulo handles negative results correctly.
        my $p_idx = ($c_idx - $k_idx + 26) % 26;
        $plaintext .= $alphabet_list_ref->[$p_idx];
    }
    return $plaintext;
}

=head2 info
 
 Returns a formatted string with detailed information about the Autokey Vigenere cipher.
 
=cut
sub info {
    return qq(CIPHER: Vigenere Cipher (Autokey Variant)

DESCRIPTION:
    A polyalphabetic substitution cipher that improves upon the Caesar cipher
    by using a keyword to shift letters by different amounts. This makes it
    immune to simple frequency analysis. The CriptoFEP version implements the
    secure "Autokey" variant.

MECHANISM (ENCRYPTION):
    - A keyword is used to start a "running key".
    - The running key is extended by appending the plaintext itself.
    - Each letter of the plaintext is then shifted by the corresponding letter
      of this running key using modular addition.
    - Formula: E(Pi) = (Pi + Ki) mod 26
    - Example:
        - Plaintext: "ATTACKATDAWN"
        - Key: "LEMON"
        - Running Key: "LEMONATTACKA"
        - Result: "LXFOPKTMDAKN"

MANUAL DECRYPTION:
    Decryption requires rebuilding the running key step-by-step as you decrypt.
    This is the crucial part of the Autokey variant.

    - Formula: D(Ci) = (Ci - Ki) mod 26
    - Example: Let's decrypt "LXFOPKTMDAKN" with the key "LEMON".
        1. Decrypt 'L' with key 'L': (11 - 11) mod 26 = 0 -> 'A'.
           The plaintext is now "A". The running key for the next step is "LEMONA...".
        2. Decrypt 'X' with key 'E': (23 - 4) mod 26 = 19 -> 'T'.
           The plaintext is now "AT". The running key for the next step is "LEMONAT...".
        3. Decrypt 'F' with key 'M': (5 - 12) mod 26 = 19 -> 'T'.
           The plaintext is now "ATT". And so on.
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;