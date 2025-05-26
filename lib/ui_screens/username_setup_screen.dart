import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/state_management/providers/user_providers.dart';
import 'package:myapp/generated/app_localizations.dart'; // For localization
import 'package:cloud_firestore/cloud_firestore.dart'; // For FirebaseException
import 'package:myapp/services/auth_service.dart'; // For authServiceProvider
import 'package:myapp/services/user_service.dart'; // For userAccountServiceProvider, functionsProvider
import 'package:cloud_functions/cloud_functions.dart'; // For FirebaseFunctionsException, HttpsCallable
import 'package:myapp/services/local_storage_service.dart'; // For local username storage

enum SetupMode { create, recover }

class UsernameSetupScreen extends ConsumerStatefulWidget {
  const UsernameSetupScreen({super.key});

  @override
  ConsumerState<UsernameSetupScreen> createState() =>
      _UsernameSetupScreenState();
}

class _UsernameSetupScreenState extends ConsumerState<UsernameSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _recoveryCodeController = TextEditingController(); // For recovery code
  String? _errorText;
  bool _isLoading = false;
  SetupMode _setupMode =
      SetupMode.create; // To toggle between create and recover

  @override
  void dispose() {
    _usernameController.dispose();
    _recoveryCodeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _errorText = null;
      _isLoading = true;
    });

    if (_formKey.currentState!.validate()) {
      if (_setupMode == SetupMode.create) {
        await _createNewAccount();
      } else {
        await _recoverAccount();
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createNewAccount() async {
    final enteredUsername = _usernameController.text.trim();
    final authService = ref.read(authServiceProvider);
    final currentUser = authService.currentUser;

    print("DEBUG: _createNewAccount called with username: '$enteredUsername'");
    print("DEBUG: Current user UID: ${currentUser?.uid}");

    if (currentUser == null) {
      print("DEBUG: No current user - authentication failed");
      if (mounted) {
        setState(() {
          _errorText = AppLocalizations.of(context)!.authenticationError;
          _isLoading = false;
        });
      }
      return;
    }

    final userAccountService = ref.read(userAccountServiceProvider);
    final localStorageService = LocalStorageService(); // Create local storage service
    
    try {
      print("DEBUG: Attempting to create user in Firebase...");
      // 1. Try to create user in Firebase
      final userProfile = await userAccountService.createNewUser(
        userId: currentUser.uid,
        username: enteredUsername,
      );
      print("DEBUG: User creation result: ${userProfile != null ? 'SUCCESS' : 'FAILED'}");
      
      if (userProfile != null) {
        // 2. Also save username to local storage as backup
        try {
          await localStorageService.saveUsername(enteredUsername);
          print("Username saved to both Firebase and local storage: $enteredUsername");
        } catch (localError) {
          // Even if local storage fails, we continue since Firebase save succeeded
          print("Warning: Username saved to Firebase but failed to save locally: $localError");
        }
        
        ref.refresh(usernameProvider);
        ref.refresh(userProfileProvider);
        // GoRouter redirect should handle navigation
      } else {
        if (mounted) {
          setState(() {
            _errorText = AppLocalizations.of(context)!.failedToSaveUsername;
          });
        }
        print("Failed to save username to Firebase: userProfile is null");
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        setState(() {
          if (e.code == 'not-found') {
            _errorText =
                AppLocalizations.of(
                  context,
                )!.firestoreDatabaseNotConfiguredError;
          } else if (e.code == 'permission-denied') {
            // More specific error for permission denied
            _errorText = "权限被拒绝：请检查用户名格式是否正确，或稍后重试。";
            print("PERMISSION_DENIED error details: ${e.message}");
          } else {
            _errorText =
                AppLocalizations.of(
                  context,
                )!.failedToSaveUsername; // Or a more specific error based on e.code
          }
        });
      }
      print("FirebaseException in _createNewAccount: ${e.code} - ${e.message}");
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorText = AppLocalizations.of(context)!.genericError;
        });
      }
      print("Error in _createNewAccount: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _recoverAccount() async {
    final recoveryCode = _recoveryCodeController.text.trim();
    final userAccountService = ref.read(userAccountServiceProvider);
    final authService = ref.read(authServiceProvider);
    final functions = ref.read(
      functionsProvider,
    ); // Get FirebaseFunctions instance

    try {
      final userId = await userAccountService.getUserIdByTransferCode(
        recoveryCode,
      );
      if (userId == null) {
        if (mounted) {
          setState(() {
            _errorText =
                AppLocalizations.of(
                  context,
                )!.recoveryCodeInvalid; // Add this localization
          });
        }
        return;
      }

      // Call Cloud Function to get custom token
      final HttpsCallable callable = functions.httpsCallable(
        'generateCustomAuthToken',
      );
      final response = await callable.call<Map<String, dynamic>>({
        'uid': userId,
      });
      final customToken = response.data['token'] as String?;

      if (customToken == null) {
        if (mounted) {
          setState(() {
            _errorText =
                AppLocalizations.of(
                  context,
                )!.recoveryFailedError; // Add this localization
          });
        }
        return;
      }

      // Sign in with custom token
      final user = await authService.signInWithCustomToken(customToken);
      if (user != null) {
        ref.refresh(usernameProvider);
        ref.refresh(userProfileProvider);
        // GoRouter redirect should handle navigation
      } else {
        if (mounted) {
          setState(() {
            _errorText =
                AppLocalizations.of(
                  context,
                )!.recoverySignInFailed; // Add this localization
          });
        }
      }
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        setState(() {
          _errorText =
              "${AppLocalizations.of(context)!.recoveryFailedError}: ${e.message}";
        });
      }
      print(
        "FirebaseFunctionsException in _recoverAccount: ${e.code} - ${e.message}",
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorText = AppLocalizations.of(context)!.genericError;
        });
      }
      print("Error in _recoverAccount: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _setupMode == SetupMode.create
              ? localizations.usernameSetupTitle
              : localizations.accountRecoveryTitle,
        ), // Add accountRecoveryTitle
        automaticallyImplyLeading: false,
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
                if (_setupMode == SetupMode.create) ...[
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
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return localizations.usernameValidationError;
                      }
                      if (value.trim().length < 3) {
                        return localizations.usernameTooShortError;
                      }
                      if (value.trim().length > 15) {
                        return localizations.usernameTooLongError;
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    enabled: !_isLoading,
                  ),
                ] else ...[
                  // Recovery Mode UI
                  Text(
                    localizations
                        .enterRecoveryCodePrompt, // Add this localization
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _recoveryCodeController,
                    decoration: InputDecoration(
                      labelText:
                          localizations
                              .recoveryCodeLabel, // Add this localization
                      hintText:
                          localizations
                              .recoveryCodeHint, // Add this localization (e.g., 18 alphanumeric characters)
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return localizations
                            .recoveryCodeCannotBeEmpty; // Add this
                      }
                      if (value.trim().length != 18) {
                        // Basic length check
                        return localizations
                            .recoveryCodeInvalidLength; // Add this
                      }
                      // Add regex for alphanumeric if desired
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    enabled: !_isLoading,
                  ),
                ],
                if (_errorText != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                            _setupMode == SetupMode.create
                                ? localizations.saveButtonLabel
                                : localizations
                                    .recoverAccountButtonLabel, // Add this
                            style: const TextStyle(fontSize: 18),
                          ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () {
                            setState(() {
                              _setupMode =
                                  _setupMode == SetupMode.create
                                      ? SetupMode.recover
                                      : SetupMode.create;
                              _errorText =
                                  null; // Clear error when switching modes
                              _formKey.currentState
                                  ?.reset(); // Reset form validation state
                            });
                          },
                  child: Text(
                    _setupMode == SetupMode.create
                        ? localizations
                            .switchToRecoverAccountLabel // Add this
                        : localizations.switchToCreateAccountLabel, // Add this
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
