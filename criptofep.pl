#!/usr/bin/perl
#
# CriptoFEP - The Main Controller
# This script serves as the main entry point and command-line interface
# for the CriptoFEP toolkit. It handles argument parsing, validation,
# and dispatches tasks to the appropriate backend modules.
#

# --- PRAGMAS AND CORE MODULES ---
# Enforce modern Perl best practices and prevent common errors.
use strict;
use warnings;
# A robust module for parsing command-line options.
use Getopt::Long;

# --- FULL UNICODE (UTF-8) SUPPORT ---
# Allow the source code itself to contain UTF-8 characters.
use utf8;
# Set the default encoding for standard I/O (STDIN, STDOUT) and file operations to UTF-8.
use open ':std', ':encoding(UTF-8)';
# Import the 'decode' function to explicitly handle UTF-8 from command-line arguments.
use Encode qw(decode);


# --- LOAD CUSTOM MODULES ---
# Specify the 'lib' directory as a source for our custom modules.
use lib 'lib';
# Ciphers
use CriptoFEP::Cesar qw(cesar_encrypt cesar_decrypt info);
use CriptoFEP::Atbash qw(atbash_cipher info);
use CriptoFEP::Atbah qw(atbah_cipher info);
use CriptoFEP::Albam qw(albam_cipher info);
use CriptoFEP::Scytale qw(scytale_encrypt scytale_decrypt info);
use CriptoFEP::Polybius qw(polybius_encrypt polybius_decrypt info);
use CriptoFEP::Rot13 qw(rot13_cipher info);
use CriptoFEP::Rot47 qw(rot47_cipher info);
use CriptoFEP::Bacon qw(bacon_encrypt bacon_decrypt info);
use CriptoFEP::XOR qw(xor_encrypt xor_decrypt info);
use CriptoFEP::Vigenere qw(vigenere_encrypt vigenere_decrypt info);
use CriptoFEP::Playfair qw(playfair_encrypt playfair_decrypt info);
use CriptoFEP::RailFence qw(rail_fence_encrypt rail_fence_decrypt info);
use CriptoFEP::Affine qw(affine_encrypt affine_decrypt info);
use CriptoFEP::ADFGX qw(adfgx_encrypt adfgx_decrypt info);
use CriptoFEP::ADFGVX qw(adfgvx_encrypt adfgvx_decrypt info);
use CriptoFEP::Multiplicative qw(multiplicative_encrypt multiplicative_decrypt info);
use CriptoFEP::KeyboardShift qw(keyboard_shift_encrypt keyboard_shift_decrypt info);
use CriptoFEP::Columnar qw(columnar_encrypt columnar_decrypt info); 
use CriptoFEP::DoubleColumnar qw(double_columnar_encrypt double_columnar_decrypt info);
use CriptoFEP::AMSCO qw(amsco_encrypt amsco_decrypt info);
use CriptoFEP::CaesarBox qw(caesar_box_encrypt caesar_box_decrypt info);
# Encodings
use CriptoFEP::Morse qw(morse_encode morse_decode info);
use CriptoFEP::A1Z26 qw(a1z26_encode a1z26_decode info);
use CriptoFEP::NATO qw(nato_encode nato_decode info);
use CriptoFEP::TapCode qw(tap_code_encode tap_code_decode info);
use CriptoFEP::Navajo qw(navajo_encode navajo_decode info);
use CriptoFEP::AltCode qw(alt_code_encode alt_code_decode info);
use CriptoFEP::T9 qw(t9_encode t9_decode info);
use CriptoFEP::BrailleGS8 qw(braille_encode braille_decode info);

