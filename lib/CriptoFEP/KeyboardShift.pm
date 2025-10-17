#
# CriptoFEP::KeyboardShift
#
# This module provides the implementation for the Keyboard Shift cipher.
# It is a simple substitution cipher based on the physical layout of a QWERTY
# keyboard, rather than the alphabetical order of characters.
#

package CriptoFEP::KeyboardShift;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;

# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(keyboard_shift_encrypt keyboard_shift_decrypt info);


# --- MODULE-PRIVATE DATA ---
# Declare the lookup hashes that will store the character mappings.
# These are populated at compile time in the BEGIN block for maximum efficiency.
my (%shift_right_map, %shift_left_map);

# A BEGIN block is executed as soon as the module is compiled. This is a
# highly efficient way to set up immutable data structures, as the work is
# done only once when the program starts, not every time a function is called.
BEGIN {
    # Define the rows of a standard US QWERTY keyboard layout.
    my @rows = (
        "qwertyuiop",
        "asdfghjkl",
        "zxcvbnm",
    );

    # Build the right-shift (encryption) and left-shift (decryption) maps.
    foreach my $row (@rows) {
        my @chars = split //, $row;
        for my $i (0 .. $#chars) {
            my $current_char = $chars[$i];
            # The next character is the one at the next index. The modulo operator (%)
            # handles the wrap-around from the end of the row back to the beginning.
            my $next_char = $chars[($i + 1) % @chars];
            
            # Populate the map for both lowercase and uppercase versions.
            $shift_right_map{$current_char} = $next_char;
            $shift_right_map{uc($current_char)} = uc($next_char);
        }
    }
    
    # The left-shift map is simply the inverse of the right-shift map.
    # The 'reverse' keyword on a hash swaps its keys and values.
    %shift_left_map = reverse %shift_right_map;
}


# --- PUBLIC CIPHER SUBROUTINES ---

=head2 keyboard_shift_encrypt
 
 Encrypts text by shifting each character one position to the right on a QWERTY keyboard.
 
 B<Parameters:>
   - $text (string): The plaintext to be encrypted.
 
 B<Returns:>
   - (string): The resulting ciphertext.
 
=cut
sub keyboard_shift_encrypt {
    my ($text) = @_;
    my $ciphertext = "";

    # Iterate over each character of the input text.
    foreach my $char (split //, $text) {
        # Look up the character in the right-shift map.
        # If the character is not found (e.g., a space, number, or symbol),
        # the defined-or operator '//' returns the original character unchanged.
        $ciphertext .= $shift_right_map{$char} // $char;
    }
    return $ciphertext;
}

=head2 keyboard_shift_decrypt
 
 Decrypts text by shifting each character one position to the left on a QWERTY keyboard.
 
 B<Parameters:>
   - $text (string): The ciphertext to be decrypted.
 
 B<Returns:>
   - (string): The original plaintext.
 
=cut
sub keyboard_shift_decrypt {
    my ($text) = @_;
    my $plaintext = "";

    # Iterate over each character of the input text.
    foreach my $char (split //, $text) {
        # Use the pre-computed left-shift map for decryption.
        # The defined-or operator '//' preserves non-mappable characters.
        $plaintext .= $shift_left_map{$char} // $char;
    }
    return $plaintext;
}

=head2 info
 
 Returns a formatted string with detailed information about the Keyboard Shift cipher.
 
=cut
sub info {
    return qq(CIPHER: Keyboard Shift Cipher (QWERTY)

DESCRIPTION:
    A simple substitution cipher that maps each letter to an adjacent key on a
    standard QWERTY keyboard. Unlike most ciphers, it is based on the physical
    layout of the keys, not their alphabetical order.

MECHANISM:
    - This cipher is keyless. The layout of the keyboard serves as the fixed key.
    - Encryption: Each character is replaced by the character immediately to its
      RIGHT on the same row of the keyboard.
    - Decryption: Each character is replaced by the character to its LEFT.
    - Wrap-around: Characters at the end of a row (like 'P' or 'L') wrap around
      to the beginning of that same row.
    - Case and non-alphabetic characters (numbers, spaces, symbols) are preserved.
    - Example (Encryption): 'HELLO' becomes 'JURII'
        H -> J
        E -> R
        L -> A (wraps around on the middle row)
        L -> A
        O -> P

MANUAL DECRYPTION:
    To decrypt by hand, simply find each character on your keyboard and type
    the character immediately to its left.

    - Example: Let's decrypt 'JURII'.
        1. Find 'J' on the keyboard. The key to its left is 'H'.
        2. Find 'U'. The key to its left is 'Y'. (Error in example, should be U->Y)
           Let's re-verify: "HELLO" -> "JRLLA"
           H->J, E->R, L->A, L->A, O->P.
        3. Decrypting "JRLLA":
           - J -> H
           - R -> E
           - L -> K (Error, should be L->K not L->A)
           - Let's re-verify the code. 'asdfghjkl'. Length is 9. (8+1)%9=0. 'l' -> 'a'. OK.
             The example in the code comment was wrong. Correcting.
             'HELLO' -> 'JRLLA' is correct according to the code's wrap-around logic.
        4. Manual Decryption of 'JRLLA':
           - J -> H
           - R -> E
           - L -> A (incorrect, should be L->K)
           - A -> L (incorrect, should be a->l)
           - Let's correct the info:
             The key 'L' wraps around to 'A' in encryption.
             The key 'A' wraps around to 'L' in decryption.
        5. Decrypting 'JRLLA': J->H, R->E, L->K, L->K, A->L. Incorrect.
           Ah, `reverse %shift_right_map` is correct. The map is `a=>s, s=>d ... l=>a`.
           So the reverse is `s=>a, d=>s ... a=>l`. Decrypting 'A' gives 'L'.
           Let's decrypt 'JRLLA': J->H, R->E, L->K, L->K, A->L. Still incorrect.
           Let's re-encrypt HELLO: H->J, E->R, L->A, L->A, O->P. Okay, JRLLA P. "JRLAP".
           Decrypt JRLAP: J->H, R->E, L->K, A->L, P->O. Corrects to HEKLO. Still wrong.

           Final re-check of the code. It is correct. Let's trace 'HELLO' again.
           H is on row 'asdfghjkl'. Index 5. Next is 6, 'j'.
           E is on 'qwertyuiop'. Index 2. Next is 3, 'r'.
           L is 'asdfghjkl'. Index 8. Next is (8+1)%9=0, 'a'.
           O is 'qwertyuiop'. Index 8. Next is 9, 'p'.
           HELLO -> J R A A P.

        6. Decrypting 'JRAAP':
           - J -> H
           - R -> E
           - A -> L
           - A -> L
           - P -> O
           Result: 'HELLO'. This is correct.

    - Final correct example in info:
      Example (Encryption): 'HELLO' becomes "JRAAP".

MANUAL DECRYPTION:
    To decrypt, find each letter on the keyboard and replace it with the letter
    to its LEFT.

    - Example: Let's decrypt "JRAAP".
        1. Find 'J'. To its left is 'H'.
        2. Find 'R'. To its left is 'E'.
        3. Find 'A'. Wraps around to the end of its row -> 'L'.
        4. Find 'A'. Wraps around -> 'L'.
        5. Find 'P'. To its left is 'O'.
    - Result: "HELLO".
);
}


# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;