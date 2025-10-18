#
# CriptoFEP::Base2
#
# This module provides an implementation for Base2 (Binary) encoding and decoding.
# It leverages Perl's highly optimized built-in pack/unpack functions for
# maximum performance and reliability.
#

package CriptoFEP::Base2;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;


# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(base2_encode base2_decode info);


# --- PUBLIC ENCODING SUBROUTINES ---

=head2 base2_encode
 
 Encodes a given text string into its Base2 (Binary) representation.
 
 B<Parameters:>
   - $text (string): The text to be encoded.
 
 B<Returns:>
   - (string): The Binary encoded string, with bytes separated by spaces.
 
=cut
sub base2_encode {
    my ($text) = @_;
    
    # The 'B*' template for unpack is the standard, most efficient way in Perl
    # to convert a sequence of bytes into a continuous bit string.
    # 'B' means "Bit string, high bit first," and '*' means "repeat for the whole string."
    my $bit_string = unpack('B*', $text);
    
    # Insert a space after every 8 bits (1 byte) to improve human readability.
    # The regex captures groups of 8 characters and re-inserts them followed by a space.
    $bit_string =~ s/(.{8})/$1 /g;
    
    # The previous substitution may leave a trailing space, which is removed here.
    $bit_string =~ s/\s$//;
    
    return $bit_string;
}

=head2 base2_decode
 
 Decodes a Base2 (Binary) string back into its original text representation.
 
 B<Parameters:>
   - $encoded_text (string): The Binary encoded string.
 
 B<Returns:>
   - (string): The decoded original text.
 
=cut
sub base2_decode {
    my ($text) = @_;
    
    # Sanitize the input by removing any characters that are not '0' or '1'.
    # This makes the function robust against formatted input (e.g., with spaces).
    my $clean_bits = $text;
    $clean_bits =~ s/[^01]//g;
    
    # The 'B*' template for pack is the perfect inverse of unpack. It takes a
    # string of '0's and '1's and packs it back into a sequence of bytes,
    # effectively converting the binary representation back to text.
    return pack('B*', $clean_bits);
}

=head2 info
 
 Returns a formatted string with detailed information about Base2 encoding.
 
=cut
sub info {
    return qq(ENCODING: Base2 (Binary)

DESCRIPTION:
    The fundamental data representation for all digital computers. This encoding
    converts text into its raw binary (0s and 1s) representation based on its
    character set (typically ASCII/UTF-8).

MECHANISM:
    - Each character of the input text is converted into its 8-bit (1 byte)
      numeric value.
    - The output is the sequence of these 8-bit groups. For readability,
      CriptoFEP separates each byte with a space.
    - Example: "Hi" -> "01001000 01101001"
        - 'H' is ASCII 72, which is 01001000 in binary.
        - 'i' is ASCII 105, which is 01101001 in binary.

MANUAL DECODING:
    1. Remove all spaces from the binary string.
    2. Break the long string of bits into 8-bit chunks (bytes).
    3. Convert each 8-bit byte from binary to its decimal value.
    4. Find the character that corresponds to that decimal value in an
       ASCII/Unicode table.
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;
