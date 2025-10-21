#
# CriptoFEP::Utils
#
# This module provides shared helper functions and global data structures
# used by multiple cipher and encoding modules within the CriptoFEP toolkit.
# It centralizes common logic, such as text normalization and alphabet mapping,
# to ensure consistency and reduce code duplication.
#

# Declares the "full name" of this module. Corresponds to the file path.
package CriptoFEP::Utils;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;
# THE CRITICAL FIX: Tells Perl that this source code file is written in UTF-8,
# allowing Unicode characters (like Á, É, Ç) to be processed correctly.
use utf8; 

# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);

# List the functions and variables this module will "export" (make available)
# to other modules that 'use' it.
our @EXPORT_OK = qw(normalize_text $alphabet_list_ref $alphabet_map_ref);

# --- Global Definitions ---

# A global, 0-indexed list of the standard 26-letter Roman alphabet.
our @alphabet_list = ('A' .. 'Z');

# A global hash mapping each letter to its 0-based index (e.g., A=>0, B=>1).
our %alphabet_map;
@alphabet_map{@alphabet_list} = (0 .. 25); # Map: A=>0, B=>1, ...

# We export as REFERENCES to ensure the original global variables
# cannot be accidentally modified by other modules, which is a safer practice.
our $alphabet_list_ref = \@alphabet_list;
our $alphabet_map_ref  = \%alphabet_map;

# --- Utility Functions ---

=head2 normalize_text
 
 Cleans and normalizes a given string for cryptographic operations.
 This is the standard pre-processing step for most alphabetic ciphers.
 
 The normalization process involves:
 1. Converting the entire string to uppercase.
 2. Transliterating common diacritics (accented characters) to their
    base ASCII equivalent.
 3. Stripping all remaining non-alphabetic characters (spaces, punctuation, numbers).
 
 B<Parameters:>
   - $text (string): The raw input text.
 
 B<Returns:>
   - (string): The normalized, uppercase, A-Z only string.
 
=cut
sub normalize_text {
    my ($text) = @_;
    # Gracefully handle undefined input by returning an empty string.
    return '' unless defined $text;
    
    # Convert the entire string to uppercase first.
    $text = uc($text);
    
    # These regexes will now work correctly because of 'use utf8;'.
    # Transliterate common accented characters.
    $text =~ s/[ÁÀÂÃÄ]/A/g;
    $text =~ s/[ÉÈÊË]/E/g;
    $text =~ s/[ÍÌÎÏ]/I/g;
    $text =~ s/[ÓÒÔÕÖ]/O/g;
    $text =~ s/[ÚÙÛÜ]/U/g;
    $text =~ s/Ç/C/g;
    
    # This will no longer delete the base letters from the UTF-8 bytes.
    # It now correctly strips everything that is *not* a standard A-Z letter.
    $text =~ s/[^A-Z]//g; 
    
    return $text;
}

# --- MODULE SUCCESS ---
# Every Perl module MUST end with a statement that returns true
# to indicate that it has been loaded and compiled successfully.
1;