import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  // Form and Controller
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State Variables
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Animation Controllers
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Focus Nodes for form navigation
  final FocusNode _fullNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    // Initialize Animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    // Dispose Controllers and Focus Nodes
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _fullNameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();

    _animationController.dispose();

    super.dispose();
  }

  Future<void> _signup() async {
    // Validate form
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        // Attempt signup
        await AuthService().signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _fullNameController.text.trim(),
        );

        // Show success message
        _showSuccessDialog();
      } catch (e) {
        // Show error dialog
        _showErrorDialog(e.toString());
      } finally {
        // Reset loading state
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Account Created'),
        content: const Text('Your account has been successfully created. Please verify your email.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Signup Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          _buildBackgroundGradient(),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              child: FadeTransition(
                opacity: _animation,
                child: _buildSignupContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[900]!,
            Colors.blue[600]!,
          ],
        ),
      ),
    );
  }

  Widget _buildSignupContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          _buildHeader(),

          const SizedBox(height: 40),

          // Signup Form
          _buildSignupForm(),

          const SizedBox(height: 24),

          // Social Signup Options
          _buildSocialSignupOptions(),

          const SizedBox(height: 24),

          // Login Option
          _buildLoginOption(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          Hero(
            tag: 'logo',
            child: Image.asset(
              'assets/acc_logo.png',
              width: 200,
              height: 200,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Create an Account',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign up to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Full Name Input
          _buildFullNameInput(),

          const SizedBox(height: 16),

          // Email Input
          _buildEmailInput(),

          const SizedBox(height: 16),

          // Password Input
          _buildPasswordInput(),

          const SizedBox(height: 16),

          // Confirm Password Input
          _buildConfirmPasswordInput(),

          const SizedBox(height: 32),

          // Signup Button
          _buildSignupButton(),
        ],
      ),
    );
  }

  Widget _buildFullNameInput() {
    return TextFormField(
      controller: _fullNameController,
      focusNode: _fullNameFocus,
      decoration: _buildInputDecoration(
        labelText: 'Full Name',
        prefixIcon: Icons.person_outline_rounded,
      ),
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) {
        FocusScope.of(context).requestFocus(_emailFocus);
      },
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your full name';
        }
        if (value.trim().length < 2) {
          return 'Name must be at least 2 characters';
        }
        return null;
      },
    );
  }

  Widget _buildEmailInput() {
    return TextFormField(
      controller: _emailController,
      focusNode: _emailFocus,
      decoration: _buildInputDecoration(
        labelText: 'Email',
        prefixIcon: Icons.email_outlined,
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) {
        FocusScope.of(context).requestFocus(_passwordFocus);
      },
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your email';
        }
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(value.trim())) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordInput() {
    return TextFormField(
      controller: _passwordController,
      focusNode: _passwordFocus,
      decoration: _buildInputDecoration(
        labelText: 'Password',
        prefixIcon: Icons.lock_outline_rounded,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.white70,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) {
        FocusScope.of(context).requestFocus(_confirmPasswordFocus);
      },
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a password';
        }
        if (value.trim().length < 8) {
          return 'Password must be at least 8 characters';
        }
        // Add more password strength validation if needed
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordInput() {
    return TextFormField(
      controller: _confirmPasswordController,
      focusNode: _confirmPasswordFocus,
      decoration: _buildInputDecoration(
        labelText: 'Confirm Password',
        prefixIcon: Icons.lock_outline_rounded,
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.white70,
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
      ),
      obscureText: _obscureConfirmPassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _signup(),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please confirm your password';
        }
        if (value.trim() != _passwordController.text.trim()) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(prefixIcon, color: Colors.white),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withOpacity(0.2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white),
      ),
      labelStyle: const TextStyle(color: Colors.white70),
      errorStyle: TextStyle(color: Colors.yellow[200]),
    );
  }

  Widget _buildSignupButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _signup,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue[900],
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _isLoading
          ? CircularProgressIndicator(color: Colors.blue[900])
          : const Text(
        'Sign Up',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSocialSignupOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialSignupButton(
          icon: Icons.g_mobiledata,
          onPressed: () {
            // Implement Google Sign-Up
          },
        ),
        const SizedBox(width: 16),
        _buildSocialSignupButton(
          icon: Icons.facebook,
          onPressed: () {
            // Implement Facebook Sign-Up
          },
        ),
      ],
    );
  }

  Widget _buildSocialSignupButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 30),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildLoginOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(color: Colors.white70),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacementNamed('/login');
          },
          child: Text(
            'Login',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}