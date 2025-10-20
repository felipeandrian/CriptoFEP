# --- Test Script for the VIC Cipher ---
use strict;
use warnings;
use utf8;
use Test::More;
use lib 'lib';
use CriptoFEP::VIC qw(vic_encrypt vic_decrypt);
use CriptoFEP::Utils qw(normalize_text);

# --- Begin Tests ---

# Usando os valores que VOCÊ confirmou estarem corretos.
my $phrase = "A SIN TO SIN";
my $date = "171025";
my $plaintext = "ATTACK AT DAWN";
my $ciphertext = "3773834622371727";

# Teste 1: Encriptação básica
is(
    vic_encrypt($plaintext, [$phrase, $date]),
    $ciphertext,
    "Encrypt: Should produce the correct, standard VIC ciphertext"
);

# Teste 2: Decriptação básica
is(
    vic_decrypt($ciphertext, [$phrase, $date]),
    normalize_text($plaintext),
    "Decrypt: Should correctly reverse the encryption"
);

# Teste 3: Ciclo completo
my $original = "THIS IS A TEST";
my $encrypted = vic_encrypt($original, [$phrase, $date]);
my $decrypted = vic_decrypt($encrypted, [$phrase, $date]);
is(
    $decrypted,
    normalize_text($original),
    "Full cycle: Encrypt then Decrypt should return the original (normalized)"
);

done_testing();
