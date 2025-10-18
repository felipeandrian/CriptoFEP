#
# CriptoFEP::StraddlingCheckerboard
#
# This module provides an implementation for the Straddling Checkerboard, a
# substitution system that converts text into a variable-length sequence of
# digits. It is a key component of several advanced classic ciphers, like the VIC cipher.
#

package CriptoFEP::StraddlingCheckerboard;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;
use utf8;


# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(checkerboard_encrypt checkerboard_decrypt);


# --- MODULE-PRIVATE HELPER SUBROUTINES ---

=head2 _generate_boards
 
 Internal function to generate the forward and reverse mapping tables (boards)
 based on a numeric checkerboard key.
 
 B<Parameters:>
   - $key (string): An 8-digit string with unique digits, serving as the header row.
 
 B<Returns:>
   - A list containing two references:
     1. A reference to a hash mapping each character to its numeric code.
     2. A reference to a hash mapping each numeric code back to its character.
 
=cut
sub _generate_boards {
    my ($key) = @_;
    my %char_to_num;
    my %num_to_char;

    my @header = split //, $key;
    # The 8 most frequent letters in English, in a standard order.
    my @frequent_chars = split //, "ETAONISR";
    
    # --- Step 1: Map the frequent characters to single-digit codes ---
    for my $i (0..7) {
        my $char = $frequent_chars[$i];
        my $num  = $header[$i];
        $char_to_num{$char} = $num;
        $num_to_char{$num}  = $char;
    }

    # --- Step 2: Find the two unused digits to serve as row headers ---
    my %all_digits = map { $_ => 1 } 0..9;
    delete $all_digits{$_} for @header;
    my @other_rows = sort { $a <=> $b } keys %all_digits;

    # --- Step 3: Map the remaining 18 letters to two-digit codes ---
    my @other_chars = ('B','C','D','F','G','H','J','K','L','M','P','Q','U','V','W','X','Y','Z');
    my $char_idx = 0;
    foreach my $row_header (@other_rows) {
        for my $i (0..7) {
            # Stop if all remaining characters have been mapped.
            last if $char_idx >= @other_chars;
            
            my $char = $other_chars[$char_idx++];
            my $col_header = $header[$i];
            # The code is formed by the row header plus the column header.
            my $num = "$row_header$col_header";
            
            $char_to_num{$char} = $num;
            $num_to_char{$num}  = $char;
        }
    }
    return (\%char_to_num, \%num_to_char);
}


# --- PUBLIC CIPHER SUBROUTINES ---

=head2 checkerboard_encrypt
 
 Encrypts (substitutes) plaintext using the Straddling Checkerboard.
 
 B<Parameters:>
   - $plaintext (string): The plaintext to be encrypted.
   - $key (string): The 8-digit checkerboard key.
 
 B<Returns:>
   - (string): The resulting numeric string.
 
=cut
sub checkerboard_encrypt {
    my ($plaintext, $key) = @_;
    # Generate the mapping tables.
    my ($char_map) = _generate_boards($key);
    my $output = "";
    
    # Iterate over each character and substitute it with its numeric code.
    foreach my $char (split //, uc($plaintext)) {
        $output .= $char_map->{$char} if exists $char_map->{$char};
    }
    return $output;
}

=head2 checkerboard_decrypt
 
 Decrypts (reverse substitutes) a numeric string using the Straddling Checkerboard.
 
 B<Parameters:>
   - $ciphertext (string): The numeric string to be decrypted.
   - $key (string): The 8-digit checkerboard key.
 
 B<Returns:>
   - (string): The original plaintext.
 
=cut
sub checkerboard_decrypt {
    my ($ciphertext, $key) = @_;
    my (undef, $num_map) = _generate_boards($key);
    my $output = "";
    
    my @nums = split //, $ciphertext;
    # Process the numeric string one or two digits at a time.
    while (@nums) {
        my $d1 = shift @nums;
        
        # This is the core logic: try a single-digit lookup first.
        if (exists $num_map->{$d1}) {
            # If it's a valid single-digit code, it must correspond to a frequent letter.
            $output .= $num_map->{$d1};
        }
        # If the single digit is not a valid code, it must be the start of a two-digit code.
        else {
            my $d2 = shift @nums;
            my $pair = "$d1$d2";
            # Append the character only if the pair is valid.
            $output .= $num_map->{$pair} if defined $d2 && exists $num_map->{$pair};
        }
    }
    return $output;
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;