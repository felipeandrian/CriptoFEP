#
# CriptoFEP::AltCode
#
# This module provides an implementation for ALT Code encoding, a system that
# represents any character by its standard numeric code point value (ASCII/Unicode).
# It relies on Perl's native character handling functions.
#

package CriptoFEP::AltCode;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;
# Ensure that the source code itself can contain and process UTF-8 characters,
# which is essential for handling a wide range of symbols.
use utf8;


# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(alt_code_encode alt_code_decode info);


# --- PUBLIC ENCODING SUBROUTINES ---

=head2 alt_code_encode
 
 Encodes a given text string into its corresponding numeric code point values.
 
 B<Parameters:>
   - $text (string): The text to be encoded. Can contain any Unicode character.
 
 B<Returns:>
   - (string): A space-separated string of the integer code points.
 
=cut
sub alt_code_encode {
    my ($text) = @_;
    my @codes;

    # Iterate over each character of the input text.
    foreach my $char (split //, $text) {
        # The built-in ord() function correctly returns the Unicode code point
        # for any given character.
        push @codes, ord($char);
    }
    
    # Join the resulting numbers with a space for readability.
    return join(' ', @codes);
}

=head2 alt_code_decode
 
 Decodes a space-separated string of numeric code points back into characters.
 
 B<Parameters:>
   - $text (string): The string of numbers to be decoded.
 
 B<Returns:>
   - (string): The decoded text, which may contain any Unicode characters.
 
=cut
sub alt_code_decode {
    my ($text) = @_;
    my $decoded_text = "";

    # Split the input string by whitespace to get individual numbers.
    foreach my $code (split /\s+/, $text) {
        # Ensure we only process valid integer strings to avoid errors.
        if ($code =~ /^\d+$/) {
            # The built-in chr() function is the inverse of ord(); it takes a
            # numeric code point and returns the corresponding character.
            $decoded_text .= chr($code);
        }
    }
    
    return $decoded_text;
}

=head2 info
 
 Returns a formatted string with detailed information about the ALT Code encoding.
 
=cut
sub info {
    return qq(ENCODING: ALT Code (ASCII/Unicode Code Points)

DESCRIPTION:
    A system for representing any character by its standard numeric value, known
    as a "code point". This is not a cipher, as the mapping is a universal, public
    standard (ASCII, and its modern superset, Unicode). It's named after the ALT
    key on Windows keyboards, which allows users to type characters by their number.

MECHANISM:
    - Each character has a unique number assigned to it by the Unicode standard.
    - Encoding: This process finds the number for each character.
    - Decoding: This process finds the character for each number.
    - The CriptoFEP implementation handles the full Unicode range, allowing it
      to work with letters, numbers, symbols (©, ♦), and even emojis (😀).
    - Example (Encoding): "A B C" becomes "65 32 66 32 67".
    - Example (Encoding): "€" becomes "8364".

MANUAL DECODING:
    To decode manually, you need an ASCII or Unicode character table.

    - Take each number from the encoded string.
    - Look up that number in the table to find the corresponding character.
    - Example: Let's decode "72 101 108 108 111".
        1. Break into numbers: 72, 101, 108, 108, 111.
        2. Look up each number in an ASCII table:
           - 72  -> 'H'
           - 101 -> 'e'
           - 108 -> 'l'
           - 108 -> 'l'
           - 111 -> 'o'
        3. The result is "Hello".
);
}


# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;