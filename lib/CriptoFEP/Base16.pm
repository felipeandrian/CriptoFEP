#
# CriptoFEP::Base16
#
# This module provides an implementation for Base16 (Hexadecimal) encoding and
# decoding. It leverages Perl's highly optimized built-in pack/unpack functions
# for maximum performance and reliability.
#

package CriptoFEP::Base16;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;


# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(base16_encode base16_decode info);


# --- PUBLIC ENCODING SUBROUTINES ---

=head2 base16_encode
 
 Encodes a given text string into its Base16 (Hexadecimal) representation.
 
 B<Parameters:>
   - $text (string): The text to be encoded.
 
 B<Returns:>
   - (string): The Hexadecimal encoded string.
 
=cut
sub base16_encode {
    my ($text) = @_;
    
    # The 'H*' template for unpack is the standard, most efficient way in Perl
    # to convert a sequence of bytes into a hexadecimal string. 'H' means
    # "Hex string, high nibble first," and '*' means "repeat for the whole string."
    return unpack('H*', $text);
}

=head2 base16_decode
 
 Decodes a Base16 (Hexadecimal) string back into its original text representation.
 
 B<Parameters:>
   - $encoded_text (string): The Hexadecimal encoded string.
 
 B<Returns:>
   - (string): The decoded original text.
 
=cut
sub base16_decode {
    my ($text) = @_;
    
    # The 'H*' template for pack is the perfect inverse of unpack. It takes a
    # hexadecimal string and packs it back into a sequence of bytes.
    return pack('H*', $text);
}

=head2 info
 
 Returns a formatted string with detailed information about Base16 encoding.
 
=cut
sub info {
    return qq(ENCODING: Base16 (Hexadecimal)

DESCRIPTION:
    A standard encoding that represents binary data using a 16-character set
    (0-9 and A-F). It is fundamental in computing for representing memory
    addresses, byte values, and colors in web design.

MECHANISM:
    - Each byte (8 bits) of input data is split into two 4-bit chunks (nibbles).
    - Each 4-bit chunk, which represents a value from 0 to 15, is mapped to one
      of the 16 hexadecimal characters.
    - Example: "Hi"
        - 'H' -> ASCII 72 -> Binary 01001000 -> Hex "48"
        - 'i' -> ASCII 105 -> Binary 01101001 -> Hex "69"
        - Result: "4869"
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;
