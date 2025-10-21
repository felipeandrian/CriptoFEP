#
# CriptoFEP::Analyzer
#
# This module provides a suite of cryptanalysis tools, including
# frequency analysis, Index of Coincidence (IC) calculation,
# N-gram analysis, and polyalphabetic key length detection.
#
package CriptoFEP::Analyzer;

# --- CORE PRAGMAS ---
# Enforce modern Perl best practices for cleaner, safer code.
use strict;
use warnings;
use utf8;

# --- EXPORTER CONFIGURATION ---
# Standard Perl boilerplate to allow other scripts to import this module's functions.
require Exporter;
our @ISA = qw(Exporter);
# Now exporting all analysis functions.
our @EXPORT_OK = qw(analyze_frequency analyze_ic find_key_length analyze_ngrams);

# --- LANGUAGE PROFILES DATABASE ---
# An internal, "hardcoded" hash containing statistical data for various languages.
# This data is used as a baseline for comparison during analysis.
# 'order' is the array of letters from most to least frequent.
# 'ic' is the expected Index of Coincidence (IC) for that language.
my %lang_profiles = (
    'pt' => { name => "Portuguese", order => [qw(A E O S R I N D M U T C L P V G H Q B F Z J X K W Y)], ic => 0.0745 },
    'en' => { name => "English", order => [qw(E T A O I N S H R D L C U M W F G Y P B V K J X Q Z)], ic => 0.0667 },
    'es' => { name => "Spanish", order => [qw(E A O S R N I L D C T U M P B G V Y Q H F Z J X K W)], ic => 0.0770 },
    'fr' => { name => "French", order => [qw(E S A I T N R U L O D C P M V Q F B G H J X Y Z W K)], ic => 0.0778 },
    'de' => { name => "German", order => [qw(E N I S R A T D H U L C G M O B W F K Z P V J Y X Q)], ic => 0.0762 },
    'it' => { name => "Italian", order => [qw(E A I O N L R T S C D P U M V G H F B Q Z Y K X J W)], ic => 0.0737 },
    'nl' => { name => "Dutch", order => [qw(E N A T I R O D S L G V H K M U B P W C J F Z Y X Q)], ic => 0.0844 },
    'pl' => { name => "Polish", order => [qw(A I E O N Z R W S T C Y K D P M U L J B G H F Q V X)], ic => 0.0900 },
    'tr' => { name => "Turkish", order => [qw(A E I N R L K M D O U Y T S B G C P H F V Z J)], ic => 0.0700 },
    'sv' => { name => "Swedish", order => [qw(A E N T R S L I O D G M K V U P H F B C Y J Z X W Q)], ic => 0.0630 },
    'da' => { name => "Danish", order => [qw(E R N T A D S L I O G K M U B V H F P C J Y Z X Q W)], ic => 0.0690 },
    'fi' => { name => "Finnish", order => [qw(A I N T E S L O K U M V H R J P Y D B C F G W Q Z X)], ic => 0.0830 },
    'no' => { name => "Norwegian", order => [qw(E R T S N A I L K O D G V M U P F B H C J Y Z X Q W)], ic => 0.0690 },
    'hu' => { name => "Hungarian", order => [qw(E A T L S O N K M I R G Y D B Z V C F H P U J X W Q)], ic => 0.0820 },
    'ro' => { name => "Romanian", order => [qw(A E I N R T C L U S D P M O V B F H G Z J X K W Y Q)], ic => 0.0800 },
    'id' => { name => "Indonesian", order => [qw(A N E I T K U S M R L P G D H O B C Y F W Z J V X Q)], ic => 0.0800 },
);

# --- PRIVATE HELPER FUNCTION ---
# This function centralizes the logic for cleaning text and counting characters.
# It is used by all other analysis functions to promote code reuse.
=head2 _get_char_counts
 
 Internal helper function to sanitize and analyze input text.
 It centralizes the logic for normalizing text (uppercase, A-Z only)
 and counting the frequency of each character.
 
 B<Parameters:>
   - $text (string): The raw input text.
 
 B<Returns:>
   - A list containing two items:
     1. (hash ref): A reference to a hash of character counts (e.g., {'A' => 5, 'B' => 2}).
     2. (integer): The total number of alphabetic characters analyzed.
 
