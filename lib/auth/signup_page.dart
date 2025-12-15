import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notes_sharing/providers/auth_provider.dart';
import 'login_page.dart';
import 'package:notes_sharing/pages/main_screen.dart';
import 'package:notes_sharing/pages/profile_setup_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_fullNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showErrorSnackBar('Please fill in all fields');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorSnackBar('Passwords do not match');
      return;
    }

    if (_passwordController.text.length < 6) {
      _showErrorSnackBar('Password must be at least 6 characters long');
      return;
    }

    final auth = context.read<AuthProvider>();

    final user = await auth.signUp(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (user != null && mounted) {
      _showSuccessSnackBar('Account created successfully!');

      await Future.delayed(const Duration(milliseconds: 1500));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ProfileSetupPage(userId: user.uid),
        ),
      );
    } else {
      final message = auth.error ?? 'Signup failed. Please try again.';
      _showErrorSnackBar(message);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF000000),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade300),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF000000),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isDesktop = size.width >= 768;
    final bool isTablet = size.width >= 600;

    return Scaffold(
      body: Container(
        color: const Color(0xFFF5F5F0),
        child: Stack(
          children: [
            // Animated Background Elements
            _buildAnimatedBackground(),

            // Content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: child,
                        ),
                      );
                    },
                    child: isDesktop
                        ? _buildDesktopLayout()
                        : _buildMobileLayout(isTablet),
                  ),
                ),
              ),
            ),

            // Loading Overlay
            if (context.watch<AuthProvider>().isLoading) _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return IgnorePointer(
      child: Column(
        children: [
          // Top floating circles
          AnimatedContainer(
            duration: const Duration(seconds: 4),
            curve: Curves.easeInOut,
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.1,
              left: MediaQuery.of(context).size.width * 0.1,
            ),
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFE8E8E3).withOpacity(0.6),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const Spacer(),
          // Bottom floating circles
          AnimatedContainer(
            duration: const Duration(seconds: 3),
            curve: Curves.easeInOut,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.1,
              right: MediaQuery.of(context).size.width * 0.1,
            ),
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFD4D4CC).withOpacity(0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Left side - Branding
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAppLogo(),
              const SizedBox(height: 40),
              const Text(
                'Join NoteVerse\nToday',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'Start your learning journey with thousands of students\nand access unlimited notes and resources',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF5A5A5A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              _buildFeatureGrid(),
            ],
          ),
        ),

        const SizedBox(width: 80),

        // Right side - Signup Form
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: _buildSignupForm(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(bool isTablet) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildAppLogo(),
        const SizedBox(height: 40),
        Text(
          'Create Account',
          style: TextStyle(
            fontSize: isTablet ? 36 : 32,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Join thousands of students today',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF5A5A5A),
          ),
        ),
        const SizedBox(height: 40),
        _buildSignupForm(),
      ],
    );
  }

  Widget _buildAppLogo() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.menu_book_rounded,
            color: Color(0xFFFAFAF8),
            size: 40,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'NoteVerse',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureGrid() {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.center,
      children: [
        _buildFeatureItem('🎓', 'All Semesters'),
        _buildFeatureItem('📚', 'Unlimited Notes'),
        _buildFeatureItem('🤖', 'AI Powered'),
        _buildFeatureItem('👥', 'Community'),
      ],
    );
  }

  Widget _buildFeatureItem(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E0D8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupForm() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E0D8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Full Name Field
          _buildTextField(
            controller: _fullNameController,
            label: 'Full Name',
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 20),

          // Email Field
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),

          // Password Field
          _buildPasswordField(
            controller: _passwordController,
            label: 'Password',
            obscureText: _obscurePassword,
            onToggleVisibility: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
          ),
          const SizedBox(height: 20),

          // Confirm Password Field
          _buildPasswordField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            obscureText: _obscureConfirmPassword,
            onToggleVisibility: () {
              setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
            },
          ),
          const SizedBox(height: 10),

          // Password requirements
          _buildPasswordRequirements(),
          const SizedBox(height: 20),

          // Sign Up Button
          _buildSignupButton(),
          const SizedBox(height: 30),

          // Divider
          _buildDivider(),
          const SizedBox(height: 30),

          // Login Link
          _buildLoginLink(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Color(0xFF000000)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF666666)),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF999999)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0D8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0D8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF000000)),
        ),
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Color(0xFF000000)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF666666)),
        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF999999)),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF999999),
          ),
          onPressed: onToggleVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0D8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0D8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF000000)),
        ),
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
      ),
    );
  }

  Widget _buildPasswordRequirements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password must contain:',
          style: TextStyle(
            color: const Color(0xFF666666),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        _buildRequirementItem('At least 6 characters', true),
        _buildRequirementItem('Uppercase and lowercase letters', true),
        _buildRequirementItem('Numbers and symbols', false),
      ],
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isMet ? const Color(0xFF10B981) : Colors.grey.shade600,
          size: 12,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: isMet ? const Color(0xFF10B981) : Colors.grey.shade600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildSignupButton() {
    final isLoading = context.watch<AuthProvider>().isLoading;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleSignup,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF000000),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 20),
                ],
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(height: 1, color: const Color(0xFFE0E0D8)),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Already have an account?',
            style: TextStyle(color: Color(0xFF666666)),
          ),
        ),
        Expanded(
          child: Container(height: 1, color: const Color(0xFFE0E0D8)),
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Already have an account?",
          style: TextStyle(color: Color(0xFF5A5A5A)),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const LoginPage(),
                transitionsBuilder: (_, animation, __, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(-1.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
              ),
            );
          },
          child: const Text(
            'Sign In',
            style: TextStyle(
              color: Color(0xFF000000),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Color(0xFF000000)),
        ),
      ),
    );
  }
}