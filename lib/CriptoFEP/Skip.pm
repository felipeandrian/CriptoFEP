#
# CriptoFEP::Skip
#
# This module provides the implementation for the Skip cipher.
# It functions as an intelligent wrapper, translating the Skip cipher logic
# into a specific case of the more general Columnar Transposition cipher.
#

package CriptoFEP::Skip;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;


# --- MODULE IMPORTS ---
# IMPORTANT: This module is a composition and depends entirely on the robust
# logic from the Columnar module. This is a prime example of code reuse.
use CriptoFEP::Columnar qw(columnar_encrypt columnar_decrypt);


# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(skip_encrypt skip_decrypt info);


# --- PUBLIC CIPHER SUBROUTINES ---

=head2 skip_encrypt
 
 Encrypts plaintext using the Skip cipher.
 It achieves this by converting the numeric key into a simple alphabetic
 key and then delegating the work to the Columnar cipher module.
 
 B<Parameters:>
   - $plaintext (string): The plaintext to be encrypted.
   - $key (integer): The skip interval (which corresponds to the number of columns).
 
 B<Returns:>
   - (string): The resulting ciphertext.
 
=cut
sub skip_encrypt {
    my ($plaintext, $key) = @_;
    my $skip_count = int($key);

    # The Skip cipher with a key of N is functionally identical to a Columnar
    # Transposition with a simple, sequential alphabetic key of length N
    # (e.g., a skip key of 4 is equivalent to the keyword "ABCD").
    my @letters = ('A'..'Z');
    my $columnar_key = join '', @letters[0 .. $skip_count - 1];
    
    # Delegate the actual encryption work to the already-tested Columnar module.
    return columnar_encrypt($plaintext, $columnar_key);
}

=head2 skip_decrypt
 
 Decrypts ciphertext that was encrypted with the Skip cipher.
 Like the encryption function, it acts as a wrapper for the Columnar module.
 
 B<Parameters:>
   - $ciphertext (string): The ciphertext to be decrypted.
   - $key (integer): The skip interval used for the original encryption.
 
 B<Returns:>
   - (string): The original plaintext.
 
=cut
sub skip_decrypt {
    my ($ciphertext, $key) = @_;
    my $skip_count = int($key);

    # Generate the identical sequential key used for encryption.
    my @letters = ('A'..'Z');
    my $columnar_key = join '', @letters[0 .. $skip_count - 1];
    
    # Delegate the actual decryption work to the Columnar module.
    return columnar_decrypt($ciphertext, $columnar_key);
}

=head2 info
 
 Returns a formatted string with detailed information about the Skip cipher.
 
=cut
sub info {
    return qq(CIPHER: Skip Cipher

DESCRIPTION:
    A simple transposition cipher where the ciphertext is constructed by taking
    characters from the plaintext at fixed intervals (the "skip" value).

MECHANISM:
    - The key is a number (N) that specifies the skip interval.
    - The ciphertext is formed by making N passes over the plaintext:
        - Pass 1: Start at the 1st character and take every Nth character.
        - Pass 2: Start at the 2nd character and take every Nth character.
        - ...and so on, for N passes.
    - This is functionally identical to a Columnar Transposition cipher where the
      keyword is simply the alphabet in order (e.g., a key of 4 is the same as the
      keyword "ABCD").
    - Example (Key: 4, Plaintext: "ATTACK AT DAWN"):
      This is equivalent to writing the text in a 4-column grid and reading
      down the columns in order.
        Grid:
            A T T A
            C K   A
            T   D A
            W N
      Ciphertext (reading columns 1, 2, 3, 4): "ACTWTK N T DAA  "
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;
