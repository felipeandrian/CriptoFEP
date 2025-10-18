#
# CriptoFEP::VIC
#
# This module acts as the main controller for the VIC cipher. It orchestrates
# the three main stages of the algorithm—key generation, substitution, and
# transposition—by delegating the work to other specialized modules.
#

package CriptoFEP::VIC;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;
use utf8;

# --- MODULE IMPORTS ---
# Import the necessary functions from the component modules.
# This demonstrates the "composition over inheritance" design principle.
use CriptoFEP::VICKeyGenerator qw(generate_vic_keys);
use CriptoFEP::StraddlingCheckerboard qw(checkerboard_encrypt checkerboard_decrypt);
use CriptoFEP::Columnar qw(columnar_encrypt columnar_decrypt);


# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(vic_encrypt vic_decrypt info);


# --- PUBLIC CIPHER SUBROUTINES ---

=head2 vic_encrypt
 
 Encrypts plaintext using the full three-stage VIC cipher process.
 
 B<Parameters:>
   - $plaintext (string): The plaintext to be encrypted.
   - $key_pair (array ref): A reference to an array containing the two primary keys:
     - [$phrase, $date]
 
 B<Returns:>
   - (string): The final, superencrypted ciphertext.
 
=cut
sub vic_encrypt {
    my ($plaintext, $key_pair) = @_;
    my ($phrase, $date) = @$key_pair;

    # --- Stage 1: Key Generation ---
    # Use the VICKeyGenerator module to derive the complex sub-keys from the phrase and date.
    my $keys = generate_vic_keys($phrase, $date);
    my $checkerboard_key = $keys->{checkerboard};
    my $columnar_key_digits = $keys->{columnar_key};

    # --- Stage 2: Substitution ---
    # Use the StraddlingCheckerboard module to convert the plaintext into a numeric string.
    my $intermediate_text = checkerboard_encrypt($plaintext, $checkerboard_key);
    
    # --- Stage 3: Transposition ---
    # Convert the array of columnar key digits into a string, as expected by the Columnar module.
    my $columnar_key_string = join '', @$columnar_key_digits;
    # Apply a single columnar transposition to the numeric string.
    my $final_ciphertext = columnar_encrypt($intermediate_text, $columnar_key_string);
    
    return $final_ciphertext;
}

=head2 vic_decrypt
 
 Decrypts ciphertext that was encrypted with the VIC cipher by reversing the stages.
 
 B<Parameters:>
   - $ciphertext (string): The ciphertext to be decrypted.
   - $key_pair (array ref): A reference to the array of keys used for encryption.
 
 B<Returns:>
   - (string): The original plaintext.
 
=cut
sub vic_decrypt {
    my ($ciphertext, $key_pair) = @_;
    my ($phrase, $date) = @$key_pair;
    
    # --- Stage 1: Re-generate the exact same keys ---
    # The key generation process is deterministic.
    my $keys = generate_vic_keys($phrase, $date);
    my $checkerboard_key = $keys->{checkerboard};
    my $columnar_key_digits = $keys->{columnar_key};
    my $columnar_key_string = join '', @$columnar_key_digits;

    # --- Stage 2: Reverse the Transposition ---
    # The last step of encryption is the first to be undone.
    my $intermediate_text = columnar_decrypt($ciphertext, $columnar_key_string);

    # --- Stage 3: Reverse the Substitution ---
    # Decrypt the numeric string from the checkerboard to recover the original plaintext.
    my $final_plaintext = checkerboard_decrypt($intermediate_text, $checkerboard_key);

    return $final_plaintext;
}

=head2 info
 
 Returns a formatted string with detailed information about the VIC cipher.
 
=cut
sub info {
    return qq(CIPHER: VIC Cipher

DESCRIPTION:
    A very strong, multi-stage manual cipher used by Soviet spy rings during
    the Cold War (e.g., in the Hollow Nickel case). It is a superencipherment,
    combining complex key generation, substitution, and transposition to create
    a formidable cryptographic system.

MECHANISM:
    It is a three-stage process requiring a secret phrase and a date:

    1. Key Generation: A complex algorithm involving chain addition and sequencing
       converts the phrase and date into a pseudo-random sequence of digits.
       This sequence is used to derive two sub-keys: an 8-digit key for the
       checkerboard and a variable-length key for the transposition.

    2. Substitution (Straddling Checkerboard): A special grid is created where
       the 8 most common letters are mapped to single digits and the rest are
       mapped to two-digit pairs. This converts the plaintext into a compressed,
       variable-length string of numbers.

    3. Transposition (Columnar): The resulting string of numbers is then written
       into a grid and rearranged using a standard Columnar Transposition based
       on the second derived key.

MANUAL DECRYPTION:
    Decryption requires reversing the three stages in the opposite order:

    1. Re-generate the exact same sub-keys using the original phrase and date.
    2. Reverse the Columnar Transposition on the ciphertext to recover the
       intermediate numeric string.
    3. Reverse the Straddling Checkerboard substitution on the numeric string
       to recover the original plaintext.
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;