# --- CIPHER DATA STRUCTURE ---
# A hash of hashes that organizes all our ciphers and their functions.
my %ciphers = (
    'cesar' =>    { encrypt => \&cesar_encrypt,    decrypt => \&cesar_decrypt,    needs_key => 0, info => \&info },
    'atbash' =>   { encrypt => \&atbash_cipher,    decrypt => \&atbash_cipher,    needs_key => 0, info => \&info },
    'atbah' =>    { encrypt => \&atbah_cipher,     decrypt => \&atbah_cipher,     needs_key => 0, info => \&info },
    'albam' =>    { encrypt => \&albam_cipher,     decrypt => \&albam_cipher,     needs_key => 0, info => \&info },
    'scytale' =>  { encrypt => \&scytale_encrypt,  decrypt => \&scytale_decrypt,  needs_key => 0, info => \&info},
    'polybius' => { encrypt => \&polybius_encrypt, decrypt => \&polybius_decrypt, needs_key => 0, info => \&info },
    'rot13' =>    { encrypt => \&rot13_cipher,     decrypt => \&rot13_cipher,     needs_key => 0, info => \&info },
    'rot47' =>    { encrypt => \&rot47_cipher,     decrypt => \&rot47_cipher,     needs_key => 0, info => \&info },
    'bacon' =>    { encrypt => \&bacon_encrypt,    decrypt => \&bacon_decrypt,    needs_key => 0, info => \&info },
    'xor' =>      { encrypt => \&xor_encrypt,      decrypt => \&xor_decrypt,      needs_key => 1, info => \&info },
    'vigenere' => { encrypt => \&vigenere_encrypt, decrypt => \&vigenere_decrypt, needs_key => 1, info => \&info },
    'playfair' => { encrypt => \&playfair_encrypt, decrypt => \&playfair_decrypt, needs_key => 1, info => \&info },
    'railfence' => { encrypt => \&rail_fence_encrypt, decrypt => \&rail_fence_decrypt, needs_key => 1, info => \&info},
    'affine' =>   { encrypt => \&affine_encrypt,   decrypt => \&affine_decrypt,   needs_key => 1, info => \&info },
	'adfgx'     => { encrypt => \&adfgx_encrypt,    decrypt => \&adfgx_decrypt,    needs_key => 1, info => \&info }, 
    'adfgvx' =>   { encrypt => \&adfgvx_encrypt,   decrypt => \&adfgvx_decrypt,   needs_key => 1, info => \&info },
	'multiplicative' => { encrypt => \&multiplicative_encrypt, decrypt => \&multiplicative_decrypt, needs_key => 1, info => \&info }, 
	'keyboardshift'  => { encrypt => \&keyboard_shift_encrypt, decrypt => \&keyboard_shift_decrypt, needs_key => 0, info => \&info },
	'columnar' => { encrypt => \&columnar_encrypt, decrypt => \&columnar_decrypt, needs_key => 1, info => \&info }, 
	'doublecolumnar' => { encrypt => \&double_columnar_encrypt, decrypt => \&double_columnar_decrypt, needs_key => 1, info => \&info }, 
	'amsco' => { encrypt => \&amsco_encrypt, decrypt => \&amsco_decrypt, needs_key => 1, info => \&info }, 
	'caesarbox'      => { encrypt => \&caesar_box_encrypt,      decrypt => \&caesar_box_decrypt,      needs_key => 1, info => \&info }, 
);
# --- ENCODING DATA STRUCTURE ---
my %encodings = (
    'morse' => { encode => \&morse_encode, decode => \&morse_decode, info => \&info },
    'a1z26' => { encode => \&a1z26_encode, decode => \&a1z26_decode, info => \&info },
	'nato'  => { encode => \&nato_encode,  decode => \&nato_decode, info => \&info  },
	'tapcode' => { encode => \&tap_code_encode,decode => \&tap_code_decode, info => \&info},
	'navajo'  => { encode => \&navajo_encode,  decode => \&navajo_decode, info => \&info },
	'altcode' => { encode => \&alt_code_encode,decode => \&alt_code_decode, info => \&info},
	't9'      => { encode => \&t9_encode,      decode => \&t9_decode, info => \&info },
	'braillegs8' => { encode => \&braille_encode, decode => \&braille_decode, info => \&info },
);


