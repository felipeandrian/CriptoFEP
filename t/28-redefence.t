# --- Test Script for the Redefence Cipher ---
use strict;
use warnings;
use utf8;
use Test::More;
use lib 'lib';
use CriptoFEP::Redefence qw(redefence_encrypt redefence_decrypt);

# --- Begin Tests ---

# Estes são os valores matematicamente corretos para a nova implementação.
my $key = 4;
my $plaintext = "ATTACK AT DAWN";
my $ciphertext = "ACTWTK NT D AAA ";

# Teste 1: Encriptação básica
is(
    redefence_encrypt($plaintext, $key),
    $ciphertext,
    "Encrypt: Should produce the correct ciphertext"
);

# Teste 2: Decriptação básica
is(
    redefence_decrypt($ciphertext, $key),
    $plaintext,
    "Decrypt: Should correctly reverse the encryption"
);

# Teste 3: Ciclo completo
my $original = "This is a much longer test for the redefence transposition";
my $test_key = 7;
my $encrypted = redefence_encrypt($original, $test_key);
my $decrypted = redefence_decrypt($encrypted, $test_key);
is(
    $decrypted,
    $original,
    "Full cycle: Encrypt then Decrypt should return the original text perfectly"
);

done_testing();
