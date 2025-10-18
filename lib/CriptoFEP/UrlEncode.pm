#
# CriptoFEP::UrlEncode
#
# This module provides a from-scratch implementation for URL Encoding, also known
# as Percent-Encoding. It is designed to correctly encode and decode strings,
# including full Unicode (UTF-8) support, for safe use in URIs.
#

package CriptoFEP::UrlEncode;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;
# Ensure that the source code itself can contain and process UTF-8 characters.
use utf8;


# --- MODULE IMPORTS ---
# Import the 'encode' function from Perl's core Encode module. This is the
# low-level, professional way to convert Perl's internal character strings
# into a specific byte sequence (in this case, UTF-8).
use Encode qw(encode);


# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(url_encode url_decode info);


# --- PUBLIC ENCODING SUBROUTINES ---

=head2 url_encode
 
 Encodes a given string into its URL-encoded (percent-encoded) representation.
 
 B<Parameters:>
   - $text (string): The text to be encoded.
 
 B<Returns:>
   - (string): The URL-encoded string.
 
=cut
sub url_encode {
    my ($text) = @_;
    my $encoded_text = "";

    # Iterate over each character of the input string.
    foreach my $char (split //, $text) {
        # Check if the character is in the set of "unreserved" characters
        # as defined by RFC 3986. These characters do not need to be encoded.
        if ($char =~ /[A-Za-z0-9\-\._~]/) {
            $encoded_text .= $char;
        } else {
            # If the character is not safe, convert it to its raw UTF-8 byte sequence.
            # A single character like 'á' might become two or more bytes.
            my $utf8_bytes = encode('UTF-8', $char);
            
            # For each byte in the sequence, append its %HH representation.
            # unpack('C*') converts the byte string into a list of decimal values.
            foreach my $byte (unpack('C*', $utf8_bytes)) {
                # sprintf formats the decimal value as a two-digit, uppercase hexadecimal number.
                $encoded_text .= sprintf("%%%02X", $byte);
            }
        }
    }
    return $encoded_text;
}

=head2 url_decode
 
 Decodes a URL-encoded string back into its original text representation.
 
 B<Parameters:>
   - $encoded_text (string): The URL-encoded string.
 
 B<Returns:>
   - (string): The decoded original text.
 
=cut
sub url_decode {
    my ($text) = @_;
    
    # First, handle a common web form convention where '+' is used as a substitute for a space.
    $text =~ s/\+/ /g;
    
    # Use a substitution regex with the /e (evaluate) modifier. This is the most
    # efficient and idiomatic way to perform this decoding in Perl.
    # It finds each percent-encoded sequence (%HH), and for each match:
    # 1. $1 captures the two hex digits (e.g., "C3").
    # 2. hex($1) converts the hex string to its decimal value (e.g., 195).
    # 3. chr(...) converts the decimal value back into its corresponding character.
    # The /g flag ensures this is done for all occurrences in the string.
    $text =~ s/%([0-9a-fA-F]{2})/chr(hex($1))/ge;
    
    return $text;
}

=head2 info
 
 Returns a formatted string with detailed information about URL Encoding.
 
=cut
sub info {
    return qq(ENCODING: URL Encoding (Percent-Encoding)

DESCRIPTION:
    A standard encoding mechanism used in the World Wide Web to represent
    reserved or non-ASCII characters in a Uniform Resource Identifier (URI).
    It ensures that data can be safely transmitted over the internet.

MECHANISM:
    - Safe characters (A-Z, a-z, 0-9, '-', '_', '.', '~') remain unchanged.
    - All other characters (including spaces, punctuation, and multi-byte
      Unicode characters like 'á' or '€') are converted to their UTF-8 byte
      representation.
    - Each byte is then replaced by a '%' followed by its two-digit
      hexadecimal value (e.g., a space becomes '%20').
    - Example: "Olá!" becomes "Ol%C3%A1%21".

MANUAL DECODING:
    1. Replace any '+' characters with spaces.
    2. Find every sequence of '%HH', where HH is a two-digit hexadecimal number.
    3. Convert each HH value from hexadecimal to its decimal byte value.
    4. Convert the sequence of byte values back into characters, interpreting them
       as a UTF-8 stream.
);
}


# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;
