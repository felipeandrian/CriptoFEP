# --- Test Script for the core Utils.pm module ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8; # Crucial for testing accented characters

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions and Variables to be Tested
use CriptoFEP::Utils qw(normalize_text $alphabet_list_ref $alphabet_map_ref);

# --- Begin Tests ---

# --- Test 1: Validate the Alphabet List ---
ok(defined $alphabet_list_ref, "Alphabet list reference is defined");
is(ref $alphabet_list_ref, 'ARRAY', "Alphabet list is an ARRAY reference");
is(scalar(@$alphabet_list_ref), 26, "Alphabet list contains 26 letters");
is($alphabet_list_ref->[0], 'A', "Alphabet list starts with 'A'");
is($alphabet_list_ref->[25], 'Z', "Alphabet list ends with 'Z'");

# --- Test 2: Validate the Alphabet Map ---
ok(defined $alphabet_map_ref, "Alphabet map reference is defined");
is(ref $alphabet_map_ref, 'HASH', "Alphabet map is a HASH reference");
is(scalar(keys %$alphabet_map_ref), 26, "Alphabet map contains 26 keys");
is($alphabet_map_ref->{'A'}, 0, "Map: 'A' correctly maps to 0");
is($alphabet_map_ref->{'Z'}, 25, "Map: 'Z' correctly maps to 25");

# --- Test 3: Validate normalize_text ---
is(normalize_text("Hello World"), "HELLOWORLD", "Normalize: Handles mixed case and spaces");
is(normalize_text("123ABC456!@#"), "ABC", "Normalize: Strips numbers and symbols");
is(normalize_text("Olá, Mundo!"), "OLAMUNDO", "Normalize: Handles Portuguese diacritics");
is(normalize_text("crème brûlée"), "CREMEBRULEE", "Normalize: Handles French diacritics");
is(normalize_text("Über"), "UBER", "Normalize: Handles German diacritics");
is(normalize_text(undef), "", "Normalize: Handles undefined input gracefully");
is(normalize_text(""), "", "Normalize: Handles empty string input");

# 7. Signal that all tests are done.
done_testing();
