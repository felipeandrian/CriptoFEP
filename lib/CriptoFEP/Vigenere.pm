package CriptoFEP::Vigenere;

use strict;
use warnings;
use utf8;

# --- MODULE IMPORTS ---
use lib 'lib';
use CriptoFEP::Utils qw(normalize_text $alphabet_list_ref $alphabet_map_ref);

# --- EXPORTER CONFIGURATION ---
require Exporter;
our @ISA = qw(Exporter);

our @EXPORT_OK = qw(vigenere_encrypt vigenere_decrypt info);

# --- CIPHER LOGIC ---

sub vigenere_encrypt {
    my ($plaintext, $key) = @_;
    my $norm_plain = normalize_text($plaintext);
    my $norm_key   = normalize_text($key);
    my $running_key = $norm_key . $norm_plain;
    my $ciphertext = "";
    my @plain_chars = split //, $norm_plain;
    my @key_chars = split //, $running_key;
    for (my $i = 0; $i < @plain_chars; $i++) {
        my $p_idx = $alphabet_map_ref->{ $plain_chars[$i] };
        my $k_idx = $alphabet_map_ref->{ $key_chars[$i] };
        my $c_idx = ($p_idx + $k_idx) % 26;
        $ciphertext .= $alphabet_list_ref->[$c_idx];
    }
    return $ciphertext;
}

sub vigenere_decrypt {
    my ($ciphertext, $key) = @_;
    my $norm_cipher = normalize_text($ciphertext);
    my $norm_key    = normalize_text($key);
    my $plaintext = "";
    my @cipher_chars = split //, $norm_cipher;
    my @key_chars = split //, $norm_key;
    for (my $i = 0; $i < @cipher_chars; $i++) {
        my $c_idx = $alphabet_map_ref->{ $cipher_chars[$i] };
        my $k_idx = $alphabet_map_ref->{ $key_chars[$i] };
        my $p_idx = ($c_idx - $k_idx + 26) % 26;
        my $p_char = $alphabet_list_ref->[$p_idx];
        $plaintext .= $p_char;
        push @key_chars, $p_char;
    }
    return $plaintext;
}

# --- DOCUMENTATION SUBROUTINE ---

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
        - Result: 'A'+'L' -> 'L', 'T'+'E' -> 'X', ... => "LXFOPVEFRNHR"

MANUAL DECRYPTION:
    Decryption requires rebuilding the running key step-by-step as you decrypt.
    This is the crucial part of the Autokey variant.

    - Formula: D(Ci) = (Ci - Ki) mod 26
    - Example: Let's decrypt "LXFOPVEFRNHR" with the key "LEMON".
        1. Decrypt 'L' with key 'L': (11 - 11) mod 26 = 0 -> 'A'.
           The plaintext is now "A".
           The running key for the next step is "LEMONA".
        2. Decrypt 'X' with key 'E': (23 - 4) mod 26 = 19 -> 'T'.
           The plaintext is now "AT".
           The running key for the next step is "LEMONAT".
        3. Decrypt 'F' with key 'M': (5 - 12) mod 26 = 19 -> 'T'.
           The plaintext is now "ATT".
           And so on...
);
}

# --- MODULE SUCCESS ---
1;