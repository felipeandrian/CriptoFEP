#
# CriptoFEP::Morbit
#
# This module provides an implementation for the Morbit cipher.
# Morbit is a fractionating cipher that combines Morse Code
# with a simple 3x3 grid substitution (using 'A'-'I').
# It is a keyless cipher.
#
package CriptoFEP::Morbit;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;
use utf8; # Enable UTF-8 encoding.

# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(morbit_encrypt morbit_decrypt info);

# --- MODULE-PRIVATE DATA ---
# A local Morse dictionary is used for the initial conversion.
# This makes the module self-contained and independent.
my %char_to_morse = (
    'A'=>'.-', 'B'=>'-...', 'C'=>'-.-.', 'D'=>'-..', 'E'=>'.', 'F'=>'..-.',
    'G'=>'--.', 'H'=>'....', 'I'=>'..', 'J'=>'.---', 'K'=>'-.-', 'L'=>'.-..',
    'M'=>'--', 'N'=>'-.', 'O'=>'---', 'P'=>'.--.', 'Q'=>'--.-', 'R'=>'.-.',
    'S'=>'...', 'T'=>'-', 'U'=>'..-', 'V'=>'...-', 'W'=>'.--', 'X'=>'-..-',
    'Y'=>'-.--', 'Z'=>'--..',
);

# Pre-compute the reverse map (Morse-to-char) and find the longest
# Morse code sequence. This is an optimization for the greedy
# decoding algorithm in morbit_decrypt.
my %morse_to_char;
my $max_morse_len = 0;
foreach my $char (keys %char_to_morse) {
    my $code = $char_to_morse{$char};
    $morse_to_char{$code} = $char;
    $max_morse_len = length($code) if length($code) > $max_morse_len;
}

# The fixed 3x3 substitution grid that maps pairs of Morse symbols
# ('.', '-', 'x') to the letters 'A' through 'I'.
my %pair_to_morbit = (
    '..' => 'A', '.-' => 'B', '.x' => 'C',
    '-.' => 'D', '--' => 'E', '-x' => 'F',
    'x.' => 'G', 'x-' => 'H', 'xx' => 'I',
);
# The reverse map is created automatically for efficient decryption.
my %morbit_to_pair = reverse %pair_to_morbit;

# --- PUBLIC CIPHER SUBROUTINES ---

=head2 morbit_encrypt
 
 Encrypts plaintext using the Morbit cipher.
 
 B<Parameters:>
   - $plaintext (string): The plaintext to be encrypted.
 
 B<Returns:>
   - (string): The resulting ciphertext.
 
=cut
sub morbit_encrypt {
    my ($plaintext) = @_;
    
    # --- Stage 1: Convert to Fractionated Morse ---
    my @morse_codes;
    # Convert each character of the (uppercased) plaintext to its Morse equivalent.
    foreach my $char (split //, uc($plaintext)) {
        # Ignore spaces and unknown characters.
        push @morse_codes, $char_to_morse{$char} if exists $char_to_morse{$char};
    }
    # Join the individual Morse codes with 'x' as a letter separator.
    my $morse_string = join 'x', @morse_codes;

    # --- Stage 2: Padding ---
    # The string must have an even number of symbols to be grouped into pairs.
    # If the length is odd, an 'x' is appended as padding.
    $morse_string .= 'x' if length($morse_string) % 2 != 0;

    # --- Stage 3: Substitution ---
    my $ciphertext = "";
    # Use unpack to efficiently split the string into pairs of two characters.
    foreach my $pair (unpack '(A2)*', $morse_string) {
        # Substitute each Morse pair with its corresponding Morbit letter.
        $ciphertext .= $pair_to_morbit{$pair} if exists $pair_to_morbit{$pair};
    }
    return $ciphertext;
}

=head2 morbit_decrypt
 
 Decrypts ciphertext that was encrypted with the Morbit cipher.
 
 B<Parameters:>
   - $ciphertext (string): The ciphertext to be decrypted.
 
 B<Returns:>
   - (string): The original plaintext.
 
=cut
sub morbit_decrypt {
    my ($ciphertext) = @_;
    
    # --- Stage 1: Reverse Substitution ---
    # Convert each Morbit letter back into its corresponding two-symbol Morse pair.
    my $morse_string = "";
    foreach my $char (split //, uc($ciphertext)) {
        $morse_string .= $morbit_to_pair{$char} if exists $morbit_to_pair{$char};
    }
    
    # --- Stage 2: Decode the Morse Stream ---
    # This is a "greedy" decoding algorithm, required because the
    # 'x' separators alone are not always enough to resolve ambiguity
    # (e.g., '...-' could be 'SV' or 'H').
    my $plaintext = "";
    while (length($morse_string) > 0) {
        # If the next character is a separator, just remove it and continue.
        if (substr($morse_string, 0, 1) eq 'x') {
            substr($morse_string, 0, 1, '');
            next;
        }
        
        # Try to match the longest possible Morse code first.
        my $found = 0;
        for (my $len = $max_morse_len; $len >= 1; $len--) {
            my $prefix = substr($morse_string, 0, $len);
            if (exists $morse_to_char{$prefix}) {
                # If a valid Morse code is found...
                $plaintext .= $morse_to_char{$prefix}; # ...append the character.
                substr($morse_string, 0, $len, ''); # ...remove the code from the stream.
                $found = 1;
                last; # ...and start the next search.
            }
        }
        # If no valid code is found (e.g., corrupted data), remove one
        # symbol to prevent an infinite loop.
        substr($morse_string, 0, 1, '') unless $found;
    }
    
    return $plaintext;
}

=head2 info
 
 Returns a formatted string with detailed information about the Morbit cipher.
 This serves as the dynamic help text for the '--info' command-line option.
 
 B<Parameters:> None
 
 B<Returns:>
   - (string): A multi-line help text.
 
=cut
sub info {
    return qq(CIPHER: Morbit Cipher

DESCRIPTION:
    A classic fractionating cipher that combines Morse Code with a simple
    grid substitution. It's a keyless cipher that obscures the patterns of
    standard Morse code, making it more resistant to simple frequency analysis.

MECHANISM (ENCRYPTION):
    1. The plaintext is converted to Morse code, with an 'x' separating each
       letter's code sequence.
    2. If the resulting Morse string has an odd number of symbols, an extra 'x'
       is appended to make its length even.
    3. This string is broken into pairs of symbols (digraphs).
    4. Each pair is substituted with a letter (A-I) based on a fixed 3x3 grid,
       where '..'=A, '.-'=B, '.x'=C, etc.
    - Example: "CAT"
        - Morse: "-.-.x.-x-" (length 9, odd)
        - Padded: "-.-.x.-x-x" (length 10, even)
        - Pairs: "-.", "-.", ".x", ".-", "-x"
        - Ciphertext: "DDCBF"

MANUAL DECRYPTION:
    To decrypt, you must reverse the process using the same fixed grid.

    1. For each letter in the ciphertext, find its corresponding two-symbol
       Morse pair from the 3x3 grid.
    2. Concatenate these pairs to form the full Morse string.
    3. If the string ends with a padding 'x', it is often removed.
    4. Split the string by the 'x' separator to get the codes for individual letters.
    5. Decode each resulting Morse code back into a letter.
    - Example: "DDCBF"
        - Pairs: "-.", "-.", ".x", ".-", "-x"
        - Morse String: "-.-..x.-x"
        - Split by 'x': -.-., ., .-
        - Result: C A T.
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;