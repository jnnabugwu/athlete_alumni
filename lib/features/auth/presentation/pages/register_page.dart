import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/models/athlete.dart';
import '../bloc/auth_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _collegeController = TextEditingController();
  final _scrollController = ScrollController();
  AthleteStatus _athleteStatus = AthleteStatus.current;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _collegeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      debugPrint('👤 Registration requested with email: ${_emailController.text}');
      
      context.read<AuthBloc>().add(
            AuthSignUpRequested(
              email: _emailController.text,
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.go(RouteConstants.home);
        } else if (state.status == AuthStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Registration failed'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state.status == AuthStatus.loading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Processing registration...'),
              duration: Duration(seconds: 2),
            ),
          );
        } else if (state.status == AuthStatus.emailVerificationSent) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Verification Email Sent'),
                content: const Text(
                  'We\'ve sent a verification email to your address. Please check your inbox and click the verification link to complete your registration.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go(RouteConstants.login);
                    },
                    child: const Text('Go to Login'),
                  ),
                ],
              );
            },
          );
        }
      },
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 1000) {
              return _buildDesktopLayout();
            } else {
              return _buildMobileLayout();
            }
          },
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
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
                    'Join Our Athletic Community',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A1F44),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Create your athlete profile and connect with a network of current and former college athletes.',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 64),
                  _buildFeatureItem(
                    number: '1',
                    title: 'Create Your Profile',
                    description: 'Set up your athletic profile with your college, sport, and achievements.',
                  ),
                  const SizedBox(height: 32),
                  _buildFeatureItem(
                    number: '2',
                    title: 'Connect with Athletes',
                    description: 'Network with current and former athletes from your college and sport.',
                  ),
                  const SizedBox(height: 32),
                  _buildFeatureItem(
                    number: '3',
                    title: 'Access Resources',
                    description: 'Get career guidance, mentorship, and exclusive opportunities.',
                  ),
                ],
              ),
            ),
          ),
        ),
        // Right side - Registration form
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 32.0),
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
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: _buildRegistrationForm(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          // Top section with logo and brief intro
          Container(
            padding: const EdgeInsets.all(24.0),
            color: AppColors.background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                const Text(
                  'Join Our Athletic Community',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A1F44),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Create your athlete profile and start connecting.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Registration form
          Container(
            padding: const EdgeInsets.all(24.0),
            child: _buildRegistrationForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                hintText: 'Create a password',
                isPassword: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: state.status == AuthStatus.loading ? null : _handleRegister,
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
                        'Create Account',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              Divider(color: Colors.grey[300]),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  debugPrint("🔧 Development testing registration");
                  // Fill form with test data if empty
                  if (_emailController.text.isEmpty) {
                    _emailController.text = 'test.user@example.com';
                    _passwordController.text = 'password123';
                  }
                  // Skip verification and go directly to home page
                  context.go(RouteConstants.home, extra: {'devBypass': true});
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
                    Text('Dev Registration (Bypass)'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go(RouteConstants.login),
                child: const Text('Already have an account? Sign in'),
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
        );
      },
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

  Widget _buildAthleteStatusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Athlete Status',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xFF0A1F44),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<AthleteStatus>(
                title: const Text('Current'),
                value: AthleteStatus.current,
                groupValue: _athleteStatus,
                onChanged: (AthleteStatus? value) {
                  if (value != null) {
                    setState(() {
                      _athleteStatus = value;
                    });
                  }
                },
              ),
            ),
            Expanded(
              child: RadioListTile<AthleteStatus>(
                title: const Text('Former'),
                value: AthleteStatus.former,
                groupValue: _athleteStatus,
                onChanged: (AthleteStatus? value) {
                  if (value != null) {
                    setState(() {
                      _athleteStatus = value;
                    });
                  }
                },
              ),
            ),
          ],
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
