#
# CriptoFEP::Morse
#
# This module provides the implementation for Morse Code, a classic method of
# encoding text characters as sequences of dots and dashes.
#

package CriptoFEP::Morse;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;


# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(morse_encode morse_decode info);


# --- MODULE-PRIVATE DATA ---

# Defines the standard mapping from alphanumeric characters and punctuation
# to their International Morse Code equivalents.
my %char_to_morse = (
    'A' => '.-',   'B' => '-...', 'C' => '-.-.', 'D' => '-..',  'E' => '.',
    'F' => '..-.', 'G' => '--.',  'H' => '....', 'I' => '..',   'J' => '.---',
    'K' => '-.-',  'L' => '.-..', 'M' => '--',   'N' => '-.',   'O' => '---',
    'P' => '.--.', 'Q' => '--.-', 'R' => '.-.',  'S' => '...',  'T' => '-',
    'U' => '..-',  'V' => '...-', 'W' => '.--',  'X' => '-..-', 'Y' => '-.--',
    'Z' => '--..',
    '1' => '.----', '2' => '..---', '3' => '...--', '4' => '....-', '5' => '.....',
    '6' => '-....', '7' => '--...', '8' => '---..', '9' => '----.', '0' => '-----',
    '.' => '.-.-.-', ',' => '--..--', '?' => '..--..', '/' => '-..-.', '@' => '.--.-.',
);

# Creates the reverse map for efficient decoding by swapping keys and values.
my %morse_to_char = reverse %char_to_morse;


# --- PUBLIC ENCODING SUBROUTINES ---

=head2 morse_encode
 
 Encodes a given text string into its Morse Code representation.
 
 B<Parameters:>
   - $text (string): The text to be encoded.
 
 B<Returns:>
   - (string): The Morse Code representation, with spaces used as separators.
 
=cut
sub morse_encode {
    my ($text) = @_;
    
    # Process each word in the original text separately to preserve word breaks.
    my @words = split /\s+/, uc($text);
    my @morse_words;

    foreach my $word (@words) {
        my @morse_chars;
        # For each character in the word, find its Morse equivalent.
        foreach my $char (split //, $word) {
            push @morse_chars, $char_to_morse{$char} if exists $char_to_morse{$char};
        }
        # Join the Morse codes for individual letters with a single space.
        push @morse_words, join(' ', @morse_chars);
    }
    
    # Join the encoded words with three spaces, the standard separator for words.
    return join('   ', @morse_words);
}

=head2 morse_decode
 
 Decodes a Morse Code string back into plain text.
 
 B<Parameters:>
   - $text (string): The Morse Code string, using spaces as separators.
 
 B<Returns:>
   - (string): The decoded text.
 
=cut
sub morse_decode {
    my ($text) = @_;
    my @decoded_words;

    # Sanitize input by removing leading/trailing whitespace.
    $text =~ s/^\s+|\s+$//g;

    # First, split the input by the word separator (three or more spaces).
    foreach my $word (split /\s{3,}/, $text) {
        my $decoded_word = "";
        # Then, split each Morse word by the letter separator (one or more spaces).
        foreach my $code (split /\s+/, $word) {
            # Look up the code in the reverse map and append the character.
            $decoded_word .= $morse_to_char{$code} if exists $morse_to_char{$code};
        }
        push @decoded_words, $decoded_word;
    }
    
    # Join the decoded words with a single space to reconstruct the message.
    return join(' ', @decoded_words);
}

=head2 info
 
 Returns a formatted string with detailed information about Morse Code.
 
=cut
sub info {
    return qq(ENCODING: Morse Code

DESCRIPTION:
    A method used in telecommunication to encode text characters as standardized
    sequences of two different signal durations, called dots (.) and dashes (-).
    It is named after Samuel Morse, an inventor of the telegraph.

MECHANISM:
    - Each letter, digit, and punctuation mark is represented by a unique
      sequence of dots and dashes.
    - It is a variable-length encoding, meaning common letters like 'E' have
      short codes (.), while less common ones like 'Q' have longer codes (--.-).
    - CriptoFEP uses spaces as separators to ensure clarity:
        - A single space (' ') separates letters.
        - Three spaces ('   ') separate words.
    - Example: "HELLO WORLD" becomes ".... . .-.. .-.. ---   .-- --- .-. .-.. -.."

MANUAL DECODING:
    To decode a message, you must know the Morse alphabet and the separator convention.

    - Break the message into groups based on the word separator (e.g., three spaces).
    - For each group, break it into smaller parts based on the letter separator (e.g., one space).
    - Look up each small part (the dot-dash sequence) in a Morse Code table to
      find the corresponding letter.
    - Example: Let's decode "... --- ...".
        1. Break into letters: "...", "---", "...".
        2. Look up each code:
           - "..." -> 'S'
           - "---" -> 'O'
           - "..." -> 'S'
        3. The result is "SOS".
);
}


# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;