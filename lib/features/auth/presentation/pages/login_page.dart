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
        if (state.status == AuthStatus.authenticated) {
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
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          // Add dev login button
          const SizedBox(height: 12),
          Divider(color: Colors.grey[300]),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              print("Dev login clicked - direct navigation bypass");
              try {
                // Skip the entire auth flow and navigate directly to home
                // Pass devBypass parameter to let the router know this is a development bypass
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
          const SizedBox(height: 16),
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
          // Add connection test button
          OutlinedButton(
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Testing Supabase connection...'),
                  duration: Duration(seconds: 1),
                ),
              );
              
              try {
                // Use Supabase client directly for testing
                final client = SupabaseConfig.client;
                try {
                  // Simple test query that will likely fail, but shows connection works
                  await client.from('_dummy_test')
                      .select('*')
                      .limit(1)
                      .maybeSingle();
                      
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Supabase connection successful!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  // Even a "table not found" error means the connection works
                  if (e.toString().contains('does not exist') || 
                      e.toString().contains('not found')) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Supabase connection successful! (Table not found but connection works)'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    debugPrint('✅ Connection works! Normal error: $e');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Supabase connection failed: ${e.toString().substring(0, math.min(100, e.toString().length))}...'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    debugPrint('❌ Connection test error: $e');
                  }
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error testing connection: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: Colors.grey[400]!),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi, size: 16),
                SizedBox(width: 8),
                Text('Test Supabase Connection'),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          // Add policy test button
          OutlinedButton(
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Testing database policies...'),
                  duration: Duration(seconds: 1),
                ),
              );
              
              try {
                // Use Supabase client directly for testing
                final client = SupabaseConfig.client;
                
                // Test if the athletes table exists
                try {
                  await client.from('athletes')
                      .select('count(*)')
                      .limit(1);
                      
                  debugPrint('✅ Athletes table exists and is accessible');
                  
                  // Try to get policies - this requires admin rights and will likely fail
                  // but the error can tell us about permissions
                  try {
                    await client.rpc('get_policies_for_table', params: {'table_name': 'athletes'})
                        .timeout(const Duration(seconds: 3));
                  } catch (policyError) {
                    debugPrint('⚠️ Policy check error (expected): $policyError');
                    if (policyError.toString().contains('permission denied')) {
                      debugPrint('✅ Policies exist (permission denied is expected for non-admin)');
                    }
                  }
                  
                  // Check insert specifically
                  try {
                    // Create a test user - will fail but tells us about insert policy
                    final testData = {
                      'id': '00000000-0000-0000-0000-000000000000',
                      'email': 'policy.test@example.com',
                      'full_name': 'Policy Test',
                      'username': 'policytest',
                      'athlete_status': 'former',
                      'created_at': DateTime.now().toIso8601String(),
                      'updated_at': DateTime.now().toIso8601String(),
                    };
                    
                    await client.from('athletes')
                        .insert(testData)
                        .timeout(const Duration(seconds: 3));
                        
                    debugPrint('⚠️ INSERT succeeded, but should have failed (no auth)');
                  } catch (insertError) {
                    debugPrint('✅ INSERT policy check: $insertError');
                    if (insertError.toString().contains('policy')) {
                      debugPrint('✅ INSERT policy exists and is enforcing rules');
                    } else if (insertError.toString().contains('foreign key')) {
                      debugPrint('✅ INSERT policy is likely working (foreign key constraint)');
                    } else {
                      debugPrint('⚠️ INSERT policy check inconclusive');
                    }
                  }
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Database policies check completed - see logs for details'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Athletes table not accessible: ${e.toString().substring(0, math.min(100, e.toString().length))}'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  debugPrint('⚠️ Athletes table check error: $e');
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error testing policies: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: Colors.grey[400]!),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.security, size: 16),
                SizedBox(width: 8),
                Text('Test Database Policies'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Clear storage button
          OutlinedButton(
            onPressed: () async {
              try {
                debugPrint('🧹 Clearing stored auth state...');
                // Use the WebStorage directly
                await WebStorage.clearAuthData();
                
                // Also reset the AuthBloc state
                context.read<AuthBloc>().add(const AuthCheckRequested());
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Auth state cleared!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error clearing state: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: Colors.grey[400]!),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cleaning_services, size: 16),
                SizedBox(width: 8),
                Text('Reset App State'),
              ],
            ),
          ),
        ],
      ),
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
