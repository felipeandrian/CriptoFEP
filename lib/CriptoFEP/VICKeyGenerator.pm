#
# CriptoFEP::VICKeyGenerator
#
# This module implements the complex key generation algorithm of the VIC cipher.
# It is a helper module designed to be used by the main VIC.pm module. Its sole
# responsibility is to derive the necessary sub-keys (for the straddling
# checkerboard and columnar transposition) from a user-provided phrase and date.
#

package CriptoFEP::VICKeyGenerator;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;

# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(generate_vic_keys);


# --- MODULE-PRIVATE HELPER SUBROUTINES ---

=head2 _chain_addition
 
 Internal function to perform the chain addition step of the VIC key generation.
 It creates a long sequence of pseudo-random digits from a 5-digit seed
 using a lagged Fibonacci generator (mod 10).
 
 B<Parameters:>
   - $seed_digits (array ref): A reference to an array of 5 seed digits.
 
 B<Returns:>
   - (array ref): A reference to the generated long sequence of digits.
 
=cut
sub _chain_addition {
    my ($seed_digits) = @_;
    my @sequence = @$seed_digits;
    
    # Generate a sequence of a fixed length (e.g., 75 digits).
    while (scalar @sequence < 75) {
        # The next digit is the sum (mod 10) of the digits 5 and 4 positions back.
        my $val1 = $sequence[-5];
        my $val2 = $sequence[-4];
        push @sequence, ($val1 + $val2) % 10;
    }
    return \@sequence;
}

=head2 _sequence_keystream
 
 Internal function to perform the "sequencing" step. It converts a sequence of
 digits into a permutation of 0-9 based on the first appearance of the numbers
 1 through 9, then 0.
 
 B<Parameters:>
   - $digits (array ref): A reference to the digit sequence from chain addition.
 
 B<Returns:>
   - (array ref): A reference to the generated 10-digit keystream (a permutation of 0-9).
 
=cut
sub _sequence_keystream {
    my ($digits) = @_;
    
    # Find the first 10 unique digits in the sequence.
    my %seen;
    my @unique_10 = grep { !$seen{$_}++ } @$digits;
    @unique_10 = @unique_10[0..9];
    
    my @keystream;
    # For each number from 1 to 9, then 0, find its first position (index) in the unique list.
    for my $i (1..9, 0) {
        for my $j (0..9) {
            if ($unique_10[$j] == $i) {
                push @keystream, $j;
                last; # Found the first occurrence, move to the next number.
            }
        }
    }
    return \@keystream;
}


# --- PUBLIC SUBROUTINE ---

=head2 generate_vic_keys
 
 The main function that orchestrates the entire VIC key generation process.
 
 B<Parameters:>
   - $phrase (string): A secret phrase.
   - $date (string): A date or personal number string.
 
 B<Returns:>
   - (hash ref): A reference to a hash containing the derived keys:
     - { checkerboard => "8-digit-string", columnar_key => [array-ref-of-digits] }
 
=cut
sub generate_vic_keys {
    my ($phrase, $date) = @_;

    # --- Step 1: Generate the Phrase-to-Digit Map ---
    my $norm_phrase = uc($phrase);
    $norm_phrase =~ s/[^A-Z]//g;
    my %seen;
    # Create a source of unique letters by combining the phrase and the standard alphabet.
    # This robustly handles phrases with fewer than 10 unique letters.
    my @source_letters = split //, ($norm_phrase . "ABCDEFGHIJKLMNOPQRSTUVWXYZ");
    my @unique_letters = grep { !$seen{$_}++ } @source_letters;
    # Take the first 10 unique letters for the map.
    @unique_letters = @unique_letters[0..9];
    
    # Map these 10 letters to the digits 0-9.
    my %letter_map;
    @letter_map{@unique_letters} = 0..9;

    # --- Step 2: Generate the 5-digit seed from the date ---
    my @seed;
    # Convert the first 5 characters of the date/personal number into digits.
    foreach my $char (split //, substr(uc($date), 0, 5)) {
        # Use the map for letters, or the digit itself if it's already a number.
        push @seed, $letter_map{$char} // $char;
    }

    # --- Step 3 & 4: Generate Sequences and Keystream ---
    my $chain_added_seq = _chain_addition(\@seed);
    my $keystream = _sequence_keystream($chain_added_seq);

    # --- Step 5: Derive the Final Keys from the Generated Streams ---
    # The checkerboard key is the first 8 digits of the keystream.
    my $checkerboard_key = join '', @{$keystream}[0..7];
    
    # The 9th digit of the keystream determines the length of the columnar key.
    my $col_key_len = $keystream->[8];
    $col_key_len = 10 if $col_key_len == 0; # Special rule: 0 means a length of 10.
    
    # The columnar key itself is a slice from the long chain-added sequence.
    my @col_key_digits = @{$chain_added_seq}[50 .. 50 + $col_key_len - 1];
    
    # Return the derived keys in a structured hash reference.
    return {
        checkerboard => $checkerboard_key,
        columnar_key => \@col_key_digits,
    };
}


# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;