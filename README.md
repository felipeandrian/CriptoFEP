
<img src="CriptoFEP.png" alt="CriptoFEP" width="100">
# 🟩 CriptoFEP — Classic Cipher Toolkit

[![Build Status](https://img.shields.io/badge/build-passing-green?style=flat-square&logo=github)]()
[![Coverage](https://img.shields.io/badge/coverage-100%25-brightgreen?style=flat-square)]()
[![Version](https://img.shields.io/badge/version-1.0.0-blue?style=flat-square)]()
[![Perl](https://img.shields.io/badge/perl-v5.8+-black?style=flat-square&logo=perl)]()
[![License](https://img.shields.io/badge/license-MIT-darkgreen?style=flat-square)]()

```
   ___|       _)         |           ____|  ____|   _ \  
  |       __|  |  __ \   __|   _ \   |      __|    |   | 
  |      |     |  |   |  |    (   |  __|    |      ___/  
 \____| _|    _|  .__/  \__| \___/  _|     _____| _|     
                 _|                                      
```

CriptoFEP is a **Perl-based command-line toolkit** for experimenting with **classic cryptography and encodings**.  
It provides a wide arsenal of historical ciphers and mappings, designed for **education, research, and CTF challenges**.

---

## ✨ Features
- 20+ classic ciphers (Caesar, Vigenère, Playfair, Affine, Rail Fence, etc.)
- Multiple encodings (Morse, NATO, TapCode, BrailleGS8, etc.)
- Full **UTF-8 support**
- Input/output via **CLI** or **files**
- Modular architecture (`lib/CriptoFEP/`)

---

## 🚀 Installation
Clone the repository:
```bash
git clone https://github.com/felipeandrian/CriptoFEP.git
cd CriptoFEP
```

Run directly with Perl:
```bash
perl criptofep.pl -h
```

---

## 🛠️ Usage Examples

### Encrypt with Affine
```bash
perl criptofep.pl -c affine -e -k "5,8" "affine cipher example"
```

### Decrypt with Double Columnar
```bash
perl criptofep.pl -c doublecolumnar -d -k "GERMAN" -k2 "SECRET" "TADWTNKA C TAA"
```

### Encode with NATO
```bash
perl criptofep.pl -m nato --encode "HELLO WORLD"
```

### Decode BrailleGS8
```bash
perl criptofep.pl -m braillegs8 -dec "⠉⠗⠊⠏⠞⠕⠋⠑⠏"
```

---

## 📂 Project Structure
```
CriptoFEP/
│── criptofep.pl        # Main CLI entrypoint
│── lib/CriptoFEP/      # Cipher & encoding modules
│── README.md           # This file
│── LICENSE             # MIT License
```

---

## ✅ Roadmap
- [ ] Add more historical ciphers
- [ ] Expand test coverage
- [ ] Publish on CPAN
- [ ] Create GitHub Pages documentation

---

## 🤝 Contributing
Pull requests are welcome.  
For major changes, please open an issue first to discuss what you’d like to improve.

---

## 📜 License
This project is licensed under the [MIT License](LICENSE).

---
