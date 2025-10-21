#
# CriptoFEP::Analyzer
#
# This module provides a comprehensive suite of cryptanalysis tools.
# It is the "brain" of CriptoFEP's code-breaking capabilities,
# offering functions for frequency analysis, Index of Coincidence (IC)
# calculation, N-gram pattern finding, and a semi-automated solver
# for periodic polyalphabetic ciphers.
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
# Define the public API for this module.
our @EXPORT_OK = qw(
    analyze_frequency 
    analyze_ic 
    find_key_length 
    analyze_ngrams 
    poly_solve
);

# --- LANGUAGE PROFILES DATABASE ---
# An internal, "hardcoded" hash containing statistical data for various languages.
# This data is used as a baseline for comparison during analysis.
# 'name': The human-readable language name.
# 'ic': The expected Index of Coincidence for that language.
# 'order': An array of letters from most frequent to least frequent.
# 'freqs': A hash mapping each letter to its known frequency percentage.
my %lang_profiles = (
    'pt' => { 
        name => "Portuguese", 
        ic => 0.0745,
        order => [qw(A E O S R I N D M U T C L P V G H Q B F Z J X K W Y)],
        freqs => {
            'A'=>14.63, 'B'=>1.04, 'C'=>3.88, 'D'=>4.99, 'E'=>12.57, 'F'=>1.02, 'G'=>1.30,
            'H'=>1.28, 'I'=>6.18, 'J'=>0.40, 'K'=>0.02, 'L'=>2.78, 'M'=>4.74, 'N'=>5.05,
            'O'=>10.73, 'P'=>2.52, 'Q'=>1.20, 'R'=>6.53, 'S'=>7.81, 'T'=>4.34, 'U'=>4.63,
            'V'=>1.67, 'W'=>0.01, 'X'=>0.21, 'Y'=>0.01, 'Z'=>0.47
        }
    },
    'en' => { 
        name => "English", 
        ic => 0.0667,
        order => [qw(E T A O I N S H R D L C U M W F G Y P B V K J X Q Z)],
        freqs => {
            'A'=>8.17, 'B'=>1.49, 'C'=>2.78, 'D'=>4.25, 'E'=>12.70, 'F'=>2.23, 'G'=>2.02,
            'H'=>6.09, 'I'=>6.97, 'J'=>0.15, 'K'=>0.77, 'L'=>4.03, 'M'=>2.41, 'N'=>6.75,
            'O'=>7.51, 'P'=>1.93, 'Q'=>0.10, 'R'=>5.99, 'S'=>6.33, 'T'=>9.06, 'U'=>2.76,
            'V'=>0.98, 'W'=>2.36, 'X'=>0.15, 'Y'=>1.97, 'Z'=>0.07
        }
    },
    'es' => { name => "Spanish",    order => [qw(E A O S R N I L D C T U M P B G V Y Q H F Z J X K W)], ic => 0.0770 },
    'fr' => { name => "French",     order => [qw(E S A I T N R U L O D C P M V Q F B G H J X Y Z W K)], ic => 0.0778 },
    'de' => { name => "German",     order => [qw(E N I S R A T D H U L C G M O B W F K Z P V J Y X Q)], ic => 0.0762 },
    'it' => { name => "Italian",    order => [qw(E A I O N L R T S C D P U M V G H F B Q Z Y K X J W)], ic => 0.0737 },
);

# --- MODULE-GLOBAL VARIABLES ---
# Alphabet list and map for internal calculations (e.g., in poly_solve).
my @alphabet_list = ('A' .. 'Z');
my %alphabet_map;
@alphabet_map{@alphabet_list} = (0 .. 25);

