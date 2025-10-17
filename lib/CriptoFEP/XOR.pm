package CriptoFEP::XOR;

use strict;
use warnings;
use utf8;

require Exporter;
our @ISA = qw(Exporter);

our @EXPORT_OK = qw(xor_encrypt xor_decrypt info);

# --- Lógica da Cifra XOR ---

# Função interna para realizar a operação XOR com chave repetida
sub _perform_xor {
    my ($text, $key) = @_;
    return "" unless length($key);
    my $repeating_key = $key x (int(length($text) / length($key)) + 1);
    $repeating_key = substr($repeating_key, 0, length($text));
    return $text ^ $repeating_key;
}

sub xor_encrypt {
    my ($plaintext, $key) = @_;
    my $result_bytes = _perform_xor($plaintext, $key);
    return unpack('H*', $result_bytes);
}

sub xor_decrypt {
    my ($hex_ciphertext, $key) = @_;
    my $ciphertext_bytes = pack('H*', $hex_ciphertext);
    my $result_bytes = _perform_xor($ciphertext_bytes, $key);
    return $result_bytes;
}

# --- DOCUMENTATION SUBROUTINE ---

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
1;