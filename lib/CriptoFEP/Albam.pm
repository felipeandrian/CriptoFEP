package CriptoFEP::Albam;

use strict;
use warnings;
use utf8;

# --- MODULE IMPORTS ---
use lib 'lib';
use CriptoFEP::Utils qw(normalize_text);

# --- EXPORTER CONFIGURATION ---
require Exporter;
our @ISA = qw(Exporter);
# Add 'info' to the list of functions that can be exported.
our @EXPORT_OK = qw(albam_cipher info);

# --- CIPHER LOGIC ---

sub albam_cipher {
    my ($text) = @_;
    my $normalized_text = normalize_text($text);
    my $output = "";

    my %albam_map = (
        'A' => 'N', 'B' => 'O', 'C' => 'P', 'D' => 'Q', 'E' => 'R', 'F' => 'S',
        'G' => 'T', 'H' => 'U', 'I' => 'V', 'J' => 'W', 'K' => 'X', 'L' => 'Y',
        'M' => 'Z', 'N' => 'A', 'O' => 'B', 'P' => 'C', 'Q' => 'D', 'R' => 'E',
        'S' => 'F', 'T' => 'G', 'U' => 'H', 'V' => 'I', 'W' => 'J', 'X' => 'K',
        'Y' => 'L', 'Z' => 'M',
    );

    foreach my $char (split //, $normalized_text) {
        $output .= $albam_map{$char} if exists $albam_map{$char};
    }

    return $output;
}

# --- DOCUMENTATION SUBROUTINE ---

sub info {
    return qq(CIPHER: Albam Cipher

DESCRIPTION:
    An ancient, keyless substitution cipher, similar in origin to Atbash. It is
    named based on its mapping pattern for the first few letters of the Hebrew
    alphabet.

MECHANISM:
    - The mapping is fixed and requires no key.
    - The alphabet is split into two halves (A-M and N-Z). The first half is
      swapped with the second half.
    - 'A' becomes 'N', 'B' becomes 'O', ... and conversely, 'N' becomes 'A'.
    - Like Atbash, it is a reciprocal cipher (its own inverse). The same process
      is used for both encryption and decryption.
    - Example: 'HELLO' becomes 'URYYB'.

MANUAL DECRYPTION:
    Because the Albam cipher is its own inverse, the decryption process is
    identical to the encryption process.

    - To decrypt a letter, find its corresponding pair by shifting it 13 places
      in the alphabet.
    - Example: Let's decrypt 'U'.
        1. 'U' is in the second half of the alphabet.
        2. Shifting it back 13 places ('U' -> 'T' -> ... -> 'H') reveals 'H'.
        3. Therefore, 'U' decrypts (and encrypts) to 'H'.
);
}

# --- MODULE SUCCESS ---
1;