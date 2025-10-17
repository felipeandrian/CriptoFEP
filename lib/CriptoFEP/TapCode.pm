#
# CriptoFEP::TapCode
#
# This module provides an implementation for the Tap Code, a simple encoding
# method used to communicate messages via a series of taps or knocks.
#

package CriptoFEP::TapCode;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;


# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(tap_code_encode tap_code_decode info);


# --- MODULE-PRIVATE DATA ---

# Defines the 5x5 Polybius square used for the Tap Code.
# Note that 'K' is omitted and represented by 'C'.
my %char_to_coord = (
    'A' => '11', 'B' => '12', 'C' => '13', 'D' => '14', 'E' => '15',
    'F' => '21', 'G' => '22', 'H' => '23', 'I' => '24', 'J' => '25',
    'K' => '13', # K is treated as C
    'L' => '31', 'M' => '32', 'N' => '33', 'O' => '34', 'P' => '35',
    'Q' => '41', 'R' => '42', 'S' => '43', 'T' => '44', 'U' => '45',
    'V' => '51', 'W' => '52', 'X' => '53', 'Y' => '54', 'Z' => '55',
);

# The reverse map for efficient decoding.
my %coord_to_char = (
    '11' => 'A', '12' => 'B', '13' => 'C', '14' => 'D', '15' => 'E',
    '21' => 'F', '22' => 'G', '23' => 'H', '24' => 'I', '25' => 'J',
    '31' => 'L', '32' => 'M', '33' => 'N', '34' => 'O', '35' => 'P',
    '41' => 'Q', '42' => 'R', '43' => 'S', '44' => 'T', '45' => 'U',
    '51' => 'V', '52' => 'W', '53' => 'X', '54' => 'Y', '55' => 'Z',
);


# --- PUBLIC ENCODING SUBROUTINES ---

=head2 tap_code_encode
 
 Encodes a given text string into its Tap Code representation.
 
 B<Parameters:>
   - $text (string): The text to be encoded.
 
 B<Returns:>
   - (string): The Tap Code representation, using dots and separators.
 
=cut
sub tap_code_encode {
    my ($text) = @_;
    my @encoded_chars;
    
    # Tap code does not use spaces, so we normalize to uppercase A-Z.
    my $normalized_text = uc($text);
    $normalized_text =~ s/[^A-Z]//g;

    # Iterate over each character of the normalized plaintext.
    foreach my $char (split //, $normalized_text) {
        if (exists $char_to_coord{$char}) {
            # Split the coordinate pair (e.g., "23") into row ("2") and column ("3").
            my ($row, $col) = split //, $char_to_coord{$char};
            # Convert the numbers into a sequence of dots using the 'x' operator.
            push @encoded_chars, ('.' x $row) . ' ' . ('.' x $col);
        }
    }
    
    # Join the encoded characters with a slash for readability between letters.
    return join(' / ', @encoded_chars);
}

=head2 tap_code_decode
 
 Decodes a Tap Code string back into plain text.
 
 B<Parameters:>
   - $text (string): The Tap Code string, using dots and separators.
 
 B<Returns:>
   - (string): The decoded text (in uppercase).
 
=cut
sub tap_code_decode {
    my ($text) = @_;
    my $decoded_text = "";

    # Split the input by the letter separator (slash, with optional spaces).
    foreach my $pair (split /\s*\/\s*/, $text) {
        # Split the row and column tap groups by the space separator.
        my @taps = split /\s+/, $pair;
        # A valid code must have exactly two groups of taps.
        next unless @taps == 2;
        
        # Count the number of dots in each group to get the row and column numbers.
        my $row = length($taps[0]);
        my $col = length($taps[1]);
        my $coord = "$row$col";

        # Look up the coordinate in the reverse map and append the character.
        if (exists $coord_to_char{$coord}) {
            $decoded_text .= $coord_to_char{$coord};
        }
    }
    
    return $decoded_text;
}

=head2 info
 
 Returns a formatted string with detailed information about the Tap Code.
 
=cut
sub info {
    return qq(ENCODING: Tap Code

DESCRIPTION:
    A simple encoding method used to transmit text messages on a letter-by-letter
    basis. It is famous for its use by prisoners of war to communicate by tapping
    on pipes or walls.

MECHANISM:
    - The code is based on a 5x5 grid (a Polybius Square) where the letter 'K'
      is usually replaced by 'C'.
    - Each letter is represented by two numbers: its row and its column.
    - These numbers are transmitted as a sequence of taps.
    - CriptoFEP represents this as:
        - A dot ('.') for each tap.
        - A space (' ') separating the row-taps from the column-taps.
        - A slash ('/') separating each complete letter.
    - Example: To encode "WATER":
        - W is at (5,2) -> "..... .."
        - A is at (1,1) -> ". ."
        - T is at (4,4) -> ".... ...."
        - E is at (1,5) -> ". ....."
        - R is at (4,2) -> ".... .."
      Result: "..... .. / . . / .... .... / . ..... / .... .."

MANUAL DECODING:
    To decode, simply count the taps and find the letter in the grid.

    - Break the message into groups based on the slash ('/') separator.
    - For each group, count the dots before and after the space to get the
      row and column numbers.
    - Look up the coordinates in the grid.
    - Example: Let's decode ".... . / . ..... / ... .."
        1. Break into groups: ".... .", ". .....", "... ..".
        2. Analyze each group:
           - ".... ." -> 4 taps, 1 tap -> (4,1) -> 'Q'
           - ". ....." -> 1 tap, 5 taps -> (1,5) -> 'E'
           - "... .."  -> 3 taps, 2 taps -> (3,2) -> 'M'
        3. The result is "QEM".
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;