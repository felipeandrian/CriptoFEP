#
# CriptoFEP::BrailleGS8
#
# This module implements an encoding and decoding system using
# Unicode Braille Patterns (8-dot Braille). Each ASCII character
# is mapped to a Braille cell by specifying which dots are raised.
#
package CriptoFEP::BrailleGS8;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;
use utf8; # Ensures Perl handles Unicode strings correctly.

# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(braille_encode braille_decode info);

# -------------------------------------------------------------------
# CriptoFEP::BrailleGS8
#
# This module implements an encoding and decoding system using
# Unicode Braille Patterns (8-dot Braille). Each ASCII character
# is mapped to a Braille cell by specifying which dots are raised.
# -------------------------------------------------------------------

# Base Unicode value for Braille characters.
# The 8-dot Braille block starts at memory address U+2800.
my $BRAILLE_BASE = 0x2800;

# Mapping from ASCII characters to their Braille dot patterns.
# Each entry is an array of dot numbers (1–8) that should be raised.
my %char_to_dots = (
    'A' => [1],         'B' => [1,2],         'C' => [1,4],
    'D' => [1,4,5],       'E' => [1,5],         'F' => [1,2,4],
    'G' => [1,2,4,5],     'H' => [1,2,5],       'I' => [2,4],
    'J' => [2,4,5],       'K' => [1,3],         'L' => [1,2,3],
    'M' => [1,3,4],       'N' => [1,3,4,5],     'O' => [1,3,5],
    'P' => [1,2,3,4],     'Q' => [1,2,3,4,5],   'R' => [1,2,3,5],
    'S' => [2,3,4],       'T' => [2,3,4,5],     'U' => [1,3,6],
    'V' => [1,2,3,6],     'W' => [2,4,5,6],     'X' => [1,3,4,6],
    'Y' => [1,3,4,5,6],   'Z' => [1,3,5,6],
    ' ' => [], # Space is an empty cell (no dots raised)
    '1' => [2,3,4,6],     '2' => [2,3,5,6],     '3' => [2,4,6,7],
    '4' => [2,4,6,7,8],   '5' => [2,4,6,8],     '6' => [2,3,4,6,7],
    '7' => [2,3,4,6,7,8], '8' => [2,3,4,6,8],   '9' => [2,3,5,6,7],
    '0' => [2,3,5,6,7,8],
);

# Reverse mapping: from Braille numeric value to ASCII character.
# This hash is pre-computed at compile time for efficient decoding.
my %value_to_char;
foreach my $char (keys %char_to_dots) {
    my $value = 0;
    # Calculate the bitwise value for the dot combination.
    # Dot 1 = 2^0 (1), Dot 2 = 2^1 (2), Dot 3 = 2^2 (4), etc.
    foreach my $dot (@{$char_to_dots{$char}}) {
        $value += 2 ** ($dot - 1);
    }
    # Create the reverse mapping (e.g., 1 => 'A').
    $value_to_char{$value} = $char;
}

# -------------------------------------------------------------------
# Function: braille_encode
# Input:  Plaintext string
# Output: Unicode Braille string
# -------------------------------------------------------------------
=head2 braille_encode
 
 Encodes an ASCII string into its 8-dot Unicode Braille representation.
 
 B<Parameters:>
   - $text (string): The plaintext to be encoded.
 
 B<Returns:>
   - (string): The resulting Unicode Braille string.
 
=cut
sub braille_encode {
    my ($text) = @_;
    my $encoded_text = "";

    # Iterate over each character of the (uppercased) plaintext.
    foreach my $char (split //, uc($text)) {
        # Check if the character is defined in our map.
        if (exists $char_to_dots{$char}) {
            my $value = 0;
            # Compute the Braille cell value by summing powers of 2.
            # This is the same logic used to pre-compute the reverse map.
            foreach my $dot (@{$char_to_dots{$char}}) {
                $value += 2 ** ($dot - 1);
            }
            # Convert to Unicode Braille by adding the calculated value
            # to the base address of the Braille block.
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
=head2 braille_decode
 
 Decodes an 8-dot Unicode Braille string back into its ASCII representation.
 
 B<Parameters:>
   - $text (string): The Unicode Braille string to be decoded.
 
 B<Returns:>
   - (string): The decoded ASCII plaintext.
 
=cut
sub braille_decode {
    my ($text) = @_;
    my $decoded_text = "";

    # Iterate over each character in the Braille string.
    foreach my $char (split //, $text) {
        # Get the numeric Unicode code point of the character.
        my $code_point = ord($char);
        
        # Only process characters that fall within the 8-dot Braille block (U+2800 to U+28FF).
        if ($code_point >= $BRAILLE_BASE && $code_point < $BRAILLE_BASE + 256) {
            # Subtract the base address to get the raw bitwise value (0-255).
            my $value = $code_point - $BRAILLE_BASE;
            # Look up this value in our pre-computed reverse map.
            $decoded_text .= $value_to_char{$value} if exists $value_to_char{$value};
        }
    }
    return $decoded_text;
}

# -------------------------------------------------------------------
# Function: info
# Returns a detailed description of the BrailleGS8 encoding scheme
# -------------------------------------------------------------------
=head2 info
 
 Returns a formatted string with detailed information about the Braille GS8 encoding.
 
=cut
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
    - Example: 'A' -> dot 1 -> value 1 (2^(1-1)) -> U+2801 (⠁).
    - Example: 'B' -> dots 1, 2 -> value 3 (2^0 + 2^1) -> U+2803 (⠃).

MANUAL DECODING:
    To decode, subtract the Braille base (U+2800) from the code point to get
    the dot pattern value, then map it back to the corresponding ASCII character.

    - Example: '⠁' (U+2801)
        1. Code point = 0x2801.
        2. Subtract base (0x2800) -> value = 1.
        3. Value 1 corresponds to 'A'.

CURIOSITY:
    Braille GS8 (8-dot Braille) extends the traditional 6-dot Braille system
    by adding two extra dots. This allows representation of a wider range of
    symbols, including digits and formatting marks, and is often used in
    computer Braille systems.
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;