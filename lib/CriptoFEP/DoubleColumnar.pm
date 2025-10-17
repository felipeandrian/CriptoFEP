#
# CriptoFEP::DoubleColumnar
#
# This module provides the implementation for the Double Columnar Transposition
# cipher. It functions as a wrapper, applying the single Columnar Transposition
# algorithm twice to significantly increase cryptographic strength.
#

package CriptoFEP::DoubleColumnar;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;

# --- MODULE IMPORTS ---
# IMPORTANT: This module is a composition and depends entirely on the logic
# from the Columnar module.
use CriptoFEP::Columnar qw(columnar_encrypt columnar_decrypt);


# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(double_columnar_encrypt double_columnar_decrypt info);


# --- PUBLIC CIPHER SUBROUTINES ---

=head2 double_columnar_encrypt
 
 Encrypts plaintext by applying the Columnar Transposition cipher twice with two separate keys.
 
 B<Parameters:>
   - $plaintext (string): The plaintext to be encrypted.
   - $key_pair (array ref): A reference to an array containing the two keys:
     - [$key1, $key2]
 
 B<Returns:>
   - (string): The resulting ciphertext.
 
=cut
sub double_columnar_encrypt {
    my ($plaintext, $key_pair) = @_;
    my ($key1, $key2) = @$key_pair;

    # 1. Apply the first transposition using the first key.
    my $intermediate_ciphertext = columnar_encrypt($plaintext, $key1);
    
    # 2. Apply the second transposition on the intermediate result, using the second key.
    my $final_ciphertext = columnar_encrypt($intermediate_ciphertext, $key2);
    
    return $final_ciphertext;
}

=head2 double_columnar_decrypt
 
 Decrypts ciphertext by reversing the Double Columnar Transposition process.
 
 B<Parameters:>
   - $ciphertext (string): The ciphertext to be decrypted.
   - $key_pair (array ref): A reference to an array containing the two keys
     in the same order they were used for encryption: [$key1, $key2]
 
 B<Returns:>
   - (string): The original plaintext.
 
=cut
sub double_columnar_decrypt {
    my ($ciphertext, $key_pair) = @_;
    my ($key1, $key2) = @$key_pair;

    # 1. Reverse the second transposition first, using the second key.
    # The order of decryption must be the reverse of the encryption order.
    my $intermediate_plaintext = columnar_decrypt($ciphertext, $key2);
    
    # 2. Reverse the first transposition on that result, using the first key.
    my $final_plaintext = columnar_decrypt($intermediate_plaintext, $key1);
    
    return $final_plaintext;
}

=head2 info
 
 Returns a formatted string with detailed information about the Double Columnar Transposition cipher.
 
=cut
sub info {
    return qq(CIPHER: Double Columnar Transposition Cipher

DESCRIPTION:
    A very strong classic transposition cipher, widely used during World War II.
    It is not a new algorithm itself, but rather the process of applying the
    standard Columnar Transposition cipher twice in succession.

MECHANISM:
    - This cipher requires two separate keywords (Key 1 and Key 2).
    - Encryption Formula:
      Ciphertext = Encrypt( Encrypt(Plaintext, Key1), Key2 )

    - First, the plaintext is encrypted using Columnar Transposition with Key 1.
    - Then, the resulting intermediate ciphertext is encrypted *again* using
      Columnar Transposition with Key 2.
    - This second pass drastically obscures any patterns left by the first,
      making it exceptionally difficult to break by hand.

MANUAL DECRYPTION:
    To decrypt, you must know both keys and apply the decryption process in the
    exact reverse order of encryption.

    - Decryption Formula:
      Plaintext = Decrypt( Decrypt(Ciphertext, Key2), Key1 )

    1. First, take the final ciphertext and decrypt it using Key 2.
    2. Then, take the result from step 1 and decrypt it using Key 1 to
       recover the original plaintext.
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;