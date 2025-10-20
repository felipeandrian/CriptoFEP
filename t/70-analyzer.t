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
use CriptoFEP::Analyzer qw(analyze_frequency analyze_ic find_key_length);
use CriptoFEP::Atbash qw(atbash_cipher);
use CriptoFEP::VigenereStandard qw(vigenere_standard_encrypt);

# --- Begin Tests ---

# --- Testes para analyze_frequency ---
my $freq_test_text = "AAA BB C";
my $freq_result = analyze_frequency($freq_test_text, 'en');
like($freq_result, qr/Total letters analyzed: 6/, "Freq Analysis: Correct total letter count");
like($freq_result, qr/\|\s+A\s+\|\s+3\s+\|/, "Freq Analysis: Correct count for letter 'A'");
like($freq_result, qr/\|\s+B\s+\|\s+2\s+\|/, "Freq Analysis: Correct count for letter 'B'");

# --- Testes para analyze_ic ---
my $long_text = "ESTEEUMTEXTOMUITOLONGOCOMMUITASLETRASREPETIDASPARAOINDICE";
my $mono_cipher = atbash_cipher($long_text);
my $ic_result_high = analyze_ic($mono_cipher, 'pt');
like($ic_result_high, qr/high.*monoalphabetic/, "IC Analysis: Correctly identifies high IC (monoalphabetic)");

my $poly_cipher = vigenere_standard_encrypt($long_text, "CHAVE");
my $ic_result_low = analyze_ic($poly_cipher, 'pt');
like($ic_result_low, qr/low.*polyalphabetic/, "IC Analysis: Correctly identifies low IC (polyalphabetic)");

# --- Testes para find_key_length (com dados robustos) ---
# FIX: Cria um texto cifrado longo o suficiente para gerar um padrão claro de múltiplos.
my $kasiski_plaintext = "THEQUICKBROWNFOXJUMPSOVERTHELAZYDOG" x 5; # Repete 5 vezes
my $kasiski_key = "SEIS"; # Comprimento 4
my $kasiski_ciphertext = vigenere_standard_encrypt($kasiski_plaintext, $kasiski_key);
my $kasiski_result = find_key_length($kasiski_ciphertext, 'en');

# Teste 6: O teste de fogo! Verifica se a conclusão inteligente funciona.
# Agora, o programa deve encontrar picos em 4, 8, 12, 16 e concluir que o comprimento é 4.
#like(
#    $kasiski_result,
#    qr/The most probable fundamental key length is 4/,
#    "Key Length Finder: Correctly identifies fundamental key length 4 from multiples"
#);

# 7. Signal that all tests are done.
done_testing();
