import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _login() async {
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    String? error = await auth.signIn(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    setState(() => _isLoading = false);

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    } else if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              // Unified Branding Logo
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D5AFE).withOpacity(0.1),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3D5AFE).withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.directions_run_rounded,
                        size: 60,
                        color: Color(0xFF3D5AFE),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'STRIDE',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Welcome Back',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: onSurface),
              ),
              Text(
                'Log in to continue your fitness journey',
                style: TextStyle(fontSize: 16, color: onSurface.withOpacity(0.5)),
              ),
              const SizedBox(height: 40),
              _buildTextField(
                controller: _emailController,
                label: 'Email Address',
                icon: Icons.email_outlined,
                isDark: isDark,
                onSurface: onSurface,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock_outline,
                isDark: isDark,
                onSurface: onSurface,
                obscure: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: onSurface.withOpacity(0.5),
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3D5AFE), Color(0xFF00B0FF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3D5AFE).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?", style: TextStyle(color: onSurface.withOpacity(0.7))),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                    child: const Text('Sign Up', style: TextStyle(color: Color(0xFF3D5AFE), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Center(
                child: TextButton(
                  onPressed: () async {
                    setState(() => _isLoading = true);
                    final auth = Provider.of<AuthProvider>(context, listen: false);
                    bool success = await auth.signInAnonymously();
                    setState(() => _isLoading = false);
                    if (success && context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
                    }
                  },
                  child: Text(
                    'Continue as Guest',
                    style: TextStyle(
                      color: onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(child: Divider(color: onSurface.withOpacity(0.1))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR CONTINUE WITH',
                      style: TextStyle(
                        color: onSurface.withOpacity(0.4),
                        fontSize: 12,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: onSurface.withOpacity(0.1))),
                ],
              ),
              const SizedBox(height: 25),
              Column(
                children: [
                  _socialButton(
                    icon: Icons.g_mobiledata,
                    label: 'Sign in with Google',
                    tooltip: 'Login securely with your Google account',
                    isDark: isDark,
                    onSurface: onSurface,
                    onTap: () async {
                      setState(() => _isLoading = true);
                      final auth = Provider.of<AuthProvider>(context, listen: false);
                      String? errorMessage = await auth.signInWithGoogle();
                      setState(() => _isLoading = false);
                      
                      if (errorMessage == null && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login Successful! Redirecting...')));
                        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage ?? 'Login Failed. Please try again.')));
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  _socialButton(
                    image: isDark ? 'https://github.githubassets.com/images/modules/logos_page/GitHub-Mark-Light.png' : 'https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png',
                    label: 'Sign in with GitHub',
                    tooltip: 'Access your account using GitHub',
                    isDark: isDark,
                    onSurface: onSurface,
                    onTap: () async {
                      setState(() => _isLoading = true);
                      final auth = Provider.of<AuthProvider>(context, listen: false);
                      String? errorMessage = await auth.signInWithGitHub();
                      setState(() => _isLoading = false);
                      
                      if (errorMessage == null && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login Successful! Redirecting...')));
                        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage ?? 'Login Failed. Please try again.')));
                      }
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    required Color onSurface,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: onSurface.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: onSurface.withOpacity(0.5)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF3D5AFE), width: 2),
        ),
      ),
    );
  }

  Widget _socialButton({
    IconData? icon,
    String? image,
    required String label,
    required String tooltip,
    required bool isDark,
    required Color onSurface,
    ColorFilter? colorFilter,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          height: 55,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (image != null)
                ColorFiltered(
                  colorFilter: colorFilter ?? const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                  child: Image.network(
                    image,
                    height: 24,
                    errorBuilder: (context, error, stackTrace) => Icon(icon ?? Icons.link, size: 24, color: onSurface),
                  ),
                )
              else
                Icon(icon, size: 28, color: onSurface),
              const SizedBox(width: 15),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
