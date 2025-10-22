#
# CriptoFEP::Porta
#
# This module provides an implementation for the Porta Cipher.
# It is a polyalphabetic substitution cipher notable for using
# 13 reciprocal substitution alphabets selected by a keyword.
# Like the Beaufort cipher, it is its own inverse.
#
package CriptoFEP::Porta;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;
use utf8; # Ensure correct handling of Unicode (though not strictly needed for A-Z).

# --- MODULE IMPORTS ---
# Add the parent 'lib' directory to Perl's search path.
use lib 'lib';
# Import shared utilities: text normalization and standard alphabet mappings.
# Note: While Porta uses its own tables, normalization is still useful for input.
use CriptoFEP::Utils qw(normalize_text $alphabet_list_ref $alphabet_map_ref);

# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Define which subroutines can be explicitly imported by other packages.
our @EXPORT_OK = qw(porta_cipher info);

# --- MODULE-PRIVATE DATA ---

# The core data structure holding the 13 reciprocal Porta tables.
# It's a hash where keys are the key letters ('A'..'Z') and values
# are references to the specific substitution table hash for that key letter.
my %porta_tables;

# --- Private Helper Function ---
=head2 _build_porta_tables
 
 Internal function called once when the module loads. It pre-computes
 the 13 reciprocal substitution tables used by the Porta cipher.
 
 B<Parameters:> None
 
 B<Returns:> Nothing (populates the global %porta_tables hash).
 
=cut
sub _build_porta_tables {
    # The upper half of the standard alphabet (N-Z, 13 letters).
    my @upper_half = ('N'..'Z');
    # The lower half of the standard alphabet (A-M, 13 letters).
    my @lower_half = ('A'..'M');

    # Start with the ASCII code for 'A'.
    my $key_char_code = ord('A');

    # Iterate 13 times, once for each pair of key letters (A/B, C/D, ..., Y/Z).
    for (my $i = 0; $i < 13; $i++) {
        # Create a temporary hash to hold the current table's substitutions.
        my %table;
        
        # Build the reciprocal substitution map for this table.
        for (my $j = 0; $j < 13; $j++) {
            # Get the j-th letter from the lower half (A-M).
            my $lower_char = $lower_half[$j];
            # Get the corresponding letter from the upper half (N-Z).
            # The 'shift' of the upper half depends on the table index 'i'.
            # Table A/B (i=0) maps A->N, B->O, ...
            # Table C/D (i=1) maps A->O, B->P, ...
            my $upper_char = $upper_half[ ($j + $i) % 13 ]; 
            
            # Create the reciprocal mapping (A->N and N->A).
            $table{$lower_char} = $upper_char;
            $table{$upper_char} = $lower_char;
        }
        
        # Assign this completed table to the current pair of key letters.
        my $key1 = chr($key_char_code);     # e.g., 'A'
        my $key2 = chr($key_char_code + 1); # e.g., 'B'
        
        $porta_tables{$key1} = \%table; # Store a *reference* to the table
        $porta_tables{$key2} = \%table; # Both key letters point to the *same* table
        
        # Move to the next pair of key letters (e.g., 'C').
        $key_char_code += 2; 
    }
}
# Execute the table-building function immediately when the module is loaded.
_build_porta_tables();


# --- PUBLIC CIPHER SUBROUTINE ---

=head2 porta_cipher
 
 Performs the Porta substitution on a given text using a keyword.
 Since the Porta cipher is reciprocal (its own inverse), this single
 function handles both encryption and decryption.
 
 B<Parameters:>
   - $text (string): The text to be encrypted or decrypted.
   - $key (string): The secret keyword.
 
 B<Returns:>
   - (string): The resulting ciphertext or plaintext.
 
