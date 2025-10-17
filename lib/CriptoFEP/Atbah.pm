package CriptoFEP::Atbah;

use strict;
use warnings;
use utf8;

# --- MODULE IMPORTS ---
# This module does not need Utils, as it normalizes text manually for its hash keys.
# However, let's import it for consistency in our project structure.
use lib 'lib';
use CriptoFEP::Utils qw(normalize_text);

# --- EXPORTER CONFIGURATION ---
require Exporter;
our @ISA = qw(Exporter);
# Add 'info' to the list of functions that can be exported.
our @EXPORT_OK = qw(atbah_cipher info);

# --- CIPHER LOGIC ---

sub atbah_cipher {
    my ($text) = @_;
    my $normalized_text = normalize_text($text);
    my $output = "";

    my %atbah_map = (
        'A' => 'I', 'B' => 'H', 'C' => 'G', 'D' => 'F', 'E' => 'N', 'F' => 'D',
        'G' => 'C', 'H' => 'B', 'I' => 'A', 'J' => 'R', 'K' => 'Q', 'L' => 'P',
        'M' => 'O', 'N' => 'E', 'O' => 'M', 'P' => 'L', 'Q' => 'K', 'R' => 'J',
        'S' => 'Z', 'T' => 'Y', 'U' => 'X', 'V' => 'W', 'W' => 'V', 'X' => 'U',
        'Y' => 'T', 'Z' => 'S',
    );

    foreach my $char (split //, $normalized_text) {
        $output .= $atbah_map{$char} if exists $atbah_map{$char};
    }

    return $output;
}

# --- DOCUMENTATION SUBROUTINE ---

sub info {
    return qq(CIPHER: Atbah Cipher

DESCRIPTION:
    A simple, keyless substitution cipher, similar in origin to Atbash,
    historically used for the Hebrew alphabet. It follows a specific,
    non-sequential mapping of letters.

MECHANISM:
    - The mapping is fixed and requires no key.
    - It is a reciprocal cipher, meaning it is its own inverse. The same
      function is used for both encryption and decryption.
    - The mapping pairs letters like so: A<=>I, B<=>H, C<=>G, D<=>F, E<=>N, etc.
    - Example: 'ATTACK' becomes 'IYYIXQ'.

MANUAL DECRYPTION:
    Because the Atbah cipher is its own inverse, the decryption process is
    identical to the encryption process.

    - To decrypt a letter, find its corresponding pair in the substitution table.
    - Example: Let's decrypt 'B'.
        1. In the Atbah mapping, the letter 'B' is paired with 'H'.
        2. Therefore, 'B' decrypts (and encrypts) to 'H'.
    - Example: Let's decrypt 'N'.
        1. In the Atbah mapping, the letter 'N' is paired with 'E'.
        2. Therefore, 'N' decrypts (and encrypts) to 'E'.
);
}

# --- MODULE SUCCESS ---
1;