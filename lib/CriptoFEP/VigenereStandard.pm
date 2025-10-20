#
# CriptoFEP::VigenereStandard
#
# This module provides an implementation for the standard Vigenere cipher,
# which uses a repeating keyword. It is a classic polyalphabetic substitution cipher.
#

package CriptoFEP::VigenereStandard;

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
our @EXPORT_OK = qw(vigenere_standard_encrypt vigenere_standard_decrypt info);


# --- PUBLIC CIPHER SUBROUTINES ---

=head2 vigenere_standard_encrypt
 
 Encrypts plaintext using the standard repeating-key Vigenere cipher.
 
 B<Parameters:>
   - $plaintext (string): The plaintext to be encrypted.
   - $key (string): The secret keyword.
 
 B<Returns:>
   - (string): The resulting ciphertext.
 
=cut
sub vigenere_standard_encrypt {
    my ($plaintext, $key) = @_;
    
    # Sanitize the input text and key.
    my $norm_plain = normalize_text($plaintext);
    my $norm_key   = normalize_text($key);
    return $norm_plain unless length($norm_key); # Return plaintext if key is empty.
    
    my $ciphertext = "";
    my @plain_chars = split //, $norm_plain;
    my @key_chars   = split //, $norm_key;
    
    # Iterate over each character of the normalized plaintext.
    for (my $i = 0; $i < @plain_chars; $i++) {
        my $p_idx = $alphabet_map_ref->{ $plain_chars[$i] };
        
        # The key repeats cyclically. The modulo operator on the current index
        # ensures the key wraps around (e.g., for a 3-letter key, index 3 uses key char 0).
        my $k_idx = $alphabet_map_ref->{ $key_chars[$i % @key_chars] };
        
        # Apply the Vigenere encryption formula: E(p) = (p + k) mod 26.
        my $c_idx = ($p_idx + $k_idx) % 26;
        $ciphertext .= $alphabet_list_ref->[$c_idx];
    }
    return $ciphertext;
}

=head2 vigenere_standard_decrypt
 
 Decrypts ciphertext that was encrypted with the standard Vigenere cipher.
 
 B<Parameters:>
   - $ciphertext (string): The ciphertext to be decrypted.
   - $key (string): The secret keyword used for the original encryption.
 
 B<Returns:>
   - (string): The original plaintext.
 
=cut
sub vigenere_standard_decrypt {
    my ($ciphertext, $key) = @_;
    
    my $norm_cipher = normalize_text($ciphertext);
    my $norm_key    = normalize_text($key);
    return $norm_cipher unless length($norm_key);
    
    my $plaintext = "";
    my @cipher_chars = split //, $norm_cipher;
    my @key_chars    = split //, $norm_key;

    # Iterate over each character of the normalized ciphertext.
    for (my $i = 0; $i < @cipher_chars; $i++) {
        my $c_idx = $alphabet_map_ref->{ $cipher_chars[$i] };
        
        # The same repeating key logic is used for decryption.
        my $k_idx = $alphabet_map_ref->{ $key_chars[$i % @key_chars] };
        
        # Apply the Vigenere decryption formula: D(c) = (c - k) mod 26.
        # Adding 26 before the modulo handles negative results correctly.
        my $p_idx = ($c_idx - $k_idx + 26) % 26;
        $plaintext .= $alphabet_list_ref->[$p_idx];
    }
    return $plaintext;
}

=head2 info
 
 Returns a formatted string with detailed information about the standard Vigenere cipher.
 
=cut
sub info {
    return qq(CIPHER: Vigenere Cipher (Standard Repeating Key)

DESCRIPTION:
    The classic form of the Vigenere cipher, a polyalphabetic substitution
    cipher that uses a keyword to shift letters by different amounts, making it
    resistant to simple frequency analysis.

MECHANISM:
    - A keyword is used as a "running key" by repeating it as many times
      as necessary to match the length of the plaintext.
    - Each letter of the plaintext is then shifted by the corresponding letter
      of this repeating key using modular addition.
    - Formula: E(Pi) = (Pi + Ki) mod 26
    - Example (Key: "LEMON"):
        - Plaintext: "ATTACKATDAWN"
        - Running Key: "LEMONLEMONLE"
        - Result: "LXFOPVEFRNHR"
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;