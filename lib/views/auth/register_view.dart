import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_view.dart'; // biar bisa navigasi balik ke login

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterView> {
  bool _obscurePassword = true;
  bool _agreeTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                'Selamat Bergabung Bersama Fourlary 👋',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Buat akunmu dan mulai untuk perjalanan barumu\nbersama Fourlary.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),

              // Nama
              Text(
                'Nama Panggilan',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              TextFormField(decoration: _inputDecoration('Nama Lengkap')),
              const SizedBox(height: 20),

              // Email
              Text(
                'Email Anda',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration('example@email.com'),
              ),
              const SizedBox(height: 20),

              // Password
              Text(
                'Password Anda',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              TextFormField(
                obscureText: _obscurePassword,
                decoration: _inputDecoration(
                  '************',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _agreeTerms,
                    onChanged: (v) => setState(() => _agreeTerms = v!),
                    activeColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'Saya setuju dengan ',
                        style: GoogleFonts.poppins(fontSize: 13),
                        children: [
                          TextSpan(
                            text: 'Kebijakan Privasi',
                            style: GoogleFonts.poppins(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Tombol daftar
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _agreeTerms ? () {} : null,
                  child: Text(
                    'Daftar',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Sudah punya akun
              Center(
                child: Text.rich(
                  TextSpan(
                    text: 'Sudah punya akun? ',
                    style: GoogleFonts.poppins(color: Colors.black87),
                    children: [
                      TextSpan(
                        text: 'Masuk di sini.',
                        style: GoogleFonts.poppins(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginView(),
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[100],
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.blue),
      ),
    );
  }
}
