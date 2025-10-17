package CriptoFEP::Atbash;

use strict;
use warnings;

# --- MODULE IMPORTS ---
use lib 'lib';
use CriptoFEP::Utils qw(normalize_text);

# --- EXPORTER CONFIGURATION ---
require Exporter;
our @ISA = qw(Exporter);
# Add 'info' to the list of functions that can be exported.
our @EXPORT_OK = qw(atbash_cipher info);

# --- CIPHER LOGIC ---

sub atbash_cipher {
    my ($text) = @_;
    my $normalized_text = normalize_text($text);
    
    # This is a highly efficient way to reverse the alphabet.
    # It transliterates characters from the first set (A-Z) to the
    # corresponding character in the second set (Z-A).
    $normalized_text =~ tr/ABCDEFGHIJKLMNOPQRSTUVWXYZ/ZYXWVUTSRQPONMLKJIHGFEDCBA/;
    
    return $normalized_text;
}

# --- DOCUMENTATION SUBROUTINE ---

sub info {
    return qq(CIPHER: Atbash Cipher

DESCRIPTION:
    An ancient and simple substitution cipher originally used for the Hebrew
    alphabet. It works by reversing the alphabet, effectively creating a
    "mirror" image of the plaintext.

MECHANISM:
    - The mapping is fixed and requires no key.
    - The first letter ('A') is swapped with the last ('Z'), the second ('B')
      with the second-to-last ('Y'), and so on.
    - It is its own inverse, meaning the exact same process is used for both
      encryption and decryption. Applying the cipher twice returns the original text.
    - Example: 'WIZARD' becomes 'DRAZIW'.

MANUAL DECRYPTION:
    Because the Atbash cipher is its own inverse, the decryption process is
    identical to the encryption process.

    - To decrypt a letter, simply find its reverse counterpart.
    - Example: Let's decrypt 'S'.
        1. 'S' is the 19th letter of the alphabet.
        2. The 19th letter from the *end* of the alphabet is 'H'.
        3. Therefore, 'S' decrypts (and encrypts) to 'H'.

CURIOSITY:
    On Unix-like systems, you can simulate the Atbash cipher using the 'tr' command
    by mapping the alphabet to its reverse explicitly. For example:
        echo "WIZARD" | tr "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz" \\
        "ZYXWVUTSRQPONMLKJIHGFEDCBAzyxwvutsrqponmlkjihgfedcba"
    Output: DRAZIW
    Running the same command again on 'DRAZIW' returns the original 'WIZARD',
    since Atbash is its own inverse.
);

}

# --- MODULE SUCCESS ---
1;