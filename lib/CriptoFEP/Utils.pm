# Declara o "nome completo" deste módulo. Corresponde ao caminho do ficheiro.
package CriptoFEP::Utils;

use strict;
use warnings;

# --- Boilerplate para Exportar Funções ---
# Isto permite que outros scripts usem as funções aqui definidas.
require Exporter;
our @ISA = qw(Exporter);

# Liste aqui as funções e variáveis que este módulo vai "exportar"
our @EXPORT_OK = qw(normalize_text $alphabet_list_ref $alphabet_map_ref);

# --- Definições Globais ---
our @alphabet_list = ('A' .. 'Z');
our %alphabet_map;
@alphabet_map{@alphabet_list} = (0 .. 25); # Mapa: A=>0, B=>1, ...

# Exportamos como REFERÊNCIAS para garantir que a versão original não seja modificada
our $alphabet_list_ref = \@alphabet_list;
our $alphabet_map_ref  = \%alphabet_map;

# --- Funções de Utilitários ---

sub normalize_text {
    my ($text) = @_;
    return '' unless defined $text;
    $text = uc($text);
    $text =~ s/[ÁÀÂÃÄ]/A/g;
    $text =~ s/[ÉÈÊË]/E/g;
    $text =~ s/[ÍÌÎÏ]/I/g;
    $text =~ s/[ÓÒÔÕÖ]/O/g;
    $text =~ s/[ÚÙÛÜ]/U/g;
    $text =~ s/Ç/C/g;
    $text =~ s/[^A-Z]//g;
    return $text;
}

# Todo módulo Perl DEVE terminar com uma instrução que retorna verdadeiro.
1;
