import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_ticketing/utils/utils.dart';
import 'package:sports_ticketing/widgets/text_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PasswordReset extends ConsumerStatefulWidget {
  const PasswordReset({super.key});

  @override
  ConsumerState<PasswordReset> createState() => _PasswordResetState();
}

class _PasswordResetState extends ConsumerState<PasswordReset> {
  final TextEditingController _emailController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void resetPassword(String email, BuildContext context) async {
    if (email.isEmpty) {
      showSnackBar(context, 'Email can\'t be empty.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      showSnackBar(
          context, 'Password reset email sent. Please check your inbox.');
      _emailController.text = '';
      Navigator.pop(context);
    } catch (error) {
      showSnackBar(context, error.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Reset'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16.0),
            const Text(
              'Please enter your email to reset your password.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16.0),
            FormInputField(
              textController: _emailController,
              hintText: 'Email',
              obscureText: false,
              prefixIcon: const Icon(Icons.keyboard),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () => resetPassword(_emailController.text.trim(), context),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
              ),
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
