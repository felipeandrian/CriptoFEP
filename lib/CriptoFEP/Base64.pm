#
# CriptoFEP::Base64
#
# This module provides a from-scratch implementation for Base64 encoding and
# decoding, as specified by RFC 4648. It is designed to represent binary
# data in a standard, 64-character ASCII string format.
#

package CriptoFEP::Base64;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;


# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(base64_encode base64_decode info);


# --- MODULE-PRIVATE DATA ---

# The standard Base64 alphabet as defined in RFC 4648.
my @ALPHABET = ('A'..'Z', 'a'..'z', '0'..'9', '+', '/');

# The reverse lookup table for efficient decoding.
# This is built dynamically using a hash slice for performance and consistency.
my %REVERSE_ALPHABET;
@REVERSE_ALPHABET{@ALPHABET} = 0..63;


# --- PUBLIC ENCODING SUBROUTINES ---

=head2 base64_encode
 
 Encodes a given text string into its Base64 representation.
 
 B<Parameters:>
   - $text (string): The text to be encoded.
 
 B<Returns:>
   - (string): The Base64 encoded string with appropriate padding.
 
=cut
sub base64_encode {
    my ($text) = @_;
    
    # Stage 1: Convert the entire input string into a continuous bit stream.
    # 'B*' template unpacks the string byte-by-byte into a string of '0's and '1's.
    my $bit_string = unpack('B*', $text);
    
    my $encoded = "";
    # Stage 2: Process the bit stream in 6-bit chunks.
    foreach my $chunk (unpack '(A6)*', $bit_string) {
        # Pad the final chunk with '0's if it's shorter than 6 bits.
        $chunk .= '0' x (6 - length($chunk)) if length($chunk) < 6;
        
        # Stage 3: Convert the binary chunk to its decimal value and map it to the alphabet.
        my $val = oct("0b" . $chunk);
        $encoded .= $ALPHABET[$val];
    }

    # Stage 4: Add RFC 4648 compliant padding.
    # The output length must be a multiple of 4. '=' is used as the padding character.
    my $padding = (4 - (length($encoded) % 4)) % 4;
    $encoded .= '=' x $padding;
    
    return $encoded;
}

=head2 base64_decode
 
 Decodes a Base64 string back into its original text representation.
 
 B<Parameters:>
   - $encoded_text (string): The Base64 encoded string.
 
 B<Returns:>
   - (string): The decoded original text.
 
=cut
sub base64_decode {
    my ($encoded_text) = @_;
    
    # Stage 1: Sanitize the input.
    my $clean_text = $encoded_text;
    $clean_text =~ s/=//g;            # Remove padding characters.
    $clean_text =~ s/\s//g;           # Remove any whitespace.
    $clean_text =~ s/[^A-Za-z0-9+\/]//g; # Remove any invalid Base64 characters.

    my $bit_string = "";
    # Stage 2: Convert each Base64 character back to its 6-bit binary representation.
    foreach my $char (split //, $clean_text) {
        my $val = $REVERSE_ALPHABET{$char};
        # sprintf ensures each binary value is zero-padded to a length of 6.
        $bit_string .= sprintf("%06b", $val) if defined $val;
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
 
 Returns a formatted string with detailed information about Base64 encoding.
 
=cut
sub info {
    return qq(ENCODING: Base64

DESCRIPTION:
    A standard encoding scheme that represents binary data using a 64-character
    set (A-Z, a-z, 0-9, +, /). It is ubiquitous on the internet, used in email
    attachments (MIME), APIs, and for embedding data like images directly into
    HTML or CSS files.

MECHANISM:
    - The input data is processed in groups of 3 bytes (24 bits).
    - This 24-bit group is then re-grouped into four 6-bit chunks.
    - Each 6-bit chunk (a value from 0 to 63) is mapped to a character in the
      Base64 alphabet.
    - If the input is not a multiple of 3 bytes, '=' characters are used as
      padding at the end of the output to make its length a multiple of 4.
    - Example: "FEP" -> "ZkVR"

MANUAL DECODING:
    1. Remove any padding characters ('=') from the end of the string.
    2. For each character in the encoded string, look up its 6-bit value
       (e.g., 'A' -> 000000, 'B' -> 000001...).
    3. Concatenate all the 6-bit chunks into a single, long stream of bits.
    4. Re-group this bit stream into 8-bit chunks (bytes).
    5. Convert each 8-bit byte back to its corresponding ASCII/Unicode character.
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;