# --- USER INTERFACE ---
# Displays the application banner.
sub banner { print "\n=== CriptoFEP :: Classic Cipher Toolkit ===\n\n"; }

# Displays the help message.
sub help {
    # Use qq() for a clean, multi-line string that preserves formatting.
    print qq(NAME
    criptofep - A command-line tool for classic cryptography and encodings.

SYNOPSIS
    # Cipher Mode
    perl $0 -c <cipher> [-e|-d] [options...] ["text" | --in <file>] [--out <file>]

    # Encoding Mode
    perl $0 -m <mapping> [-enc|-dec] ["text" | --in <file>] [--out <file>]

DESCRIPTION
    A versatile toolkit to encrypt, decrypt, encode, and decode text using a
    variety of classic algorithms. It supports direct command-line input as
    well as file-based operations.

OPTIONS
    GENERAL:
      -h, --help                 Display this help message and exit.
      --info                     Display detailed information about a specific cipher or encoding.
      --in <FILE>                Read input text from the specified file.
      --out <FILE>               Write the output to the specified file.

    MODE SELECTION (Choose one):
      -c, --cipher <NAME>        Enter Cipher Mode and specify the cipher to use.
      -m, --mapping <NAME>       Enter Encoding Mode and specify the mapping to use.

    ACTIONS (Choose one per mode):
      -e,   --encrypt            In Cipher Mode, encrypt the input text.
      -d,   --decrypt            In Cipher Mode, decrypt the input text.
      -enc, --encode             In Encoding Mode, encode the input text.
      -dec, --decode             In Encoding Mode, decode the input text.

    CIPHER-SPECIFIC KEYS:
      -k, --key <KEY>            Provide the primary secret key.
      -k2, --key2 <KEY>          Provide the second key (for 'doublecolumnar').
      --grid-key <KEY>           Provide the grid generation key (for 'adfgx', 'adfgvx').
      --pattern-key <PATTERN>    Provide the pattern key (for 'amsco', e.g., "1221").

AVAILABLE CIPHERS
    ); # End of the first block of text

    # Print dynamically generated lists for maintainability.
    print "    " . join(', ', sort keys %ciphers) . "\n\n";
    
    print "AVAILABLE ENCODINGS\n";
    print "    " . join(', ', sort keys %encodings) . "\n\n";

    print qq(EXAMPLES
    # Encrypt a string using the Affine cipher
    perl $0 -c affine -e -k "5,8" "affine cipher example"

    # Decrypt a string using Double Columnar with two keys
    perl $0 -c doublecolumnar -d -k "GERMAN" -k2 "SECRET" "TADWTNKA C TAA"

    # Encode the content of a file using NATO and save to another file
    perl $0 -m nato --encode --in message.txt --out nato_encoded.txt

    # Decode a string using BrailleGS8
    perl $0 -m braillegs8 -dec "⠉⠗⠊⠏⠞⠕⠋⠑⠏"
	
    # Get information about the Caesar cipher
    perl $0 -c cesar --info

);
}

# --- MAIN LOGIC ---
# Declare variables that will be populated by GetOptions.
my ($cipher_name, $encrypt_flag, $decrypt_flag, $key_input, $key2_input, $grid_key_input, $pattern_key_input);
my ($mapping_name, $encode_flag, $decode_flag);
my ($file_in, $file_out, $show_help, $info_flag);

# Parse command-line arguments and populate the variables.
GetOptions(
    'c|cipher=s'   => \$cipher_name,
    'e|encrypt'    => \$encrypt_flag,
    'd|decrypt'    => \$decrypt_flag,
    'k|key=s'      => \$key_input,
	'k2|key2=s'    => \$key2_input, 
    'grid-key=s'   => \$grid_key_input,
	'pattern-key=s'=> \$pattern_key_input,
    'm|mapping=s'  => \$mapping_name,
    'enc|encode'       => \$encode_flag,
    'dec|decode'       => \$decode_flag,
	'info'       => \$info_flag,
    'in=s'         => \$file_in,
    'out=s'        => \$file_out,
    'h|help'       => \$show_help,
);