# --- PRIVATE HELPER FUNCTION ---
=head2 _get_char_counts
 
 Internal helper function to sanitize and analyze input text.
 It centralizes the logic for normalizing text (uppercase, A-Z only)
 and counting the frequency of each character. This promotes the DRY
 (Don't Repeat Yourself) principle.
 
 B<Parameters:>
   - $text (string): The raw input text.
 
 B<Returns:>
   - A list containing two items:
     1. (hash ref): A reference to a hash of character counts (e.g., {'A' => 5, 'B' => 2}).
     2. (integer): The total number of alphabetic characters analyzed.
 
=cut
sub _get_char_counts {
    my ($text) = @_;
    my $norm_text = uc($text);
    $norm_text =~ s/[^A-Z]//g;
    my %counts;
    $counts{$_}++ for (split //, $norm_text);
    return (\%counts, length($norm_text));
}

# --- MATHEMATICAL ENGINE (CHI-SQUARED) ---
=head2 _calculate_chi_squared
 
 Internal helper function to calculate the Chi-Squared (χ²) statistic for a text.
 This function measures the "goodness of fit" between the letter frequencies
 of the given text and the expected frequencies of a target language.
 A *lower* Chi-Squared score indicates a *better* match.
 
 B<Parameters:>
   - $text (string): The text to score.
   - $profile (hash ref): The language profile to compare against.
 
 B<Returns:>
   - (float): The Chi-Squared score. Returns a very large number (1e9)
              if the text is empty.
 
=cut
sub _calculate_chi_squared {
    my ($text, $profile) = @_;
    my ($counts_ref, $total_chars) = _get_char_counts($text);
    # Return a massive score (bad fit) if there's no text to analyze.
    return 1e9 unless $total_chars > 0; 

    my $chi_score = 0;
    my $expected_freqs = $profile->{freqs};

    for my $char ('A' .. 'Z') {
        # Get the actual count of the letter in the given text.
        my $observed_count = $counts_ref->{$char} // 0;
        # Calculate the expected count based on the language profile.
        # Use 0.01 as a floor to prevent division-by-zero errors.
        my $expected_count = (($expected_freqs->{$char} // 0.01) / 100) * $total_chars;
        
        # Apply the Chi-Squared formula: Σ( (Observed - Expected)² / Expected )
        $chi_score += ( ($observed_count - $expected_count) ** 2 ) / $expected_count;
    }
    return $chi_score;
}

# --- PUBLIC ANALYSIS FUNCTIONS ---

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
    # Use a more lenient threshold (85%) to account for statistical noise in shorter texts.
    if ($ic > ($profile->{ic} * 0.85)) { # If close to the target language's IC
        $interpretation = "The IC is high. This suggests a monoalphabetic substitution cipher...";
    } elsif ($ic < ($random_ic * 1.5)) { # If close to the IC of random text
        $interpretation = "The IC is low. This suggests a polyalphabetic cipher...";
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
    
    # This function *must* operate on the full, normalized text string.
    my $norm_text = uc($text);
    $norm_text =~ s/[^A-Z]//g;
    my $text_len = length($norm_text);
    
    my @results;
    # Iterate through potential key lengths (e.g., from 2 to 20).
    for my $key_len (2 .. 20) {
        # Stop if the key length is too large to be statistically significant.
        last if $key_len > $text_len / 4; 
        
        # Create an array of strings, one for each "column" of the text.
        my @columns; $columns[$_] = '' for 0..$key_len-1;
        
        # Distribute the ciphertext into columns based on the key length.
        my @chars = split //, $norm_text; 
        for (my $i=0; $i<@chars; $i++) { $columns[$i % $key_len] .= $chars[$i]; }
        
        # Calculate the average Index of Coincidence across all columns.
        my $total_ic = 0; my $valid_cols = 0;
        foreach my $col_text (@columns) {
            my $col_len = length($col_text);
            next if $col_len < 2; # Need at least 2 chars to calculate IC.
            
            # Get the counts for this specific column.
            my ($col_counts_ref) = _get_char_counts($col_text);
            my $sum_of_products = 0;
            # Apply the IC formula to this column.
            foreach my $count (values %$col_counts_ref) { $sum_of_products += $count * ($count - 1); }
            my $denominator = $col_len * ($col_len - 1);
            $total_ic += $sum_of_products / $denominator if $denominator > 0;
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
    
    # Use the same lenient threshold as analyze_ic for consistency.
    my $threshold = $profile->{ic} * 0.85; 
    foreach my $res (@results) {
        my $interp = ($res->{ic} > $threshold) ? "VERY LIKELY!" : (($res->{ic} > 0.055) ? "Possible" : "Unlikely");
        $output .= sprintf "| %-10d | %-10.4f | %-15s |\n", $res->{len}, $res->{ic}, $interp;
    }
    $output .= ("-" x 45) . "\n\n";
    
    # --- Intelligent Conclusion Logic ---
    my $conclusion;
    # Filter for all key lengths with a very high IC score.
    my @likely_candidates = sort { $a->{len} <=> $b->{len} } grep { $_->{ic} > $threshold } @results;
    
    if (scalar @likely_candidates == 0) {
        # If no strong candidates, just report the single best score.
        my $best_guess_ref = (sort { $b->{ic} <=> $a->{ic} } @results)[0];
        my $best_guess = $best_guess_ref ? $best_guess_ref->{len} : 'N/A';
        $conclusion = "Conclusion: No strong periodic pattern found. The highest score was for length $best_guess.\n";
    } else {
        # The most likely candidate is the shortest key length with a high IC.
        my $base_len = $likely_candidates[0]->{len};
        my $all_are_multiples = 1;
        # Check if all other high-scoring candidates are multiples of the shortest one.
        for my $i (1 .. $#likely_candidates) { if ($likely_candidates[$i]->{len} % $base_len != 0) { $all_are_multiples = 0; last; }}
        
        if ($all_are_multiples && scalar @likely_candidates > 1) {
            # This is the "jackpot" scenario - indicates a clear repeating pattern.
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
    my ($text, $n_size) = @_;
    my $norm_text = uc($text); $norm_text =~ s/[^A-Z]//g;
    my $text_len = length($norm_text);
    return "Not enough text to analyze N-grams.\n" if $text_len < $n_size;
    # 1. Count the occurrences of each N-gram.
    my %counts; my $total_ngrams = 0;
    # This is the "sliding window" logic.
    for (my $i = 0; $i <= $text_len - $n_size; $i++) {
        my $ngram = substr($norm_text, $i, $n_size);
        $counts{$ngram}++; $total_ngrams++;
    }
    return "No N-grams found to analyze.\n" unless $total_ngrams > 0;
    # 2. Calculate frequencies and sort the results.
    my @results;
    foreach my $ngram (keys %counts) {
        push @results, { ngram => $ngram, count => $counts{$ngram}, freq  => ($counts{$ngram} / $total_ngrams) * 100 };
    }
    my @sorted_results = sort { $b->{count} <=> $a->{count} } @results;
    # 3. Build the output table.
    my $type = ($n_size == 2) ? "Digram" : (($n_size == 3) ? "Trigram" : "${n_size}-gram");
    my $output = "=== CriptoFEP :: $type Analysis ===\n\n";
    $output .= "Total $type" . "s analyzed: $total_ngrams\n\n";
    $output .= "[+] $type Frequency (Top 20):\n";
    $output .= ("-" x 30) . "\n";
    $output .= sprintf "| %-10s | %-7s | %-7s |\n", $type, "Count", "Freq.";
    $output .= ("-" x 30) . "\n";
    my $limit = @sorted_results > 20 ? 19 : $#sorted_results;
    for my $i (0 .. $limit) {
        my $res = $sorted_results[$i];
        $output .= sprintf "| %-10s | %-7d | %6.2f%% |\n", $res->{ngram}, $res->{count}, $res->{freq};
    }
    $output .= ("-" x 30) . "\n";
    return $output;
}

=head2 poly_solve
 
 Attempts to automatically solve for the key of a periodic polyalphabetic
 cipher (like Vigenere) given a ciphertext and a key length.
 
 B<Parameters:>
   - $ciphertext (string): The ciphertext to break.
   - $key_len (integer): The key length to target (found via `find_key_length`).
   - $lang (string, optional): The 2-letter language code.
 
 B<Returns:>
   - (string): A formatted report detailing the most likely key.
 
=cut
sub poly_solve {
    my ($ciphertext, $key_len, $lang) = @_;
    $lang = 'pt' unless defined $lang && exists $lang_profiles{$lang};
    my $profile = $lang_profiles{$lang};

    my $norm_text = uc($ciphertext);
    $norm_text =~ s/[^A-Z]//g;
    
    # 1. Distribute the ciphertext into columns, just like in find_key_length.
    my @columns;
    $columns[$_] = '' for 0..$key_len-1;
    my @chars = split //, $norm_text;
    for (my $i=0; $i<@chars; $i++) { $columns[$i % $key_len] .= $chars[$i]; }

    my $found_key = "";
    my $output = "=== CriptoFEP :: Polyalphabetic Solver ===\n\n";
    $output .= "Targeting Key Length: $key_len (Profile: $profile->{name})\n\n";
    $output .= "[+] Best guess for each key letter:\n\n";

    # 2. For each column...
    for (my $col_index = 0; $col_index < $key_len; $col_index++) {
        my $col_text = $columns[$col_index];
        my $best_shift = 0;
        my $best_score = 1e9; # Start with a (near) infinite Chi-Squared score.

        # 3. ...test all 26 possible Caesar shifts (0=A, 1=B, ... 25=Z).
        for (my $shift = 0; $shift < 26; $shift++) {
            
            # --- THE CRITICAL LOGIC ---
            # Decrypt the column with the current hypothetical shift.
            my $decrypted_col = "";
            foreach my $cipher_char (split //, $col_text) {
                my $c_idx = $alphabet_map{$cipher_char};
                next unless defined $c_idx;
                # Apply the Caesar DECRYPTION formula: P = (C - K + 26) % 26
                my $p_idx = ($c_idx - $shift + 26) % 26;
                $decrypted_col .= $alphabet_list[$p_idx];
            }
            # --- END OF LOGIC ---
            
            # 4. Score the result.
            # Get the Chi-Squared score for this decrypted text.
            my $current_score = _calculate_chi_squared($decrypted_col, $profile);
            
            # 5. Find the best (lowest) score.
            if ($current_score < $best_score) {
                $best_score = $current_score;
                $best_shift = $shift;
            }
        }
        # The key letter is the one that produced the lowest Chi-Squared score.
        my $key_letter = $alphabet_list[$best_shift];
        $output .= sprintf("  - Column %d: Best shift +%d (Key Letter: '%s') (Chi2: %.2f)\n",
                           $col_index + 1, $best_shift, $key_letter, $best_score);
        $found_key .= $key_letter;
    }

    $output .= "\nConclusion: The most probable key is '$found_key'.\n";
    return $output;
}

# --- MODULE SUCCESS ---
# Every Perl module must end with a true value to indicate successful loading.
1;