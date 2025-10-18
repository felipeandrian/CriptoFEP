#
# CriptoFEP::Base8
#
# This module provides a from-scratch implementation for Base8 (Octal) encoding
# and decoding. Unlike Base16, Perl does not have a direct pack/unpack template,
# so this module performs the bit-level manipulation manually.
#

package CriptoFEP::Base8;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;


# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(base8_encode base8_decode info);


# --- PUBLIC ENCODING SUBROUTINES ---

=head2 base8_encode
 
 Encodes a given text string into its Base8 (Octal) representation.
 
 B<Parameters:>
   - $text (string): The text to be encoded.
 
 B<Returns:>
   - (string): The Octal encoded string.
 
=cut
sub base8_encode {
    my ($text) = @_;
    
    # Stage 1: Convert the entire input string into a continuous bit stream.
    my $bit_string = unpack('B*', $text);
    
    # Stage 2: Pad the bit stream to ensure its length is a multiple of 3.
    # This is necessary for grouping into 3-bit chunks (octal digits).
    $bit_string .= '0' x ( (3 - (length($bit_string) % 3)) % 3 );
    
    my $encoded = "";
    # Stage 3: Process the bit stream in 3-bit chunks.
    foreach my $chunk (unpack '(A3)*', $bit_string) {
        # Convert the binary chunk (e.g., "101") into its decimal/octal value.
        $encoded .= oct("0b" . $chunk);
    }
    return $encoded;
}

=head2 base8_decode
 
 Decodes a Base8 (Octal) string back into its original text representation.
 
 B<Parameters:>
   - $encoded_text (string): The Octal encoded string.
 
 B<Returns:>
   - (string): The decoded original text.
 
=cut
sub base8_decode {
    my ($text) = @_;
    
    my $bit_string = "";
    # Stage 1: Convert each octal digit back to its 3-bit binary representation.
    foreach my $digit (split //, $text) {
        # sprintf ensures each binary value is zero-padded to a length of 3 (e.g., 1 -> "001").
        $bit_string .= sprintf("%03b", $digit) if $digit =~ /^[0-7]$/;
    }

    my $decoded_text = "";
    # Stage 2: Re-group the bit stream into 8-bit chunks (bytes).
    foreach my $chunk (unpack '(A8)*', $bit_string) {
        # Discard any trailing, incomplete bytes that result from padding.
        next if length($chunk) < 8;
        # Stage 3: Convert each 8-bit chunk back into a character.
        $decoded_text .= chr(oct("0b" . $chunk));
    }
    return $decoded_text;
}

=head2 info
 
 Returns a formatted string with detailed information about Base8 encoding.
 
=cut
sub info {
    return qq(ENCODING: Base8 (Octal)

DESCRIPTION:
    A standard encoding that represents binary data using an 8-character set (0-7).
    It is historically significant in computing, especially in early Unix-like
    systems for representing file permissions (e.g., 755).

MECHANISM:
    - The input text is first converted into a stream of 8-bit bytes.
    - This continuous stream of bits is then re-grouped into 3-bit chunks.
    - Each 3-bit chunk, which represents a value from 0 to 7, is mapped to one
      of the 8 octal digits.
    - Example: "Hi" -> "110151"
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;
