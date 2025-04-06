import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../bloc/auth_bloc.dart' as app_auth;
import 'package:supabase_flutter/supabase_flutter.dart';

class PasswordResetFormPage extends StatefulWidget {
  final String token;
  
  const PasswordResetFormPage({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  _PasswordResetFormPageState createState() => _PasswordResetFormPageState();
}

class _PasswordResetFormPageState extends State<PasswordResetFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late String _token;

  @override
  void initState() {
    super.initState();
    _token = widget.token;
    
    // If the token is empty, try to extract it from the URL
    if (_token.isEmpty || _token == 'recovery') {
      _extractTokenFromUrl();
    }
  }
  
  void _extractTokenFromUrl() {
    try {
      debugPrint("🔍 Attempting to extract token from URL");
      // Supabase provides a helper to extract tokens from URLs
      final Uri uri = Uri.base;
      
      if (uri.queryParameters.containsKey('token')) {
        _token = uri.queryParameters['token']!;
        debugPrint("✅ Successfully extracted token from URL query parameters");
      } else if (uri.fragment.contains('token=')) {
        // Sometimes the token is in the fragment
        final params = Uri.parse('?${uri.fragment.replaceFirst('#', '')}').queryParameters;
        if (params.containsKey('token')) {
          _token = params['token']!;
          debugPrint("✅ Successfully extracted token from URL fragment");
        }
      }
      
      if (_token.isNotEmpty) {
        debugPrint("🔑 Token extracted successfully");
      }
    } catch (e) {
      debugPrint("❌ Error extracting token from URL: $e");
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _submitNewPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No reset token found. Please try again or request a new reset link.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      context.read<app_auth.AuthBloc>().add(
            app_auth.AuthNewPasswordSubmitted(
              password: _passwordController.text,
              token: _token,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set New Password'),
      ),
      body: BlocConsumer<app_auth.AuthBloc, app_auth.AuthState>(
        listener: (context, state) {
          if (state.status == app_auth.AuthStatus.loading) {
            setState(() => _isLoading = true);
          } else {
            setState(() => _isLoading = false);
          }

          if (state.status == app_auth.AuthStatus.passwordResetSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password reset successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }

          if (state.status == app_auth.AuthStatus.unauthenticated && state.errorMessage == null) {
            // Only redirect if we're unauthenticated without an error message
            // This means we've successfully reset the password
            context.go(RouteConstants.login);
          }

          if (state.status == app_auth.AuthStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Create a new password',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your new password must be at least 8 characters long.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  if (_token.isEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: const Text(
                        'Warning: No reset token was found. This may happen if you opened the link incorrectly. Please check your email and click the link directly.',
                        style: TextStyle(color: Colors.amber, fontSize: 14),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: _validatePassword,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureConfirmPassword,
                    validator: _validateConfirmPassword,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitNewPassword,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('SET NEW PASSWORD'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _isLoading 
                        ? null 
                        : () => context.go(RouteConstants.login),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 