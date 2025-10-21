#
# CriptoFEP::T9
#
# This module provides an implementation for the T9 multi-tap
# encoding scheme, as used on classic mobile phone keypads.
#
package CriptoFEP::T9;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;

# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
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

# --- MODULE-PRIVATE DATA ---

# --- Character-to-T9 mapping ---
# A fixed hash mapping each character (A-Z, 0-9, space) to its
# corresponding multi-tap key sequence.
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
# This is pre-computed at compile time for efficient decoding.
my %t9_to_char = reverse %char_to_t9;

# -------------------------------------------------------------------
# Function: t9_encode
# Input:  Plaintext string
# Output: Encoded T9 string (numeric sequences separated by spaces)
# -------------------------------------------------------------------
=head2 t9_encode
 
 Encodes an ASCII string into its T9 multi-tap representation.
 
 B<Parameters:>
   - $text (string): The plaintext to be encoded.
 
 B<Returns:>
   - (string): The resulting space-separated T9 code string.
 
=cut
sub t9_encode {
    my ($text) = @_;
    my @encoded_parts;
    
    # Iterate over each character of the (uppercased) plaintext.
    foreach my $char (split //, uc($text)) {
        # Look up the T9 code for the character and add it to the list.
        push @encoded_parts, $char_to_t9{$char} if exists $char_to_t9{$char};
    }
    
    # Join all the individual codes with a space for readability.
    return join(' ', @encoded_parts);
}

# -------------------------------------------------------------------
# Function: t9_decode
# Input:  T9 string (numeric sequences separated by spaces)
# Output: Decoded plaintext string
# -------------------------------------------------------------------
=head2 t9_decode
 
 Decodes a T9 multi-tap string back into its ASCII representation.
 
 B<Parameters:>
   - $text (string): The space-separated T9 code string.
 
 B<Returns:>
   - (string): The decoded ASCII plaintext.
 
=cut
sub t9_decode {
    my ($text) = @_;
    my $decoded_text = "";

    # Split the input string by spaces to get individual T9 codes.
    foreach my $code (split /\s+/, $text) {
        # Look up each code in the reverse map and build the output string.
        $decoded_text .= $t9_to_char{$code} if exists $t9_to_char{$code};
    }
    
    return $decoded_text;
}

# -------------------------------------------------------------------
# Function: info
# Returns a detailed description of the T9 encoding scheme
# -------------------------------------------------------------------
=head2 info
 
 Returns a formatted string with detailed information about the T9 encoding.
 
=cut
sub info {
    return qq(CIPHER: T9 Encoding

DESCRIPTION:
    A representation of text using the T9 multi-tap input method once common
    on mobile phones. Each letter is encoded as a sequence of digits (2–9),
    repeated according to its position on the keypad. Spaces and digits are
    also supported.

MECHANISM (ENCODING):
    - Each letter A-Z is mapped to a numeric key:
        * A,B,C - 2 (A=2, B=22, C=222)
        * D,E,F - 3 (D=3, E=33, F=333)
        * ...
        * W,X,Y,Z - 9 (W=9, X=99, Y=999, Z=9999)
    - Space is encoded as '0'.
    - Digits 0–9 are represented by repeating the digit key multiple times.
    - Example: 'HELLO' becomes '44 33 555 555 666'.

MANUAL DECODING:
    To decode, split the numeric string into groups separated by spaces and
    map each group back to its corresponding character.

    - Example: '44 33 555 555 666'
        1. '44' - H
        2. '33' - E
        3. '555' - L
        4. '555' - L
        5. '666' - O
        Result: HELLO

CURIOSITY:
    The T9 system was widely used on feature phones before the advent of
    full QWERTY keyboards on smartphones. It allowed relatively fast typing
    using only a numeric keypad.
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;