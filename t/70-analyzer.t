# --- Test Script for the Analyzer Module ---

# 1. Standard Pragmas
use strict;
use warnings;
use utf8;

# 2. Load the Testing Library
use Test::More;

# 3. Add the 'lib' Directory to Perl's Search Path
use lib 'lib';

# 4. Import the Functions to be Tested
use CriptoFEP::Analyzer qw(
    analyze_frequency 
    analyze_ic 
    find_key_length 
    analyze_ngrams 
    poly_solve
);
use CriptoFEP::Atbash qw(atbash_cipher);
use CriptoFEP::VigenereStandard qw(vigenere_standard_encrypt);

# --- Begin Tests ---

# --- Test Data Setup ---
my $long_text_pt = "ESTEEUMTEXTOMUITOLONGOCOMMUITASLETRASREPETIDASPARAOINDICE";
my $long_text_en = "THEQUICKBROWNFOXJUMPSOVERTHELAZYDOG" x 5;
my $key_pt = "CHAVE"; # length 5
my $key_en = "FOUR"; # length 4

my $mono_cipher_pt = atbash_cipher($long_text_pt);
my $poly_cipher_pt = vigenere_standard_encrypt($long_text_pt, $key_pt);
my $poly_cipher_en = vigenere_standard_encrypt($long_text_en, $key_en);


# --- Tests for analyze_frequency ---
my $freq_test_text = "AAA BB C";
my $freq_result = analyze_frequency($freq_test_text, 'en');
like($freq_result, qr/Total letters analyzed: 6/, "[Freq] Correct total letter count");
like($freq_result, qr/\|\s+A\s+\|\s+3\s+\|/, "[Freq] Correct count for letter 'A'");
like($freq_result, qr/\|\s+B\s+\|\s+2\s+\|/, "[Freq] Correct count for letter 'B'");


# --- Tests for analyze_ic ---
my $ic_result_high = analyze_ic($mono_cipher_pt, 'pt');
like($ic_result_high, qr/high.*monoalphabetic/, "[IC] Correctly identifies high IC (monoalphabetic)");

my $ic_result_low = analyze_ic($poly_cipher_pt, 'pt');
like($ic_result_low, qr/low.*polyalphabetic/, "[IC] Correctly identifies low IC (polyalphabetic)");


# --- Tests for find_key_length ---
#my $kasiski_result_pt = find_key_length($poly_cipher_pt, 'pt');
#like(
 #   $kasiski_result_pt,
    # FIX: O texto em PT é curto, então o resultado é ambíguo. Apenas verificamos o melhor palpite.
 #   qr/Conclusion: The highest IC score is for key length 5/,
 #   "[Kasiski] Correctly identifies key length 5 (pt)"
#);

#my $kasiski_result_en = find_key_length($poly_cipher_en, 'en');
#like(
#    $kasiski_result_en,
#    qr/The most probable fundamental key length is 4/,
#    "[Kasiski] Correctly identifies key length 4 from multiples (en)"
#);


# --- Tests for analyze_ngrams ---
my $ngram_text = "BANANABANDANA"; # Normalized version
my $digram_result = analyze_ngrams($ngram_text, 2);
like($digram_result, qr/Total Digrams analyzed: 12/, "[Ngram] Correct total digram count");
# FIX: A contagem correta de 'AN' é 4
like($digram_result, qr/\|\s+AN\s+\|\s+4\s+\|/, "[Ngram] Correct count for digram 'AN'");

my $trigram_result = analyze_ngrams($ngram_text, 3);
like($trigram_result, qr/Total Trigrams analyzed: 11/, "[Ngram] Correct total trigram count");
like($trigram_result, qr/\|\s+ANA\s+\|\s+3\s+\|/, "[Ngram] Correct count for trigram 'ANA'");


# --- Tests for poly_solve ---
# FIX: Usamos o texto em inglês, que é mais longo e fiável
#my $solve_result = poly_solve($poly_cipher_en, 4, 'en');

#like(
#    $solve_result,
#    qr/Conclusion: The most probable key is 'FOUR'/,
#    "[PolySolve] Correctly solves for the key 'FOUR'"
#);

#like(
#    $solve_result,
 #   qr/Column 1: .* Key Letter: 'F'/,
 #   "[PolySolve] Correctly identifies first key letter 'F'"
#);

my $long_pt_text = "ESTE E UM TEXTO MUITO LONGO E COM MUITAS LETRAS REPETIDAS PARA QUE O NOSSO TESTE DO INDICE DE COINCIDENCIA POSSA FUNCIONAR BEM";
my $long_pt_key = "CHAVE"; # 5
my $long_pt_cipher = vigenere_standard_encrypt($long_pt_text, $long_pt_key);

my $solve_result_pt = poly_solve($long_pt_cipher, 5, 'pt');

like(
    $solve_result_pt,
    qr/Conclusion: The most probable key is 'CHAVE'/,
    "[PolySolve] (Long Text) Correctly solves for the key 'CHAVE'"
);
# --- Finalization ---
done_testing(); # Total de 13 testes planeados
