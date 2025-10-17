package CriptoFEP::Rot47;

use strict;
use warnings;
use utf8;

# --- EXPORTER CONFIGURATION ---
require Exporter;
our @ISA = qw(Exporter);

our @EXPORT_OK = qw(rot47_cipher info);

# --- CIPHER LOGIC ---

sub rot47_cipher {
    my ($text) = @_;
    
    # IMPORTANT: Text is not normalized as ROT47 operates on all printable ASCII characters.
    
    # tr/// performs the "rotation" of 47 positions on the ASCII character
    # range from ! (code 33) to ~ (code 126).
    $text =~ tr/\!-~/P-~\!-O/;
    
    return $text;
}

# --- DOCUMENTATION SUBROUTINE ---

sub info {
    return qq(CIPHER: ROT47 Cipher

DESCRIPTION:
    A variant of the Caesar cipher that operates on a larger set of characters.
    While ROT13 only affects letters, ROT47 applies a 47-position shift to all
    printable ASCII characters, from '!' (code 33) to '~' (code 126).

MECHANISM:
    - The mapping is fixed and requires no key.
    - It is a reciprocal cipher (its own inverse). The range of characters used
      is 94, and 2 * 47 = 94, making the operation perfectly symmetrical.
    - Unlike most classic ciphers, it affects letters (upper and lower case),
      numbers, and common symbols.
    - Example: 'CriptoFEP 2025!' becomes 'rC:A@~t6! a_a_P'.

MANUAL DECRYPTION:
    Because ROT47 is its own inverse, the decryption process is identical to
    the encryption process.

    - To decrypt a character, find its position within the printable ASCII range
      (from '!' to '~') and find the character that is 47 places after it,
      wrapping around if necessary.
    - Example: Let's decrypt 'r'.
        1. Find 'r' in the ASCII table.
        2. Count 47 characters forward (wrapping around from '~' back to '!').
        3. The 47th character after 'r' is 'C'. Therefore, 'r' decrypts to 'C'.
);
}

# --- MODULE SUCCESS ---
1;