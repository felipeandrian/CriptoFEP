#
# CriptoFEP::A1Z26
#
# This module provides the implementation for the A1Z26 encoding, a simple
# substitution system that replaces letters with their corresponding ordinal
# position in the alphabet.
#

package CriptoFEP::A1Z26;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;

# --- MODULE IMPORTS ---
# Add the parent 'lib' directory to Perl's search path to find our custom modules.
use lib 'lib';
# Import shared utilities: text normalization and alphabet mappings from the Utils module.
use CriptoFEP::Utils qw(normalize_text $alphabet_list_ref $alphabet_map_ref);


# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(a1z26_encode a1z26_decode info);


# --- PUBLIC ENCODING SUBROUTINES ---

=head2 a1z26_encode
 
 Encodes a given text string into its A1Z26 representation.
 
 B<Parameters:>
   - $text (string): The text to be encoded.
 
 B<Returns:>
   - (string): The A1Z26 representation, with numbers separated by spaces.
 
=cut
sub a1z26_encode {
    my ($text) = @_;
    
    # Sanitize the input to uppercase A-Z characters only.
    my $normalized_text = normalize_text($text);
    my @numbers;
    
    # Iterate over each character of the normalized plaintext.
    foreach my $char (split //, $normalized_text) {
        # Get the character's 0-based index from the map (A=0, B=1...) and add 1
        # to convert it to its 1-based rank (A=1, B=2...).
        push @numbers, $alphabet_map_ref->{$char} + 1;
    }
    
    # Join the resulting numbers with a space for readability.
    return join(' ', @numbers);
}

=head2 a1z26_decode
 
 Decodes an A1Z26 string back into plain text.
 
 B<Parameters:>
   - $text (string): The A1Z26 string, with numbers separated by spaces.
 
 B<Returns:>
   - (string): The decoded text (in uppercase).
 
=cut
sub a1z26_decode {
    my ($text) = @_;
    my $output = "";
    
    # Split the input string by spaces to get individual numbers.
    foreach my $num (split / /, $text) {
        # Convert the number string to an integer and subtract 1 to get the
        # 0-based array index (1 -> index 0, 2 -> index 1...).
        my $index = int($num) - 1;
        
        # Check if the calculated index is within the valid range of the alphabet array.
        if ($index >= 0 && $index <= 25) {
            # Look up the character at that index and append it to the output.
            $output .= $alphabet_list_ref->[$index];
        }
    }
    
    return $output;
}

=head2 info
 
 Returns a formatted string with detailed information about the A1Z26 encoding.
 
=cut
sub info {
    return qq(ENCODING: A1Z26 (Letter-to-Number)

DESCRIPTION:
    A very simple substitution system where each letter of the alphabet is
    replaced by its ordinal position. It is not a cipher, as it requires no key
    and the mapping is fixed and publicly known.

MECHANISM:
    - The mapping is a direct correspondence: A=1, B=2, C=3, ..., Z=26.
    - Non-alphabetic characters in the input text are ignored during encoding.
    - Example (Encoding): "HELLO" becomes "8 5 12 12 15".

MANUAL DECODING:
    To decode, simply reverse the process by finding the letter that corresponds
    to each number.

    - Break the encoded string into individual numbers.
    - For each number, find the corresponding letter (1=A, 2=B, etc.).
    - Example: Let's decode "8 5 12 12 15".
        1. Break into numbers: 8, 5, 12, 12, 15.
        2. Look up each number:
           - 8  -> 'H'
           - 5  -> 'E'
           - 12 -> 'L'
           - 12 -> 'L'
           - 15 -> 'O'
        3. The result is "HELLO".
);
}


# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;