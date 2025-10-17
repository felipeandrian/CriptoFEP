package CriptoFEP::Bacon;

use strict;
use warnings;
use utf8;

# --- MODULE IMPORTS ---
use lib 'lib';
use CriptoFEP::Utils qw(normalize_text);

# --- EXPORTER CONFIGURATION ---
require Exporter;
our @ISA = qw(Exporter);

our @EXPORT_OK = qw(bacon_encrypt bacon_decrypt info);

# --- "Dados Privados" do Módulo ---
my %bacon_map = (
    'A' => 'AAAAA', 'B' => 'AAAAB', 'C' => 'AAABA', 'D' => 'AAABB',
    'E' => 'AABAA', 'F' => 'AABAB', 'G' => 'AABBA', 'H' => 'AABBB',
    'I' => 'ABAAA', 'J' => 'ABAAA',
    'K' => 'ABAAB', 'L' => 'ABABA', 'M' => 'ABABB', 'N' => 'ABBAA',
    'O' => 'ABBAB', 'P' => 'ABBBA', 'Q' => 'ABBBB', 'R' => 'BAAAA',
    'S' => 'BAAAB', 'T' => 'BAABA', 'U' => 'BAABB', 'V' => 'BAABB',
    'W' => 'BABAA', 'X' => 'BABAB', 'Y' => 'BABBA', 'Z' => 'BABBB',
);

my %reverse_bacon_map = (
    'AAAAA' => 'A', 'AAAAB' => 'B', 'AAABA' => 'C', 'AAABB' => 'D',
    'AABAA' => 'E', 'AABAB' => 'F', 'AABBA' => 'G', 'AABBB' => 'H',
    'ABAAA' => 'I',
    'ABAAB' => 'K', 'ABABA' => 'L', 'ABABB' => 'M', 'ABBAA' => 'N',
    'ABBAB' => 'O', 'ABBBA' => 'P', 'ABBBB' => 'Q', 'BAAAA' => 'R',
    'BAAAB' => 'S', 'BAABA' => 'T', 'BAABB' => 'U',
    'BABAA' => 'W', 'BABAB' => 'X', 'BABBA' => 'Y', 'BABBB' => 'Z',
);

# --- CIPHER LOGIC ---

sub bacon_encrypt {
    my ($text) = @_;
    my $normalized_text = normalize_text($text);
    my $output = "";
    foreach my $char (split //, $normalized_text) {
        $output .= $bacon_map{$char} . ' ' if exists $bacon_map{$char};
    }
    $output =~ s/\s+$//;
    return $output;
}

sub bacon_decrypt {
    my ($text) = @_;
    my $normalized_text = normalize_text($text);
    my $output = "";
    foreach my $chunk (unpack '(A5)*', $normalized_text) {
        $output .= $reverse_bacon_map{$chunk} if exists $reverse_bacon_map{$chunk};
    }
    return $output;
}

# --- DOCUMENTATION SUBROUTINE ---

sub info {
    return qq(CIPHER: Baconian Cipher

DESCRIPTION:
    A method of steganography (hiding a message) devised by Francis Bacon in
    1605. It is a substitution cipher that encodes each letter of the alphabet
    into a sequence of five 'A's and 'B's, representing a 5-bit binary code.

MECHANISM:
    - The mapping is fixed and requires no key.
    - It uses a 24-letter alphabet, where I/J and U/V are treated as the same letter.
    - Each letter is substituted by a unique 5-character string of 'A's and 'B's.
    - Example: 'A' -> "AAAAA", 'B' -> "AAAAB", 'C' -> "AAABA", and so on.
    - The original steganographic purpose was to hide this binary sequence in a
      carrier text by using two slightly different typefaces. The CriptoFEP
      implementation shows the direct encoding.
    - Example: 'INFO' becomes "ABAAA ABBAA AABAB ABBAB".

MANUAL DECRYPTION:
    To decrypt, you simply reverse the process by grouping the ciphertext and
    looking up the corresponding letter.

    - Take the ciphertext (string of 'A's and 'B's).
    - Break it into groups of 5 characters.
    - For each group, find the matching letter in the Baconian alphabet table.
    - Example: Let's decrypt "AAABA ABAAA BAAAA".
        1. Break into groups: "AAABA", "ABAAA", "BAAAA".
        2. Look up each group:
           - "AAABA" -> 'C'
           - "ABAAA" -> 'I' (or 'J')
           - "BAAAA" -> 'R'
        3. The result is "CIR".
);
}

# --- MODULE SUCCESS ---
1;