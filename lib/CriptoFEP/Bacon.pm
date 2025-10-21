#
# CriptoFEP::Bacon
#
# This module provides the implementation for the Baconian Cipher, a
# steganographic method that encodes letters into 5-bit binary sequences
# (represented as 'A's and 'B's).
#
package CriptoFEP::Bacon;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;
use utf8;

# --- MODULE IMPORTS ---
# Add the parent 'lib' directory to Perl's search path.
use lib 'lib';
# Import shared utilities for text normalization.
use CriptoFEP::Utils qw(normalize_text);

# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(bacon_encrypt bacon_decrypt info);

# --- MODULE-PRIVATE DATA ---

# The 24-letter Baconian alphabet, mapping each letter to a 5-bit code.
# Note that 'I' and 'J' share a code, as do 'U' and 'V'.
my %bacon_map = (
    'A' => 'AAAAA', 'B' => 'AAAAB', 'C' => 'AAABA', 'D' => 'AAABB',
    'E' => 'AABAA', 'F' => 'AABAB', 'G' => 'AABBA', 'H' => 'AABBB',
    'I' => 'ABAAA', 'J' => 'ABAAA',
    'K' => 'ABAAB', 'L' => 'ABABA', 'M' => 'ABABB', 'N' => 'ABBAA',
    'O' => 'ABBAB', 'P' => 'ABBBA', 'Q' => 'ABBBB', 'R' => 'BAAAA',
    'S' => 'BAAAB', 'T' => 'BAABA', 'U' => 'BAABB', 'V' => 'BAABB',
    'W' => 'BABAA', 'X' => 'BABAB', 'Y' => 'BABBA', 'Z' => 'BABBB',
);

# The reverse map for efficient decryption.
# Maps each 5-bit code back to a single, deterministic letter.
my %reverse_bacon_map = (
    'AAAAA' => 'A', 'AAAAB' => 'B', 'AAABA' => 'C', 'AAABB' => 'D',
    'AABAA' => 'E', 'AABAB' => 'F', 'AABBA' => 'G', 'AABBB' => 'H',
    'ABAAA' => 'I', # Decodes to 'I' for both 'I'/'J'
    'ABAAB' => 'K', 'ABABA' => 'L', 'ABABB' => 'M', 'ABBAA' => 'N',
    'ABBAB' => 'O', 'ABBBA' => 'P', 'ABBBB' => 'Q', 'BAAAA' => 'R',
    'BAAAB' => 'S', 'BAABA' => 'T', 'BAABB' => 'U', # Decodes to 'U' for both 'U'/'V'
    'BABAA' => 'W', 'BABAB' => 'X', 'BABBA' => 'Y', 'BABBB' => 'Z',
);

# --- CIPHER LOGIC ---

=head2 bacon_encrypt
 
 Encodes a given text string into its Baconian cipher representation.
 
 B<Parameters:>
   - $text (string): The plaintext to be encoded.
 
 B<Returns:>
   - (string): The space-separated 5-bit codes.
 
=cut
sub bacon_encrypt {
    my ($text) = @_;
    # Sanitize the input to uppercase A-Z characters only.
    my $normalized_text = normalize_text($text);
    my $output = "";
    
    # Iterate over each character of the normalized text.
    foreach my $char (split //, $normalized_text) {
        # Look up the 5-bit code and append it with a space for readability.
        $output .= $bacon_map{$char} . ' ' if exists $bacon_map{$char};
    }
    # Remove the final trailing space from the end of the string.
    $output =~ s/\s+$//;
    return $output;
}

=head2 bacon_decrypt
 
 Decodes a Baconian cipher string back into its original text representation.
 
 B<Parameters:>
   - $text (string): The 5-bit code string (with or without spaces).
 
 B<Returns:>
   - (string): The decoded plaintext.
 
=cut
sub bacon_decrypt {
    my ($text) = @_;
    # Sanitize the input. This cleverly removes all spaces, punctuation,
    # and any characters other than 'A' and 'B' (which are kept).
    my $normalized_text = normalize_text($text);
    my $output = "";
    
    # Use unpack with the '(A5)*' template to split the continuous
    # string into 5-character chunks.
    foreach my $chunk (unpack '(A5)*', $normalized_text) {
        # Look up each chunk in the reverse map and build the output string.
        $output .= $reverse_bacon_map{$chunk} if exists $reverse_bacon_map{$chunk};
    }
    return $output;
}

# --- DOCUMENTATION SUBROUTINE ---

=head2 info
 
 Returns a formatted string with detailed information about the Baconian cipher.
 This serves as the dynamic help text for the '--info' command-line option.
 
 B<Parameters:> None
 
 B<Returns:>
   - (string): A multi-line help text.
 
=cut
sub info {
    return qq(CIPHER: Baconian Cipher

DESCRIPTION:
    A method of steganography (hiding a message) devised by Francis Bacon in
    1605. It is a substitution cipher that encodes each letter of the alphabet
    into a sequence of five 'A's and 'B's, representing a 5-bit binary code.

MECHANISM:
    - The mapping is fixed and requires no key.
    - It uses a 24-letter alphabet, where I/J and U/V are treated as the same letter.
    - Each letter is substituted by a unique 5-character string of 'A's and 'B's.
    - Example: 'A' -> "AAAAA", 'B' -> "AAAAB", 'C' -> "AAABA", and so on.
    - The original steganographic purpose was to hide this binary sequence in a
      carrier text by using two slightly different typefaces. The CriptoFEP
      implementation shows the direct encoding.
    - Example: 'INFO' becomes "ABAAA ABBAA AABAB ABBAB".

MANUAL DECRYPTION:
    To decrypt, you simply reverse the process by grouping the ciphertext and
    looking up the corresponding letter.

    - Take the ciphertext (string of 'A's and 'B's).
    - Break it into groups of 5 characters.
    - For each group, find the matching letter in the Baconian alphabet table.
    - Example: Let's decrypt "AAABA ABAAA BAAAA".
        1. Break into groups: "AAABA", "ABAAA", "BAAAA".
        2. Look up each group:
           - "AAABA" -> 'C'
           - "ABAAA" -> 'I' (or 'J')
           - "BAAAA" -> 'R'
        3. The result is "CIR".
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;