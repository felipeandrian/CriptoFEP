#
# CriptoFEP::XOR
#
# This module provides an implementation for the XOR cipher, a symmetric
# bitwise encryption algorithm. It uses a repeating key and represents
# the binary output as a hexadecimal string for safe display.
#
package CriptoFEP::XOR;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;
use utf8; # Ensures Perl handles Unicode strings correctly.

# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(xor_encrypt xor_decrypt info);

# --- CIPHER LOGIC ---

=head2 _perform_xor
 
 Internal helper function to perform the core XOR operation.
 It handles key repetition to match the length of the text.
 
 B<Parameters:>
   - $text (string): The raw byte string (plaintext or ciphertext).
   - $key (string): The raw key string.
 
 B<Returns:>
   - (string): The raw byte string after the XOR operation.
 
=cut
# Internal function to perform the XOR operation with a repeating key.
sub _perform_xor {
    my ($text, $key) = @_;
    # A key must be provided.
    return "" unless length($key);
    
    # Generate the repeating key (keystream) to match the text length.
    my $repeating_key = $key x (int(length($text) / length($key)) + 1);
    $repeating_key = substr($repeating_key, 0, length($text));
    
    # Perform the bitwise XOR operation.
    # Perl's '^' operator works on strings byte-by-byte.
    return $text ^ $repeating_key;
}

=head2 xor_encrypt
 
 Encrypts a plaintext string using the repeating-key XOR cipher.
 
 B<Parameters:>
   - $plaintext (string): The plaintext to be encrypted.
   - $key (string): The secret key.
 
 B<Returns:>
   - (string): The resulting ciphertext, formatted as a hexadecimal string.
 
=cut
sub xor_encrypt {
    my ($plaintext, $key) = @_;
    # Perform the core bitwise operation.
    my $result_bytes = _perform_xor($plaintext, $key);
    # Convert the (potentially non-printable) raw bytes into a hex string.
    return unpack('H*', $result_bytes);
}

=head2 xor_decrypt
 
 Decrypts a hexadecimal ciphertext string using the repeating-key XOR cipher.
 
 B<Parameters:>
   - $hex_ciphertext (string): The hex-formatted ciphertext to be decrypted.
   - $key (string): The secret key.
 
 B<Returns:>
   - (string): The original plaintext.
 
=cut
sub xor_decrypt {
    my ($hex_ciphertext, $key) = @_;
    # Convert the hex string back into its raw byte representation.
    my $ciphertext_bytes = pack('H*', $hex_ciphertext);
    # Perform the core bitwise operation (which is its own inverse).
    my $result_bytes = _perform_xor($ciphertext_bytes, $key);
    return $result_bytes;
}

# --- DOCUMENTATION SUBROUTINE ---

=head2 info
 
 Returns a formatted string with detailed information about the XOR cipher.
 This serves as the dynamic help text for the '--info' command-line option.
 
 B<Parameters:> None
 
 B<Returns:>
   - (string): A multi-line help text.
 
=cut
sub info {
    return qq(CIPHER: XOR Cipher

DESCRIPTION:
    A modern, symmetric encryption algorithm that operates on the binary data
    (bits) of the text rather than the letters themselves. It is fundamental
    to many areas of computing and cryptography due to its speed and perfectly
    symmetrical nature.

MECHANISM:
    - Each character in the text is converted to its numeric ASCII/Unicode value.
    - This number is then converted to binary (e.g., 'A' (65) -> 01000001).
    - The same is done for a character in the key.
    - A bitwise XOR (exclusive OR) operation is performed on the two binary numbers.
    - The resulting binary number is the encrypted byte.
    - Key: If the key is shorter than the text, it is repeated (Repeating Key XOR).
    - Output: The result is a stream of bytes, often non-printable. CriptoFEP
      represents this output as a hexadecimal string for safe display and use.
    - Example: 'A' (01000001) XOR 'K' (01001011) = 00001010 (byte value 10).
      CriptoFEP displays this as "0a".

MANUAL DECRYPTION:
    XOR is its own inverse. The exact same operation is used for decryption.
    (Text XOR Key) XOR Key = Text.

    - To decrypt, you must have the ciphertext in hexadecimal format.
    - Take each pair of hex characters (representing one byte) and convert it
      to its binary value.
    - Perform a bitwise XOR operation against the binary value of the
      corresponding key character.
    - Convert the resulting byte back to a character.
    - This is best done with a programming calculator.
    - Example: To decrypt "0a" with the key "K":
        1. Ciphertext byte "0a" -> binary 00001010.
        2. Key "K" -> ASCII 75 -> binary 01001011.
        3. 00001010 XOR 01001011 = 01000001.
        4. Binary 01000001 is ASCII 65, which is the character 'A'.
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;