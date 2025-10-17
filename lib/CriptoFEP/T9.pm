package CriptoFEP::T9;

use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(t9_encode t9_decode info);

# -------------------------------------------------------------------
# CriptoFEP::T9
#
# This module implements a simple encoding scheme based on the
# T9 multi-tap input method once common on mobile phones. Each
# letter is represented by a sequence of digits (2–9), repeated
# according to its position on the keypad. Spaces and digits are
# also supported.
# -------------------------------------------------------------------

# --- Character-to-T9 mapping ---
# Letters A–Z are mapped to keys 2–9 with repetitions.
# Space is '0'. Digits are represented by repeating the digit key.
my %char_to_t9 = (
    'A' => '2',   'B' => '22',  'C' => '222',
    'D' => '3',   'E' => '33',  'F' => '333',
    'G' => '4',   'H' => '44',  'I' => '444',
    'J' => '5',   'K' => '55',  'L' => '555',
    'M' => '6',   'N' => '66',  'O' => '666',
    'P' => '7',   'Q' => '77',  'R' => '777', 'S' => '7777',
    'T' => '8',   'U' => '88',  'V' => '888',
    'W' => '9',   'X' => '99',  'Y' => '999', 'Z' => '9999',
    ' ' => '0',
    '0' => '00',  '1' => '1',   '2' => '2222','3' => '3333',
    '4' => '4444','5' => '5555','6' => '6666','7' => '77777',
    '8' => '8888','9' => '99999',
);

# --- Reverse mapping for decoding ---
my %t9_to_char = reverse %char_to_t9;

# -------------------------------------------------------------------
# Function: t9_encode
# Input:  Plaintext string
# Output: Encoded T9 string (numeric sequences separated by spaces)
# -------------------------------------------------------------------
sub t9_encode {
    my ($text) = @_;
    my @encoded_parts;
    
    foreach my $char (split //, uc($text)) {
        push @encoded_parts, $char_to_t9{$char} if exists $char_to_t9{$char};
    }
    
    return join(' ', @encoded_parts);
}

# -------------------------------------------------------------------
# Function: t9_decode
# Input:  T9 string (numeric sequences separated by spaces)
# Output: Decoded plaintext string
# -------------------------------------------------------------------
sub t9_decode {
    my ($text) = @_;
    my $decoded_text = "";

    foreach my $code (split /\s+/, $text) {
        $decoded_text .= $t9_to_char{$code} if exists $t9_to_char{$code};
    }
    
    return $decoded_text;
}

# -------------------------------------------------------------------
# Function: info
# Returns a detailed description of the T9 encoding scheme
# -------------------------------------------------------------------
sub info {
    return qq(CIPHER: T9 Encoding

DESCRIPTION:
    A representation of text using the T9 multi-tap input method once common
    on mobile phones. Each letter is encoded as a sequence of digits (2–9),
    repeated according to its position on the keypad. Spaces and digits are
    also supported.

MECHANISM (ENCODING):
    - Each letter A–Z is mapped to a numeric key:
        * A,B,C → 2 (A=2, B=22, C=222)
        * D,E,F → 3 (D=3, E=33, F=333)
        * ...
        * W,X,Y,Z → 9 (W=9, X=99, Y=999, Z=9999)
    - Space is encoded as '0'.
    - Digits 0–9 are represented by repeating the digit key multiple times.
    - Example: 'HELLO' becomes '44 33 555 555 666'.

MANUAL DECODING:
    To decode, split the numeric string into groups separated by spaces and
    map each group back to its corresponding character.

    - Example: '44 33 555 555 666'
        1. '44' → H
        2. '33' → E
        3. '555' → L
        4. '555' → L
        5. '666' → O
        Result: HELLO

CURIOSITY:
    The T9 system was widely used on feature phones before the advent of
    full QWERTY keyboards on smartphones. It allowed relatively fast typing
    using only a numeric keypad.
);
}

1;