# Display the banner.
banner();

# --- MODE INFO (has priority) ---
if ($info_flag) {
    my $target_name = $cipher_name // $mapping_name;
    die "ERROR: You must specify a cipher (-c) or mapping (-m) to get info about.\n" unless $target_name;

    my $info_ref;
    if ($cipher_name && exists $ciphers{$cipher_name}{info}) {
        $info_ref = $ciphers{$cipher_name}{info};
    }
    elsif ($mapping_name && exists $encodings{$mapping_name}{info}) {
        $info_ref = $encodings{$mapping_name}{info};
    }

    if ($info_ref) {
        print $info_ref->(); # Chama a função info() do módulo
    } else {
        print "No detailed information available for '$target_name'.\n";
    }
    exit; 
}

# --- CIPHER MODE ---
if ($cipher_name) {
    # --- Input Validation ---
    die "ERROR: You cannot specify a cipher (-c) and a mapping (-m) at the same time.\n" if $mapping_name;
    die "ERROR: You must specify an action: --encrypt (-e) or --decrypt (-d).\n" unless $encrypt_flag || $decrypt_flag;
    die "ERROR: --encrypt and --decrypt options cannot be used together.\n" if $encrypt_flag && $decrypt_flag;
    die "ERROR: Cipher '$cipher_name' is unknown.\n" unless exists $ciphers{$cipher_name};
	
	# Determine the action and the corresponding function reference from the dispatch table.
    my $action = $encrypt_flag ? 'encrypt' : 'decrypt';
    my $cipher_info = $ciphers{$cipher_name};
    my $function_ref = $cipher_info->{$action};

	# --- Get Input Text (from file or command line) ---
    my $text_input;
    if (defined $file_in) {
        open my $fh, '<', $file_in or die "ERROR: Could not open input file '$file_in': $!\n";
        read $fh, $text_input, -s $fh; close $fh;
        print "Read from file: '$file_in'\n";
    } else {
        $text_input = shift @ARGV;
    }
    die "ERROR: No input text provided.\n" unless defined $text_input;
	
	# Ensure command-line input is treated as UTF-8.
	$text_input = decode('UTF-8', $text_input) unless defined $file_in;
    
	# --- Execute Cipher ---
    my $final_result;
    my $command_info = "Cipher: $cipher_name, Action: $action";
    
	# Special handling for ciphers requiring multiple, specific keys.
	if ($cipher_name eq 'amsco') {
    die "ERROR: The 'amsco' cipher requires a primary key (-k) and a pattern key (--pattern-key).\n" 
        unless defined $key_input && defined $pattern_key_input;
    die "ERROR: The pattern key for 'amsco' must only contain '1's and '2's.\n"
        if $pattern_key_input =~ /[^12]/;
    
    $final_result = $function_ref->($text_input, [$key_input, $pattern_key_input]);
    $command_info .= ", Key: \"$key_input\", Pattern: \"$pattern_key_input\"";
	}
	elsif ($cipher_name eq 'doublecolumnar') {
    die "ERROR: The 'doublecolumnar' cipher requires a primary key (-k) and a second key (--key2).\n" 
        unless defined $key_input && defined $key2_input;
    # Passamos as duas chaves como uma referência a um array
    $final_result = $function_ref->($text_input, [$key_input, $key2_input]);
    $command_info .= ", Key 1: \"$key_input\", Key 2: \"$key2_input\"";
	}
    elsif ($cipher_name eq 'adfgvx' || $cipher_name eq 'adfgx' ) {
        die "ERROR: The 'adfgvx' or 'adfgx' cipher requires a transposition key (-k) and a grid key (--grid-key).\n" unless defined $key_input && defined $grid_key_input;
        $final_result = $function_ref->($text_input, [$grid_key_input, $key_input]);
        $command_info .= ", Transposition Key: \"$key_input\", Grid Key: \"$grid_key_input\"";
    }
	# General handling for all other ciphers that need a single key
    elsif ($cipher_info->{needs_key}) {
        die "ERROR: The '$cipher_name' cipher requires a key (-k).\n" unless defined $key_input;
        # Specific key validations
        if ($cipher_name eq 'railfence' || $cipher_name eq 'caesarbox') {
            unless ($key_input =~ /^\d+$/ && $key_input > 1) {
                die "ERROR: The key for 'railfence' or 'caesarbox' must be an integer greater than 1.\n";
            }
        }
        elsif ($cipher_name eq 'affine') {
            unless ($key_input =~ /^\d+,\d+$/) {
                die "ERROR: The key for 'affine' must be in the format 'a,b'.\n";
            }
        }
		elsif ($cipher_name eq 'multiplicative') {
            unless ($key_input =~ /^\d+$/ && grep { $_ == $key_input } (1, 3, 5, 7, 9, 11, 15, 17, 19, 21, 23, 25)) {
                die "ERROR: The key for 'multiplicative' cipher must be an integer coprime with 26.\n" .
                    "       Possible values: 1, 3, 5, 7, 9, 11, 15, 17, 19, 21, 23, 25.\n";
            }
		}
        $final_result = $function_ref->($text_input, $key_input);
        $command_info .= ", Key: \"$key_input\"";
    }
    else {
        $final_result = $function_ref->($text_input);
    }
    
    print "$command_info\n";
	
    # --- Output Result ---
    if (defined $file_out) {
        open my $fh, '>', $file_out or die "ERROR: Could not write to output file '$file_out': $!\n";
        print $fh $final_result; close $fh;
        print "Output successfully saved to '$file_out'.\n\n";
    } else {
        print "Result => [$final_result]\n\n";
    }
}

