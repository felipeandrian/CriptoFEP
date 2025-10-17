#
# CriptoFEP::Pollux
#
# This module provides an implementation for the Pollux cipher (also known as
# the Collon cipher), a homophonic substitution cipher that disguises Morse code
# by mapping its symbols to digits based on a numeric key.
#

package CriptoFEP::Pollux;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;
use utf8;


# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(pollux_encrypt pollux_decrypt info);


# --- MODULE-PRIVATE DATA ---

# A local Morse dictionary is used for the final decoding stage.
# This makes the module self-contained and independent of other modules.
my %char_to_morse = (
    'A' => '.-',   'B' => '-...', 'C' => '-.-.', 'D' => '-..',  'E' => '.',
    'F' => '..-.', 'G' => '--.',  'H' => '....', 'I' => '..',   'J' => '.---',
    'K' => '-.-',  'L' => '.-..', 'M' => '--',   'N' => '-.',   'O' => '---',
    'P' => '.--.', 'Q' => '--.-', 'R' => '.-.',  'S' => '...',  'T' => '-',
    'U' => '..-',  'V' => '...-', 'W' => '.--',  'X' => '-..-', 'Y' => '-.--',
    'Z' => '--..',
);
my %morse_to_char = reverse %char_to_morse;


# --- MODULE-PRIVATE HELPER SUBROUTINES ---

=head2 _generate_tables
 
 Internal function that partitions the digits 0-9 into three groups
 (for dots, dashes, and separators) based on the provided numeric key.
 
 B<Parameters:>
   - $key (string): A string of unique digits (e.g., "316").
 
 B<Returns:>
   - A list of three array references: [\@dot_digits, \@dash_digits, \@sep_digits].
 
=cut
sub _generate_tables {
    my ($key) = @_;
    my %seen;
    # The digits in the key are used for dots.
    my @dot_digits = grep { !$seen{$_}++ } split //, $key;
    
    # All other digits are used for dashes and separators.
    my %all_digits = map { $_ => 1 } 0..9;
    delete $all_digits{$_} for @dot_digits;
    
    my @remaining = sort { $a <=> $b } keys %all_digits;
    # By convention, the first 3 remaining digits are for separators.
    my @sep_digits = splice(@remaining, 0, 3);
    # The rest are for dashes.
    my @dash_digits = @remaining;

    return (\@dot_digits, \@dash_digits, \@sep_digits);
}


# --- PUBLIC CIPHER SUBROUTINES ---

=head2 pollux_encrypt
 
 Encrypts plaintext using the Pollux cipher.
 
 B<Parameters:>
   - $plaintext (string): The plaintext to be encrypted.
   - $key (string): The numeric key (e.g., "316").
 
 B<Returns:>
   - (string): The resulting numeric ciphertext.
 
=cut
sub pollux_encrypt {
    my ($plaintext, $key) = @_;
    my ($dot_digits, $dash_digits, $sep_digits) = _generate_tables($key);

    # --- Stage 1: Convert to Morse with separators ---
    # An 'x' is inserted between each letter's Morse code to ensure
    # the output is unambiguous and can be correctly decrypted.
    my $morse_string = "";
    my @chars = split //, uc($plaintext);
    for my $i (0 .. $#chars) {
        my $char = $chars[$i];
        if (exists $char_to_morse{$char}) {
            $morse_string .= $char_to_morse{$char};
            # Append a separator unless it's the last character.
            $morse_string .= 'x' if $i < $#chars;
        }
    }

    # --- Stage 2: Substitute Morse symbols with digits ---
    # Each symbol type cycles through its own list of available digits.
    my $ciphertext = "";
    my ($dot_idx, $dash_idx, $sep_idx) = (0, 0, 0);
    foreach my $symbol (split //, $morse_string) {
        if ($symbol eq '.') {
            $ciphertext .= $dot_digits->[$dot_idx++ % @$dot_digits];
        } elsif ($symbol eq '-') {
            $ciphertext .= $dash_digits->[$dash_idx++ % @$dash_digits];
        } elsif ($symbol eq 'x') {
            $ciphertext .= $sep_digits->[$sep_idx++ % @$sep_digits];
        }
    }
    return $ciphertext;
}

=head2 pollux_decrypt
 
 Decrypts ciphertext that was encrypted with the Pollux cipher.
 
 B<Parameters:>
   - $ciphertext (string): The numeric ciphertext to be decrypted.
   - $key (string): The numeric key used for the original encryption.
 
 B<Returns:>
   - (string): The original plaintext.
 
=cut
sub pollux_decrypt {
    my ($ciphertext, $key) = @_;
    my ($dot_digits, $dash_digits, $sep_digits) = _generate_tables($key);

    # --- Stage 1: Convert digits back to Morse symbols ---
    # Create a reverse map from any digit to its corresponding symbol ('.', '-', or 'x').
    my %digit_map;
    $digit_map{$_} = '.' for @$dot_digits;
    $digit_map{$_} = '-' for @$dash_digits;
    $digit_map{$_} = 'x' for @$sep_digits;

    my $morse_string_with_seps = "";
    foreach my $digit (split //, $ciphertext) {
        $morse_string_with_seps .= $digit_map{$digit} // '';
    }

    # --- Stage 2: Decode the separated Morse string ---
    # This process is now simple and unambiguous because of the 'x' separators.
    my $plaintext = "";
    # Split the Morse string by the 'x' separator to get individual letter codes.
    foreach my $code (split /x/, $morse_string_with_seps) {
        $plaintext .= $morse_to_char{$code} if exists $morse_to_char{$code};
    }
    
    return $plaintext;
}

=head2 info
 
 Returns a formatted string with detailed information about the Pollux cipher.
 
=cut
sub info {
    return qq(CIPHER: Pollux Cipher (also known as Collon Cipher)

DESCRIPTION:
    An ingenious homophonic substitution cipher that hides Morse code. Each Morse
    symbol (dot, dash, and separator) is replaced by one of several possible digits,
    making frequency analysis much more difficult.

MECHANISM:
    - It uses a numeric key with unique digits (e.g., "316").
    - A substitution table is created:
        - Dots (.) map to the digits IN the key.
        - Separators (x) map to the next 3 available digits.
        - Dashes (-) map to the remaining digits.
    - Encryption:
        1. Convert plaintext to Morse, inserting an 'x' between each letter's code.
        2. Replace each dot, dash, and 'x' with the next available digit
           from its respective list, cycling as needed.
    - Example (Key: "316", Text: "SOS"):
        - "SOS" -> "...x---x..."
        - Dots use (3,1,6), Separators use (0,2,4), Dashes use (5,7,8,9).
        - Result: "316024578" (using the next available digit from each group).

MANUAL DECRYPTION:
    1. Using the key, generate the same three sets of digits for dots, dashes,
       and separators.
    2. Convert the numeric ciphertext back into a Morse string with 'x' separators.
       (e.g., "316024578" -> "...x---x...").
    3. Split the Morse string by the 'x' separator and look up each code
       (e.g., "...", "---", "...") to find the original letters.
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;
