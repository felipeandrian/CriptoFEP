#
# CriptoFEP::Base32
#
# This module provides a from-scratch implementation for Base32 encoding and
# decoding, as specified by RFC 4648. It is designed to represent binary
# data in a case-insensitive ASCII string format.
#

package CriptoFEP::Base32;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;


# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(base32_encode base32_decode info);


# --- MODULE-PRIVATE DATA ---

# The standard Base32 alphabet as defined in RFC 4648.
my @ALPHABET = ('A'..'Z', '2'..'7');

# The reverse lookup table for efficient decoding.
# This is built dynamically using a hash slice for performance and consistency.
my %REVERSE_ALPHABET;
@REVERSE_ALPHABET{@ALPHABET} = 0..31;


# --- PUBLIC ENCODING SUBROUTINES ---

=head2 base32_encode
 
 Encodes a given text string into its Base32 representation.
 
 B<Parameters:>
   - $text (string): The text to be encoded.
 
 B<Returns:>
   - (string): The Base32 encoded string with appropriate padding.
 
=cut
sub base32_encode {
    my ($text) = @_;
    
    # Stage 1: Convert the entire input string into a continuous bit stream.
    # 'B*' template unpacks the string byte-by-byte into a string of '0's and '1's.
    my $bit_string = unpack('B*', $text);
    
    my $encoded = "";
    # Stage 2: Process the bit stream in 5-bit chunks (quintuplets).
    foreach my $chunk (unpack '(A5)*', $bit_string) {
        # Pad the final chunk with '0's if it's shorter than 5 bits.
        $chunk .= '0' x (5 - length($chunk)) if length($chunk) < 5;
        
        # Stage 3: Convert the binary chunk to its decimal value and map it to the alphabet.
        my $val = oct("0b" . $chunk);
        $encoded .= $ALPHABET[$val];
    }

    # Stage 4: Add RFC 4648 compliant padding.
    # The output length must be a multiple of 8. '=' is used as the padding character.
    my $padding = (8 - (length($encoded) % 8)) % 8;
    $encoded .= '=' x $padding;
    
    return $encoded;
}

=head2 base32_decode
 
 Decodes a Base32 string back into its original text representation.
 
 B<Parameters:>
   - $encoded_text (string): The Base32 encoded string.
 
 B<Returns:>
   - (string): The decoded original text.
 
=cut
sub base32_decode {
    my ($encoded_text) = @_;
    
    # Stage 1: Sanitize the input.
    my $clean_text = uc($encoded_text);
    $clean_text =~ s/=//g;            # Remove padding characters.
    $clean_text =~ s/[^A-Z2-7]//g;   # Remove any invalid Base32 characters.

    my $bit_string = "";
    # Stage 2: Convert each Base32 character back to its 5-bit binary representation.
    foreach my $char (split //, $clean_text) {
        my $val = $REVERSE_ALPHABET{$char};
        # sprintf ensures each binary value is zero-padded to a length of 5.
        $bit_string .= sprintf("%05b", $val) if defined $val;
    }

    my $decoded_text = "";
    # Stage 3: Re-group the bit stream into 8-bit chunks (bytes).
    foreach my $chunk (unpack '(A8)*', $bit_string) {
        # Discard any trailing, incomplete bytes that result from padding.
        next if length($chunk) < 8;
        # Stage 4: Convert each 8-bit chunk back into a character.
        $decoded_text .= chr(oct("0b" . $chunk));
    }
    
    return $decoded_text;
}

=head2 info
 
 Returns a formatted string with detailed information about Base32 encoding.
 
=cut
sub info {
    return qq(ENCODING: Base32

DESCRIPTION:
    A standard encoding scheme that represents binary data using only a 32-character
    set (A-Z and 2-7). It is designed to be case-insensitive and is commonly used
    in applications where this property is important, such as DNS records.

MECHANISM:
    - The input text is first converted into a stream of 8-bit bytes.
    - This continuous stream of bits is then re-grouped into 5-bit chunks.
    - Each 5-bit chunk (a value from 0 to 31) is mapped to a character in the
      Base32 alphabet.
    - The final output is padded with '=' characters to ensure its total length
      is a multiple of 8 characters.
    - Example: "FEP" -> "IZCVA==="

MANUAL DECODING:
    1. Remove any padding characters ('=') from the end of the string.
    2. For each character in the encoded string, look up its 5-bit value
       (e.g., 'A' -> 00000, 'B' -> 00001, ... '7' -> 11111).
    3. Concatenate all the 5-bit chunks into a single, long stream of bits.
    4. Re-group this bit stream into 8-bit chunks (bytes).
    5. Convert each 8-bit byte back to its corresponding ASCII/Unicode character.
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;
