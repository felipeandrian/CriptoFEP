#
# CriptoFEP::NATO
#
# This module provides an implementation for the NATO Phonetic Alphabet,
# a system for spelling out letters and numbers to ensure clarity in voice
# communications.
#

package CriptoFEP::NATO;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;

# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(nato_encode nato_decode info);


# --- MODULE-PRIVATE DATA ---

# Defines the standard mapping from alphanumeric characters to their
# corresponding NATO phonetic alphabet words.
my %char_to_nato = (
    'A' => 'Alpha',  'B' => 'Bravo',   'C' => 'Charlie',
    'D' => 'Delta',  'E' => 'Echo',    'F' => 'Foxtrot',
    'G' => 'Golf',   'H' => 'Hotel',   'I' => 'India',
    'J' => 'Juliett','K' => 'Kilo',    'L' => 'Lima',
    'M' => 'Mike',   'N' => 'November','O' => 'Oscar',
    'P' => 'Papa',   'Q' => 'Quebec',  'R' => 'Romeo',
    'S' => 'Sierra', 'T' => 'Tango',   'U' => 'Uniform',
    'V' => 'Victor', 'W' => 'Whiskey', 'X' => 'X-ray',
    'Y' => 'Yankee', 'Z' => 'Zulu',
    '0' => 'Zero',   '1' => 'One',     '2' => 'Two',
    '3' => 'Three',  '4' => 'Four',    '5' => 'Five',
    '6' => 'Six',    '7' => 'Seven',   '8' => 'Eight',
    '9' => 'Nine',
);

# Creates the reverse map for efficient decoding.
# This is built dynamically to ensure consistency with the primary map.
my %nato_to_char;
foreach my $char (keys %char_to_nato) {
    # The keys of the reverse map (the NATO words) are stored in uppercase
    # to make the decoding process case-insensitive.
    my $word = uc($char_to_nato{$char});
    $nato_to_char{$word} = $char;
}


# --- PUBLIC ENCODING SUBROUTINES ---

=head2 nato_encode
 
 Encodes a given text string into its NATO Phonetic Alphabet representation.
 
 B<Parameters:>
   - $text (string): The text to be encoded.
 
 B<Returns:>
   - (string): The NATO phonetic representation.
 
=cut
sub nato_encode {
    my ($text) = @_;
    my @output_words;

    # Process each word separately to preserve word breaks.
    foreach my $word (split /\s+/, uc($text)) {
        my @nato_chars;
        # For each character in the word, find its NATO equivalent.
        foreach my $char (split //, $word) {
            push @nato_chars, $char_to_nato{$char} if exists $char_to_nato{$char};
        }
        # Join the NATO words for a single original word with a space.
        push @output_words, join(' ', @nato_chars);
    }
    
    # Join the encoded word groups with a slash for clarity.
    return join(' / ', @output_words);
}

=head2 nato_decode
 
 Decodes a NATO Phonetic Alphabet string back into plain text.
 
 B<Parameters:>
   - $text (string): The NATO phonetic string.
 
 B<Returns:>
   - (string): The decoded text.
 
=cut
sub nato_decode {
    my ($text) = @_;
    my @output_words;

    # Split the input by the word group separator (slash, with optional spaces).
    foreach my $group (split /\s*\/\s*/, $text) {
        my $decoded_word = "";
        # Split each group into individual NATO words.
        foreach my $word (split /\s+/, $group) {
            my $uc_word = uc($word); # Ensure lookup is case-insensitive.
            # Look up the word in the reverse map and append the character.
            $decoded_word .= $nato_to_char{$uc_word} if exists $nato_to_char{$uc_word};
        }
        push @output_words, $decoded_word;
    }
    
    # Join the decoded words with a single space.
    return join(' ', @output_words);
}

=head2 info
 
 Returns a formatted string with detailed information about the NATO Phonetic Alphabet.
 
=cut
sub info {
    return qq(ENCODING: NATO Phonetic Alphabet

DESCRIPTION:
    The most widely used radiotelephonic spelling alphabet. It is not a cipher,
    but an encoding designed to ensure that letters and numbers are pronounced
    and understood correctly over noisy communication channels, such as radio.

MECHANISM:
    - The mapping is fixed, public, and requires no key.
    - Each letter of the English alphabet and digits 0-9 is assigned a unique,
      easily distinguishable code word (e.g., A -> Alpha, B -> Bravo).
    - CriptoFEP uses a slash ('/') to separate groups of letters that formed
      the original words.
    - Example: "SOS 123" becomes "Sierra Oscar Sierra / One Two Three".

MANUAL DECODING:
    To decode, simply reverse the process by looking up each code word in the
    NATO alphabet table.

    - Break the message into groups based on the slash ('/') separator.
    - For each group, break it into individual code words.
    - Look up each word to find the corresponding letter or digit.
    - Example: Let's decode "Victor / India / Charlie".
        1. Break into groups: "Victor", "India", "Charlie".
        2. Look up each word:
           - "Victor"  -> 'V'
           - "India"   -> 'I'
           - "Charlie" -> 'C'
        3. The result is "V I C".
);
}


# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;