=cut
sub _get_char_counts {
    my ($text) = @_;
    # Convert to uppercase and strip all non-alphabetic characters.
    my $norm_text = uc($text);
    $norm_text =~ s/[^A-Z]//g;
    
    my %counts;
    # Count the occurrences of each character.
    $counts{$_}++ for (split //, $norm_text);
    
    # Return both the counts hash and the total length.
    return (\%counts, length($norm_text));
}

# --- FREQUENCY ANALYSIS FUNCTION ---
# Performs a simple single-letter frequency count.
=head2 analyze_frequency
 
 Performs a simple single-letter frequency count on the text and presents
 a formatted table comparing the results against a target language profile.
 
 B<Parameters:>
   - $text (string): The ciphertext to analyze.
   - $lang (string, optional): The 2-letter language code (e.g., 'en', 'pt').
 
 B<Returns:>
   - (string): A formatted report string.
 
=cut
sub analyze_frequency {
    my ($text, $lang) = @_;
    # Default to Portuguese if language is not specified or unknown.
    $lang = 'pt' unless defined $lang && exists $lang_profiles{$lang};
    my $profile = $lang_profiles{$lang};
    
    # Get the counts and total from the helper function.
    my ($counts_ref, $total_chars) = _get_char_counts($text);
    return "No alphabetic characters found to analyze.\n" unless $total_chars > 0;

    # Convert counts to a sortable array of hash references.
    my @results;
    foreach my $char (keys %$counts_ref) {
        push @results, { char => $char, count => $counts_ref->{$char}, freq => ($counts_ref->{$char} / $total_chars) * 100 };
    }
    my @sorted_results = sort { $b->{count} <=> $a->{count} } @results;

    # Build the output table.
    my $output = "=== CriptoFEP :: Frequency Analysis ===\n\n";
    $output .= "Analysis based on language profile: $profile->{name}\n";
    $output .= "Total letters analyzed: $total_chars\n\n";
    $output .= "[+] Letter Frequency Analysis:\n";
    $output .= ("-" x 55) . "\n";
    $output .= sprintf "| %-4s | %-7s | %-12s | %-15s |\n", "Char", "Count", "Frequency", "Most Likely";
    $output .= ("-" x 55) . "\n";
    for my $i (0 .. $#sorted_results) {
        my $res = $sorted_results[$i];
        # Provide a "guess" by mapping the rank to the target language's frequency.
        my $suggestion = $profile->{order}[$i] // '?';
        $output .= sprintf "| %-4s | %-7d | %11.2f%% | %-15s |\n", $res->{char}, $res->{count}, $res->{freq}, $suggestion;
    }
    $output .= ("-" x 55) . "\n\n";
    $output .= "Hint: The most frequent letters in $profile->{name} are usually @{$profile->{order}}[0..2].\n";
    return $output;
}

# --- INDEX OF COINCIDENCE ANALYSIS FUNCTION ---
# Calculates the IC to help determine the cipher type (monoalphabetic vs. polyalphabetic).
=head2 analyze_ic
 
 Calculates the Index of Coincidence (IC) for the text. This is a powerful
 tool for identifying the *type* of cipher used (e.g., monoalphabetic vs. polyalphabetic).
 
 B<Parameters:>
   - $text (string): The ciphertext to analyze.
   - $lang (string, optional): The 2-letter language code for comparison.
 
 B<Returns:>
   - (string): A formatted report with the calculated IC and an interpretation.
 
=cut
sub analyze_ic {
    my ($text, $lang) = @_;
    $lang = 'pt' unless defined $lang && exists $lang_profiles{$lang};
    my $profile = $lang_profiles{$lang};

    my ($counts_ref, $total_chars) = _get_char_counts($text);
    return "Not enough text to calculate Index of Coincidence.\n" if $total_chars < 2;

    # The formula for IC is: Σ(ni * (ni-1)) / (N * (N-1))
    # where 'ni' is the count of the i-th letter and 'N' is the total length.
    my $sum_of_products = 0;
    foreach my $char (keys %$counts_ref) {
        my $count = $counts_ref->{$char};
        $sum_of_products += $count * ($count - 1);
    }

    my $ic = $sum_of_products / ($total_chars * ($total_chars - 1));
    my $random_ic = 1/26; # Expected IC for a random string of 26 letters.
    
    # Interpret the result by comparing it to known values.
    my $interpretation;
    if ($ic > ($profile->{ic} * 0.85)) { # If close to the target language's IC
        $interpretation = "The IC is high. This suggests a monoalphabetic substitution cipher (like Caesar, Atbash, Affine, or a simple substitution).";
    } elsif ($ic < ($random_ic * 1.5)) { # If close to the IC of random text
        $interpretation = "The IC is low. This suggests a polyalphabetic cipher (like Vigenere) or a transposition cipher.";
    } else {
        $interpretation = "The IC is inconclusive.";
    }

    # Build the output report.
    my $output = "=== CriptoFEP :: Index of Coincidence Analysis ===\n\n";
    $output .= "Total letters analyzed: $total_chars\n";
    $output .= sprintf "Index of Coincidence (IC): %.4f\n\n", $ic;
    $output .= "Reference IC for $profile->{name}: ~" . sprintf("%.4f", $profile->{ic}) . "\n";
    $output .= "Reference IC for random text: ~" . sprintf("%.4f", $random_ic) . "\n\n";
    $output .= "Interpretation: $interpretation\n";

    return $output;
}

# --- POLYALPHABETIC CIPHER DETECTOR FUNCTION ---
# Performs a Kasiski-style test to find the most probable key length of a periodic polyalphabetic cipher.
=head2 find_key_length
 
 Performs an automated Kasiski-style analysis to find the most probable
 key length of a periodic polyalphabetic cipher (like Vigenere).
 
 B<Parameters:>
   - $text (string): The ciphertext to analyze.
   - $lang (string, optional): The 2-letter language code for comparison.
 
 B<Returns:>
   - (string): A formatted report table and an intelligent conclusion.
 
=cut
sub find_key_length {
    my ($text, $lang) = @_;
    $lang = 'pt' unless defined $lang && exists $lang_profiles{$lang};
    my $profile = $lang_profiles{$lang};

    # Use the full normalized text for the analysis.
    my $norm_text = uc($text);
    $norm_text =~ s/[^A-Z]//g;
    my $text_len = length($norm_text);
    
    my @results;
    # Iterate through potential key lengths (e.g., from 2 to 20).
    for my $key_len (2 .. 20) {
        # Stop if the key length is too large to be statistically significant.
        last if $key_len > $text_len / 2;
        
        # Create an array of strings, one for each "column" of the text.
        my @columns;
        $columns[$_] = '' for 0..$key_len-1;
        my @chars = split //, $norm_text;
        # Distribute the ciphertext into columns based on the key length.
        for (my $i=0; $i<@chars; $i++) { $columns[$i % $key_len] .= $chars[$i]; }

        # Calculate the average Index of Coincidence across all columns.
        my $total_ic = 0;
        my $valid_cols = 0;
        foreach my $col_text (@columns) {
            my $col_len = length($col_text);
            next if $col_len < 2; # Need at least 2 chars to calculate IC.
            # Get the counts for this specific column.
            my ($counts_ref) = _get_char_counts($col_text);
            my $sum_of_products = 0;
            # Apply the IC formula to this column.
            foreach my $count (values %$counts_ref) { $sum_of_products += $count * ($count - 1); }
            $total_ic += $sum_of_products / ($col_len * ($col_len - 1));
            $valid_cols++;
        }
        # Calculate the average IC for this key length.
        my $avg_ic = $valid_cols > 0 ? $total_ic / $valid_cols : 0;
        push @results, { len => $key_len, ic => $avg_ic };
    }
    
    # Build the output table.
    my $output = "=== CriptoFEP :: Polyalphabetic Cipher Detector ===\n\n";
    $output .= "Analyzing $text_len characters (Language Profile: $profile->{name})\n\n";
    $output .= "[+] Index of Coincidence (IC) Analysis per Key Length:\n";
    $output .= ("-" x 45) . "\n";
    $output .= sprintf "| %-10s | %-10s | %-15s |\n", "Key Length", "Average IC", "Interpretation";
    $output .= ("-" x 45) . "\n";
    foreach my $res (@results) {
        my $interp = ($res->{ic} > $profile->{ic} * 0.9) ? "VERY LIKELY!" : (($res->{ic} > 0.055) ? "Possible" : "Unlikely");
        $output .= sprintf "| %-10d | %-10.4f | %-15s |\n", $res->{len}, $res->{ic}, $interp;
    }
    $output .= ("-" x 45) . "\n\n";
    
    # --- Intelligent Conclusion Logic ---
    my $conclusion;
    # Filter for all key lengths with a very high IC score.
    my @likely_candidates = sort { $a->{len} <=> $b->{len} }
                            grep { $_->{ic} > $profile->{ic} * 0.9 } @results;

    if (scalar @likely_candidates == 0) {
        # If no strong candidates, just report the single best score.
        my $best_guess = (sort { $b->{ic} <=> $a->{ic} } @results)[0];
        $conclusion = "Conclusion: No clear periodic pattern found. The highest score was for length $best_guess->{len}.\n";
    } else {
        # The most likely candidate is the shortest key length with a high IC.
        my $base_len = $likely_candidates[0]->{len};
        my $all_are_multiples = 1;
        
        # Check if all other high-scoring candidates are multiples of the shortest one.
        for my $i (1 .. $#likely_candidates) {
            if ($likely_candidates[$i]->{len} % $base_len != 0) {
                $all_are_multiples = 0;
                last;
            }
        }

        if ($all_are_multiples && scalar @likely_candidates > 1) {
            # This is the "jackpot" scenario.
            $conclusion = "Conclusion: High IC scores detected at multiples of $base_len.\n";
            $conclusion .= "            The most probable fundamental key length is $base_len.\n";
        } else {
            # If they are not multiples or if there's only one candidate, the situation is ambiguous.
            # Just report the single best guess.
            my $best_guess = (sort { $b->{ic} <=> $a->{ic} } @results)[0]->{len};
            $conclusion = "Conclusion: The highest IC score is for key length $best_guess.\n";
        }
    }
    $output .= $conclusion;
    # ----------------------------------------
    
    return $output;
}

=head2 analyze_ngrams
 
 Performs a frequency analysis on N-grams (digrams, trigrams, etc.) using
 a "sliding window" approach to find repeated patterns.
 
 B<Parameters:>
   - $text (string): The ciphertext to analyze.
   - $n_size (integer): The size of the N-gram (e.g., 2 for digrams).
 
 B<Returns:>
   - (string): A formatted report table of the most frequent N-grams.
 
=cut
sub analyze_ngrams {
    my ($text, $n_size) = @_; # n_size = 2 for digrams, 3 for trigrams

    my $norm_text = uc($text);
    $norm_text =~ s/[^A-Z]//g;
    my $text_len = length($norm_text);

    return "Not enough text to analyze N-grams.\n" if $text_len < $n_size;

    # 1. Count the occurrences of each N-gram.
    my %counts;
    my $total_ngrams = 0;
    # This is the "sliding window" logic.
    for (my $i = 0; $i <= $text_len - $n_size; $i++) {
        my $ngram = substr($norm_text, $i, $n_size);
        $counts{$ngram}++;
        $total_ngrams++;
    }

    return "No N-grams found to analyze.\n" unless $total_ngrams > 0;

    # 2. Calculate frequencies and sort the results.
    my @results;
    foreach my $ngram (keys %counts) {
        push @results, {
            ngram => $ngram,
            count => $counts{$ngram},
            freq  => ($counts{$ngram} / $total_ngrams) * 100,
        };
    }
    my @sorted_results = sort { $b->{count} <=> $a->{count} } @results;

    # 3. Build the output table.
    my $type = ($n_size == 2) ? "Digram" : "Trigram";
    my $output = "=== CriptoFEP :: $type Analysis ===\n\n";
    $output .= "Total $type" . "s analyzed: $total_ngrams\n\n";
    $output .= "[+] $type Frequency (Top 20):\n";
    $output .= ("-" x 30) . "\n";
    $output .= sprintf "| %-10s | %-7s | %-7s |\n", $type, "Count", "Freq.";
    $output .= ("-" x 30) . "\n";

    # Limit the output to the Top 20 most frequent N-grams for readability.
    my $limit = @sorted_results > 20 ? 19 : $#sorted_results;

    for my $i (0 .. $limit) {
        my $res = $sorted_results[$i];
        $output .= sprintf "| %-10s | %-7d | %6.2f%% |\n", $res->{ngram}, $res->{count}, $res->{freq};
    }
    $output .= ("-" x 30) . "\n";

    return $output;
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;