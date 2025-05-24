import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/state_management/providers/user_providers.dart';
import 'package:myapp/generated/app_localizations.dart'; // For localization

class UsernameSetupScreen extends ConsumerStatefulWidget {
  const UsernameSetupScreen({super.key});

  @override
  ConsumerState<UsernameSetupScreen> createState() => _UsernameSetupScreenState();
}

class _UsernameSetupScreenState extends ConsumerState<UsernameSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _saveUsername() async {
    setState(() {
      _errorText = null; // Clear previous error
    });

    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim();
      if (username.isEmpty) {
        setState(() {
          // This case should ideally be caught by the validator,
          // but as a fallback or for more specific messaging.
          _errorText = AppLocalizations.of(context)!.usernameCannotBeEmpty;
        });
        return;
      }

      // Simulate a slight delay if needed, or directly save
      // await Future.delayed(const Duration(milliseconds: 300));

      await ref.read(userServiceProvider).saveUsername(username);

      if (mounted) {
        // Navigate to home screen after saving
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.usernameSetupTitle),
        automaticallyImplyLeading: false, // No back button
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  localizations.usernameSetupPrompt,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: localizations.usernameLabel,
                    hintText: localizations.usernameHint,
                    border: const OutlineInputBorder(),
                    errorText: _errorText,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return localizations.usernameValidationError;
                    }
                    if (value.trim().length < 3) {
                      return localizations.usernameTooShortError; // Assuming you add this
                    }
                    if (value.trim().length > 15) {
                      return localizations.usernameTooLongError; // Assuming you add this
                    }
                    // Add more validation if needed (e.g., no special characters)
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _saveUsername,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(localizations.saveButtonLabel, style: const TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}