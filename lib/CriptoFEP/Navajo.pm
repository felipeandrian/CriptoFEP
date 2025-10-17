#
# CriptoFEP::Navajo
#
# This module provides an implementation for the Navajo Code, a word-based
# code used by the U.S. Marine Corps' "Code Talkers" during World War II.
# It is an encoding system, not a mathematical cipher.
#

package CriptoFEP::Navajo;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;

# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(navajo_encode navajo_decode info);


# --- MODULE-PRIVATE DATA ---

# Defines the standard mapping from English alphabet characters to their
# corresponding Navajo code words. This version uses one word per letter.
my %char_to_navajo = (
    'A' => 'WOL-LA-CHEE',      'B' => 'SHUSH',
    'C' => 'MOASI',            'D' => 'BE',
    'E' => 'DZEH',             'F' => 'MA-E',
    'G' => 'KLIZZIE',          'H' => 'LIN',
    'I' => 'TSE-NILL',         'J' => 'TKELE-CHO-G',
    'K' => 'KLIZZIE-YAZZIE',   'L' => 'DIBEH-YAZZIE',
    'M' => 'NA-AS-TSO-SI',     'N' => 'NESH-CHEE',
    'O' => 'NE-AHS-JAH',       'P' => 'BI-SO-DIH',
    'Q' => 'CA-YEILTH',        'R' => 'GAH',
    'S' => 'DIBEH',            'T' => 'THAN-ZIE',
    'U' => 'NO-DA-IH',         'V' => 'A-KEH-DI-GLINI',
    'W' => 'GLOE-IH',          'X' => 'AL-NA-AS-DZOH',
    'Y' => 'TSAH-AS-ZIH',      'Z' => 'BESH-DO-TLIZ',
);

# Creates the reverse map for efficient decoding.
# This is built dynamically to ensure consistency with the primary map.
my %navajo_to_char;
foreach my $char (keys %char_to_navajo) {
    # The keys of the reverse map (the Navajo words) are stored in uppercase
    # to make the decoding process case-insensitive.
    my $word = uc($char_to_navajo{$char});
    $navajo_to_char{$word} = $char;
}


# --- PUBLIC ENCODING SUBROUTINES ---

=head2 navajo_encode
 
 Encodes a given text string into its Navajo Code representation.
 
 B<Parameters:>
   - $text (string): The text to be encoded.
 
 B<Returns:>
   - (string): The Navajo Code representation.
 
=cut
sub navajo_encode {
    my ($text) = @_;
    my @output_words;

    # Process each word separately to preserve word breaks.
    foreach my $word (split /\s+/, uc($text)) {
        my @navajo_chars;
        # For each character in the word, find its Navajo equivalent.
        foreach my $char (split //, $word) {
            push @navajo_chars, $char_to_navajo{$char} if exists $char_to_navajo{$char};
        }
        # Join the Navajo words for a single original word with a space.
        push @output_words, join(' ', @navajo_chars);
    }
    
    # Join the encoded word groups with a slash for clarity.
    return join(' / ', @output_words);
}

=head2 navajo_decode
 
 Decodes a Navajo Code string back into plain text.
 
 B<Parameters:>
   - $text (string): The Navajo Code string.
 
 B<Returns:>
   - (string): The decoded text.
 
=cut
sub navajo_decode {
    my ($text) = @_;
    my @output_words;

    # Split the input by the word group separator (slash, with optional spaces).
    foreach my $group (split /\s*\/\s*/, $text) {
        my $decoded_word = "";
        # Split each group into individual Navajo words.
        foreach my $word (split /\s+/, $group) {
            my $uc_word = uc($word); # Ensure lookup is case-insensitive.
            # Look up the word in the reverse map and append the character.
            $decoded_word .= $navajo_to_char{$uc_word} if exists $navajo_to_char{$uc_word};
        }
        push @output_words, $decoded_word;
    }
    
    # Join the decoded words with a single space.
    return join(' ', @output_words);
}

=head2 info
 
 Returns a formatted string with detailed information about the Navajo Code.
 
=cut
sub info {
    return qq(ENCODING: Navajo Code

DESCRIPTION:
    A famous code based on the Navajo language, used by the U.S. Marine Corps
    during World War II. The "Code Talkers" used their native, unwritten, and
    highly complex language to transmit secret tactical messages. It was never
    broken by the enemy.

MECHANISM:
    - This is a word-based code, not a mathematical cipher.
    - It is keyless; the "secret" was the language itself, which was unknown
      outside the Navajo community.
    - Each letter of the English alphabet was assigned a specific Navajo word.
      In the actual system, common letters had multiple word options to prevent
      frequency analysis. This implementation uses one standard word per letter.
    - Example: "ATTACK" becomes "WOL-LA-CHEE THAN-ZIE THAN-ZIE WOL-LA-CHEE MOASI KLIZZIE-YAZZIE".

MANUAL DECODING:
    To decode, you must have the dictionary of Navajo code words.

    - Break the message into groups based on the word separator ('/').
    - For each group, break it into individual code words.
    - Look up each Navajo word to find the corresponding English letter.
    - Example: Let's decode "SHUSH DZEH / GAH DZEH BE".
        1. Break into groups: "SHUSH DZEH" and "GAH DZEH BE".
        2. Decode the first group:
           - "SHUSH" -> 'B'
           - "DZEH"  -> 'E'
        3. Decode the second group:
           - "GAH"   -> 'R'
           - "DZEH"  -> 'E'
           - "BE"    -> 'D'
        4. The result is "BE RED".
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;