# --- ENCODING MODE ---
elsif ($mapping_name) {
    # --- Input Validation ---
    die "ERROR: You must specify an action: --encode or --decode.\n" unless $encode_flag || $decode_flag;
    die "ERROR: --encode and --decode options cannot be used together.\n" if $encode_flag && $decode_flag;
    die "ERROR: Encoding '$mapping_name' is unknown.\n" unless exists $encodings{$mapping_name};

	# Determine action and function reference.
    my $action = $encode_flag ? 'encode' : 'decode';
    my $mapping_info = $encodings{$mapping_name};
    my $function_ref = $mapping_info->{$action};
    
	# Get input text.
    my $text_input;
    if (defined $file_in) {
        open my $fh, '<', $file_in or die "ERROR: Could not open input file '$file_in': $!\n";
        read $fh, $text_input, -s $fh; close $fh;
        print "Read from file: '$file_in'\n";
    } else {
        $text_input = shift @ARGV;
    }
    die "ERROR: No input text provided.\n" unless defined $text_input;
	
	$text_input = decode('UTF-8', $text_input) unless defined $file_in;

	# Execute encoding/decoding.
    my $final_result = $function_ref->($text_input);
    my $command_info = "Encoding: $mapping_name, Action: $action";
    
    print "$command_info\n";
    
	# Output result.
    if (defined $file_out) {
        open my $fh, '>', $file_out or die "ERROR: Could not write to output file '$file_out': $!\n";
        print $fh $final_result; close $fh;
        print "Output successfully saved to '$file_out'.\n\n";
    } else {
        print "Result => [$final_result]\n\n";
    }
}

# --- NO MODE CHOSEN ---
# If no cipher or mapping was specified, or if -h was used, display help and exit.
else {
    help();
    exit;
}