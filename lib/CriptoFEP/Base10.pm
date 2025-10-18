#
# CriptoFEP::Base10
#
# This module provides an implementation for Base10 (Decimal) encoding. It
# represents each character as its standard numerical code point value
# based on the ASCII/Unicode standard.
#

package CriptoFEP::Base10;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;
# Ensure that the source code can contain and process UTF-8 characters.
use utf8;


# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(base10_encode base10_decode info);


# --- PUBLIC ENCODING SUBROUTINES ---

=head2 base10_encode
 
 Encodes a given text string into its Base10 (Decimal) representation.
 
 B<Parameters:>
   - $text (string): The text to be encoded.
 
 B<Returns:>
   - (string): A space-separated string of decimal code point values.
 
=cut
sub base10_encode {
    my ($text) = @_;
    my @codes;
    
    # Iterate over each character in the input string.
    foreach my $char (split //, $text) {
        # The built-in ord() function returns the numeric (decimal) code point
        # for a given character, correctly handling ASCII and Unicode.
        push @codes, ord($char);
    }
    
    # Join the array of numbers with a space for readability.
    return join(' ', @codes);
}

=head2 base10_decode
 
 Decodes a space-separated string of decimal values back into text.
 
 B<Parameters:>
   - $text (string): The Base10 encoded string.
 
 B<Returns:>
   - (string): The decoded original text.
 
=cut
sub base10_decode {
    my ($text) = @_;
    my $decoded_text = "";

    # Split the input string by spaces to get individual number strings.
    foreach my $code (split /\s+/, $text) {
        # Process only if the token is a valid sequence of digits.
        if ($code =~ /^\d+$/) {
            # The built-in chr() function is the inverse of ord(); it takes a
            # numeric code point and returns the corresponding character.
            $decoded_text .= chr($code);
        }
    }
    
    return $decoded_text;
}

=head2 info
 
 Returns a formatted string with detailed information about Base10 encoding.
 
=cut
sub info {
    return qq(ENCODING: Base10 (Decimal)

DESCRIPTION:
    A fundamental encoding that represents each character of a text as its
    standard decimal code point value from the ASCII/Unicode character set.

MECHANISM:
    - Each character is converted into its integer code point.
    - The output is the sequence of these numbers, separated by spaces.
    - Example: "ABC" -> "65 66 67".
        - 'A' has the code point 65.
        - 'B' has the code point 66.
        - 'C' has the code point 67.

MANUAL DECODING:
    1. Break the encoded string into individual numbers.
    2. For each number, find the character that corresponds to that code point
       in an ASCII/Unicode table.
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;