=cut
sub porta_cipher {
    my ($text, $key) = @_;
    # Normalize the input text (uppercase, A-Z only).
    my $norm_text = normalize_text($text);
    # Normalize the key as well.
    my $norm_key  = normalize_text($key);
    # Return immediately if the key is empty.
    return $norm_text unless length($norm_key);
    
    my $output = "";
    my @text_chars = split //, $norm_text;
    my @key_chars  = split //, $norm_key;
    
    # Iterate through the text characters.
    for (my $i = 0; $i < @text_chars; $i++) {
        my $p_char = $text_chars[$i];
        # Get the current key character, repeating the key as needed.
        my $k_char = $key_chars[$i % @key_chars]; 
        
        # 1. Use the key character (e.g., 'K') to select the correct
        #    substitution table from our pre-computed map.
        my $table_ref = $porta_tables{$k_char};
        
        # 2. Look up the plaintext/ciphertext character in the selected table
        #    and append the result.
        if ($table_ref && exists $table_ref->{$p_char}) {
            $output .= $table_ref->{$p_char};
        } else {
            # If the character isn't in the table (e.g., 'J', which is
            # typically omitted, or potentially a bug), append the original.
            $output .= $p_char; 
        }
    }
    return $output;
}

=head2 info
 
 Returns a formatted string with detailed information about the Porta cipher.
 This serves as the dynamic help text for the '--info' command-line option.
 
 B<Parameters:> None
 
 B<Returns:>
   - (string): A comprehensive, multi-line help text.
 
=cut
sub info {
    # Enhanced info block with more detail and clarity.
    return qq(CIPHER: Porta Cipher

DESCRIPTION:
    A polyalphabetic substitution cipher invented by Giambattista della Porta in the 16th century. 
    It stands out among polyalphabetic ciphers like Vigenere because it uses a set of 
    13 distinct, *reciprocal* substitution alphabets, selected cyclically by a keyword. 
    Its reciprocal nature means the same function encrypts and decrypts.

KEYS:
    Requires one keyword (e.g., -k FORTUNE). Letters only.

MECHANISM:
    - The standard 26-letter alphabet is divided into two halves: A-M and N-Z.
    - There are 13 unique substitution tables. Each table defines a reciprocal swap 
      between the letters of the two halves.
    - The keyword determines which of the 13 tables to use for each plaintext letter.
    - Each pair of letters in the keyword selects one table:
        * Key 'A' or 'B' selects Table 1: [A<=>N, B<=>O, C<=>P, ..., M<=>Z]
        * Key 'C' or 'D' selects Table 2: [A<=>O, B<=>P, C<=>Q, ..., M<=>A] (shifted)
        * ...
        * Key 'Y' or 'Z' selects Table 13: [A<=>Z, B<=>A, C<=>B, ..., M<=>L] (shifted by 12)
    - To encrypt (or decrypt) a letter:
        1. Get the current key letter from the repeating keyword.
        2. Determine which of the 13 tables this key letter pair (e.g., G/H) corresponds to.
        3. Look up the plaintext (or ciphertext) letter in that table. The corresponding 
           letter in the table is the result.

RECIPROCAL PROPERTY:
    - Because each of the 13 tables is its own inverse (if A maps to N, N maps back to A 
      within that same table), the encryption and decryption processes are identical.
    - Applying the cipher twice with the same key returns the original text.

EXAMPLE (Key: "FORTUNE"):
    Plaintext:  W E L C O M E T O T H E W O R L D
    Keystream:  F O R T U N E F O R T U N E F O R
    -------------------------------------------------
    'W' (using Table F [E/F]): W -> H
    'E' (using Table O [O/P]): E -> Y
    'L' (using Table R [Q/R]): L -> T 
    'C' (using Table T [S/T]): C -> Y 
    'O' (using Table U [U/V]): O -> E 
    'M' (using Table N [M/N]): M -> S  
    'E' (using Table E [E/F]): E -> T
    'T' (using Table F [E/F]): T -> E 
    'O' (using Table O [O/P]): O -> H 
    'T' (using Table R [Q/R]): T -> L 
    'H' (using Table T [S/T]): H -> Q
    'E' (using Table U [U/V]): E -> O 
    'W' (using Table N [M/N]): W -> D
    'O' (using Table E [E/F]): O -> M
    'R' (using Table F [E/F]): R -> C 
    'L' (using Table O [O/P]): L -> S 
    'D' (using Table R [Q/R]): D -> Y
    -------------------------------------------------
    Ciphertext: H Y T Y E S T E H L Q O D M C S Y 

    (Note: The example in the original CriptoFEP info block had errors. This trace uses the implemented logic.)

MANUAL DECRYPTION:
    Identical to encryption. Use the same key ("FORTUNE") and apply the same table lookups 
    to the ciphertext letters ("HYTY...") to recover the plaintext ("WELCO...").
);
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;