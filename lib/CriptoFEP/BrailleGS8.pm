package CriptoFEP::BrailleGS8;

use strict;
use warnings;
use utf8;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(braille_encode braille_decode info);

# -------------------------------------------------------------------
# CriptoFEP::BrailleGS8
#
# This module implements an encoding and decoding system using
# Unicode Braille Patterns (8-dot Braille). Each ASCII character
# is mapped to a Braille cell by specifying which dots are raised.
# -------------------------------------------------------------------

# Base Unicode value for Braille characters
my $BRAILLE_BASE = 0x2800;

# Mapping from ASCII characters to their Braille dot patterns.
# Each entry is an array of dot numbers (1–8) that should be raised.
my %char_to_dots = (
    'A' => [1],             'B' => [1,2],           'C' => [1,4],
    'D' => [1,4,5],         'E' => [1,5],           'F' => [1,2,4],
    'G' => [1,2,4,5],       'H' => [1,2,5],         'I' => [2,4],
    'J' => [2,4,5],         'K' => [1,3],           'L' => [1,2,3],
    'M' => [1,3,4],         'N' => [1,3,4,5],       'O' => [1,3,5],
    'P' => [1,2,3,4],       'Q' => [1,2,3,4,5],     'R' => [1,2,3,5],
    'S' => [2,3,4],         'T' => [2,3,4,5],       'U' => [1,3,6],
    'V' => [1,2,3,6],       'W' => [2,4,5,6],       'X' => [1,3,4,6],
    'Y' => [1,3,4,5,6],     'Z' => [1,3,5,6],
    ' ' => [], # Space is an empty cell
    '1' => [2,3,4,6],       '2' => [2,3,5,6],       '3' => [2,4,6,7],
    '4' => [2,4,6,7,8],     '5' => [2,4,6,8],       '6' => [2,3,4,6,7],
    '7' => [2,3,4,6,7,8],   '8' => [2,3,4,6,8],     '9' => [2,3,5,6,7],
    '0' => [2,3,5,6,7,8],
);

# Reverse mapping: from Braille numeric value to ASCII character
my %value_to_char;
foreach my $char (keys %char_to_dots) {
    my $value = 0;
    foreach my $dot (@{$char_to_dots{$char}}) {
        $value += 2 ** ($dot - 1);
    }
    $value_to_char{$value} = $char;
}

# -------------------------------------------------------------------
# Function: braille_encode
# Input:  Plaintext string
# Output: Unicode Braille string
# -------------------------------------------------------------------
sub braille_encode {
    my ($text) = @_;
    my $encoded_text = "";

    foreach my $char (split //, uc($text)) {
        if (exists $char_to_dots{$char}) {
            my $value = 0;
            # Compute the Braille cell value by summing powers of 2
            foreach my $dot (@{$char_to_dots{$char}}) {
                $value += 2 ** ($dot - 1);
            }
            # Convert to Unicode Braille character
            $encoded_text .= chr($BRAILLE_BASE + $value);
        }
    }
    return $encoded_text;
}

# -------------------------------------------------------------------
# Function: braille_decode
# Input:  Unicode Braille string
# Output: Decoded ASCII string
# -------------------------------------------------------------------
sub braille_decode {
    my ($text) = @_;
    my $decoded_text = "";

    foreach my $char (split //, $text) {
        my $code_point = ord($char);
        # Only process characters within the Braille block
        if ($code_point >= $BRAILLE_BASE && $code_point < $BRAILLE_BASE + 256) {
            my $value = $code_point - $BRAILLE_BASE;
            $decoded_text .= $value_to_char{$value} if exists $value_to_char{$value};
        }
    }
    return $decoded_text;
}

# -------------------------------------------------------------------
# Function: info
# Returns a detailed description of the BrailleGS8 encoding scheme
# -------------------------------------------------------------------
sub info {
    return qq(CIPHER: Braille GS8 Encoding

DESCRIPTION:
    A representation of text using Unicode Braille Patterns (8-dot Braille).
    Each ASCII character is mapped to a Braille cell by specifying which dots
    are raised. This encoding allows both letters and digits to be represented
    in Braille form.

MECHANISM (ENCODING):
    - Each character is associated with a set of raised dots (1–8).
    - The Braille cell value is computed by summing powers of 2 for each dot.
    - The Unicode Braille block starts at U+2800, and the computed value is
      added to this base to generate the final character.
    - Example: 'A' → dot 1 → value 1 → U+2801 (⠁).

MANUAL DECODING:
    To decode, subtract the Braille base (U+2800) from the code point to get
    the dot pattern value, then map it back to the corresponding ASCII character.

    - Example: '⠁' (U+2801)
        1. Code point = 0x2801.
        2. Subtract base (0x2800) → value = 1.
        3. Value 1 corresponds to 'A'.

CURIOSITY:
    Braille GS8 (8-dot Braille) extends the traditional 6-dot Braille system
    by adding two extra dots. This allows representation of a wider range of
    symbols, including digits and formatting marks, and is often used in
    computer Braille systems.
);
}

1;