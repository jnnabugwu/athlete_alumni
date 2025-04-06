import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/route_constants.dart';
import '../bloc/auth_bloc.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/utils/web_storage.dart';
import 'dart:math' as math;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      debugPrint('Login requested with email: ${_emailController.text}');
      context.read<AuthBloc>().add(
            AuthSignInRequested(
              email: _emailController.text,
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        debugPrint('LoginPage: Auth state changed to ${state.status}');
        if (state.status == AuthStatus.authenticated) {
          debugPrint('LoginPage: User authenticated, navigating to home');
          context.go(RouteConstants.home);
        } else if (state.status == AuthStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Login failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 1000) {
                return _buildDesktopLayout(state);
              } else {
                return _buildMobileLayout(state);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildDesktopLayout(AuthState state) {
    return Row(
      children: [
        // Left side - Features
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(48.0),
            color: AppColors.background,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Collegiate Athlete Network',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A1F44),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Connect with athletes, find mentors, and build your career through our powerful networking platform.',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 64),
                  _buildFeatureItem(
                    number: '1',
                    title: 'Connect with Athletes',
                    description: 'Build relationships with current and former athletes from your sport and college.',
                  ),
                  const SizedBox(height: 32),
                  _buildFeatureItem(
                    number: '2',
                    title: 'Find Mentors',
                    description: 'Get personalized career advice from athletes who have successfully transitioned to professional careers.',
                  ),
                  const SizedBox(height: 32),
                  _buildFeatureItem(
                    number: '3',
                    title: 'Join Forums',
                    description: 'Participate in discussions about your sport, college experiences, and career opportunities.',
                  ),
                  const SizedBox(height: 32),
                  _buildFeatureItem(
                    number: '4',
                    title: 'Message Directly',
                    description: 'Connect privately with mentors and peers to ask questions and seek guidance.',
                  ),
                ],
              ),
            ),
          ),
        ),
        // Right side - Login form
        Container(
          width: 480,
          padding: const EdgeInsets.all(48.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(-2, 0),
              ),
            ],
          ),
          child: _buildLoginForm(state),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(AuthState state) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Top section with logo and brief intro
          Container(
            padding: const EdgeInsets.all(24.0),
            color: AppColors.background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                const Text(
                  'Collegiate Athlete Network',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A1F44),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Connect with athletes, find mentors, and build your career.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Login form
          Container(
            padding: const EdgeInsets.all(24.0),
            child: _buildLoginForm(state),
          ),
          // Features in a more compact format
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Why Join Us?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A1F44),
                  ),
                ),
                const SizedBox(height: 24),
                _buildFeatureItem(
                  number: '1',
                  title: 'Connect with Athletes',
                  description: 'Build relationships with current and former athletes.',
                ),
                const SizedBox(height: 24),
                _buildFeatureItem(
                  number: '2',
                  title: 'Find Mentors',
                  description: 'Get personalized career advice from successful athletes.',
                ),
                const SizedBox(height: 24),
                _buildFeatureItem(
                  number: '3',
                  title: 'Join Forums',
                  description: 'Participate in discussions about sports and careers.',
                ),
                const SizedBox(height: 24),
                _buildFeatureItem(
                  number: '4',
                  title: 'Message Directly',
                  description: 'Connect privately with mentors and peers.',
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(AuthState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Fixed header and form fields section
        const Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0A1F44),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to your account to continue',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 32),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFormField(
                label: 'Email',
                controller: _emailController,
                hintText: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              _buildFormField(
                label: 'Password',
                controller: _passwordController,
                hintText: 'Enter your password',
                isPassword: true,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: state.status == AuthStatus.loading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A1F44),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: state.status == AuthStatus.loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          ),
        ),
        
        // Scrollable buttons section
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Divider(color: Colors.grey[300]),
                const SizedBox(height: 12),
                /*
                // Dev login button
                OutlinedButton(
                  onPressed: () {
                    print("Dev login clicked - direct navigation bypass");
                    try {
                      context.go(RouteConstants.home, extra: {'devBypass': true});
                    } catch (e) {
                      print("Error in dev login bypass: $e");
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey[400]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.developer_mode, size: 20),
                      SizedBox(width: 8),
                      Text('Dev Login (Direct Bypass)'),
                    ],
                  ),
                ),
                */
                const SizedBox(height: 12),
                // Links section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => context.go(RouteConstants.register),
                      child: const Text('Create an account'),
                    ),
                    TextButton(
                      onPressed: () => context.go(RouteConstants.passwordReset),
                      child: const Text('Forgot password?'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'By continuing, you agree to our Terms of Service and Privacy Policy.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xFF0A1F44),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your ${label.toLowerCase()}';
            }
            if (label == 'Email' && !value.contains('@')) {
              return 'Please enter a valid email';
            }
            if (label == 'Password' && value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required String number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A1F44),
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A1F44),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
