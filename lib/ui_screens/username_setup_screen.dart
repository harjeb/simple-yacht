import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/state_management/providers/user_providers.dart';
import 'package:myapp/generated/app_localizations.dart'; // For localization
import 'package:cloud_firestore/cloud_firestore.dart'; // For FirebaseException
// import 'package:myapp/services/auth_service.dart'; // No longer needed for provider here
import 'package:myapp/services/user_service.dart'; // For userAccountServiceProvider, functionsProvider
import 'package:cloud_functions/cloud_functions.dart'; // For FirebaseFunctionsException, HttpsCallable
import 'package:myapp/services/local_storage_service.dart'; // For local username storage
import 'dart:math' as math;
import 'package:myapp/state_management/providers/service_providers.dart'; // Import new service providers

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

    print("=== DEBUG: 开始创建新账户 ===");
    print("DEBUG: 输入的用户名: '$enteredUsername'");
    print("DEBUG: 用户名长度: ${enteredUsername.length}");
    print("DEBUG: 当前用户 UID: ${currentUser?.uid}");
    print("DEBUG: 当前用户是否匿名: ${currentUser?.isAnonymous}");
    print("DEBUG: 当前用户邮箱: ${currentUser?.email}");
    print("DEBUG: 当前用户 providerId: ${currentUser?.providerData.map((p) => p.providerId).toList()}");
    print("DEBUG: 当前用户 token 是否可用: ${currentUser != null}");
    
    // 检查用户的 ID token
    if (currentUser != null) {
      try {
        final idToken = await currentUser.getIdToken();
        if (idToken != null) {
          print("DEBUG: 成功获取 ID token，长度: ${idToken.length}");
          print("DEBUG: ID token 前50字符: ${idToken.substring(0, math.min(50, idToken.length))}...");
        } else {
          print("DEBUG: ID token 为 null");
        }
      } catch (e) {
        print("DEBUG: 获取 ID token 失败: $e");
      }
    }

    if (currentUser == null) {
      print("DEBUG: 错误 - 没有当前用户，认证失败");
      if (mounted) {
        setState(() {
          _errorText = AppLocalizations.of(context)!.authenticationError;
          _isLoading = false;
        });
      }
      return;
    }

    final userAccountService = ref.read(userAccountServiceProvider);
    final localStorageService = LocalStorageService();
    
    try {
      print("DEBUG: 开始在 Firebase 中创建用户...");
      print("DEBUG: 调用 userAccountService.createNewUser");
      
      // 1. Try to create user in Firebase
      final userProfile = await userAccountService.createNewUser(
        userId: currentUser.uid,
        username: enteredUsername,
      );
      
      print("DEBUG: userAccountService.createNewUser 完成");
      print("DEBUG: 用户创建结果: ${userProfile != null ? 'SUCCESS' : 'FAILED'}");
      
      if (userProfile != null) {
        print("DEBUG: 用户创建成功，开始保存到本地存储...");
        // 2. Also save username to local storage as backup
        try {
          await localStorageService.saveUsername(enteredUsername);
          print("DEBUG: 用户名已保存到 Firebase 和本地存储: $enteredUsername");
        } catch (localError) {
          // Even if local storage fails, we continue since Firebase save succeeded
          print("DEBUG: 警告 - 用户名已保存到 Firebase 但本地存储失败: $localError");
        }
        
        print("DEBUG: 刷新 providers...");
        ref.refresh(usernameProvider);
        ref.refresh(userProfileProvider);
        
        // 等待 usernameProvider 更新完成
        print("DEBUG: 等待 usernameProvider 更新...");
        try {
          final updatedUsername = await ref.read(usernameProvider.future);
          print("DEBUG: usernameProvider 更新完成，新用户名: $updatedUsername");
          
          if (updatedUsername != null && updatedUsername.isNotEmpty) {
            print("DEBUG: 用户名验证成功，准备跳转...");
            // 手动触发路由重新评估
            if (mounted && context.mounted) {
              print("DEBUG: 手动跳转到主页面...");
              context.go('/');
            }
          } else {
            print("DEBUG: 警告 - usernameProvider 更新后仍为空");
          }
        } catch (e) {
          print("DEBUG: 等待 usernameProvider 更新时出错: $e");
          // 即使出错，也尝试跳转，让路由系统处理
          if (mounted && context.mounted) {
            context.go('/');
          }
        }
        
        print("DEBUG: 账户创建流程完成");
      } else {
        print("DEBUG: 错误 - 保存用户名到 Firebase 失败: userProfile 为 null");
        if (mounted) {
          setState(() {
            _errorText = AppLocalizations.of(context)!.failedToSaveUsername;
          });
        }
      }
    } on FirebaseException catch (e) {
      print("=== DEBUG: FirebaseException 捕获 ===");
      print("DEBUG: 错误代码: ${e.code}");
      print("DEBUG: 错误消息: ${e.message}");
      print("DEBUG: 错误插件: ${e.plugin}");
      print("DEBUG: 错误详情: ${e.toString()}");
      
      if (mounted) {
        setState(() {
          if (e.code == 'not-found') {
            _errorText = AppLocalizations.of(context)!.firestoreDatabaseNotConfiguredError;
            print("DEBUG: 设置错误文本为数据库未配置错误");
          } else if (e.code == 'permission-denied') {
            // More specific error for permission denied
            _errorText = "权限被拒绝：请检查用户名格式是否正确，或稍后重试。详细错误: ${e.message}";
            print("DEBUG: 权限被拒绝错误详情: ${e.message}");
          } else {
            _errorText = "保存用户名失败 (${e.code}): ${e.message}";
            print("DEBUG: 设置通用 Firebase 错误文本");
          }
        });
      }
    } catch (e) {
      print("=== DEBUG: 通用异常捕获 ===");
      print("DEBUG: 异常类型: ${e.runtimeType}");
      print("DEBUG: 异常消息: $e");
      print("DEBUG: 异常堆栈跟踪:");
      print(StackTrace.current);
      
      if (mounted) {
        setState(() {
          _errorText = "发生未知错误: $e";
        });
      }
    } finally {
      print("DEBUG: _createNewAccount 方法结束，设置 loading 为 false");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _recoverAccount() async {
    final recoveryCode = _recoveryCodeController.text.trim();
    final functions = ref.read(functionsProvider);

    print("=== DEBUG: 开始账号恢复 (数据迁移方案) ===");
    print("DEBUG: 恢复代码: '$recoveryCode'");

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorText = null;
      });
    }

    try {
      print("DEBUG: 调用 Cloud Function 进行数据迁移...");
      
      // 调用新的数据迁移恢复函数
      final HttpsCallable callable = functions.httpsCallable('recoverAccountByTransferCode');
      final response = await callable.call<Map<String, dynamic>>({
        'transferCode': recoveryCode
      });
      
      print("DEBUG: Cloud Function 调用成功");
      print("DEBUG: 响应数据: ${response.data}");
      print("DEBUG: 响应数据类型: ${response.data.runtimeType}");
      print("DEBUG: 响应数据完整内容: ${response.data.toString()}");
      print("DEBUG: success 字段: ${response.data['success']}");
      print("DEBUG: success 字段类型: ${response.data['success'].runtimeType}");
      print("DEBUG: requiresAuthentication 字段: ${response.data['requiresAuthentication']}");
      print("DEBUG: requiresAuthentication 字段类型: ${response.data['requiresAuthentication'].runtimeType}");
      print("DEBUG: userData 字段: ${response.data['userData']}");
      
      if (response.data['success'] == true) {
        print("DEBUG: 进入 success == true 分支");
        final userData = response.data['userData'] as Map<String, dynamic>;
        final username = userData['username'] as String;
        print("DEBUG: 提取的用户名: $username");
        
        // 检查是否需要认证
        print("DEBUG: 检查 requiresAuthentication 字段...");
        if (response.data['requiresAuthentication'] == true) {
          print("DEBUG: requiresAuthentication == true，需要认证，先进行匿名登录");
          
          // 确保用户已认证（匿名登录）
          final authService = ref.read(authServiceProvider);
          print("DEBUG: 当前用户状态: ${authService.currentUser}");
          
          if (authService.currentUser == null) {
            print("DEBUG: 用户未登录，进行匿名登录");
            await authService.signInAnonymously();
            print("DEBUG: 匿名登录完成，新用户ID: ${authService.currentUser?.uid}");
          } else {
            print("DEBUG: 用户已登录，用户ID: ${authService.currentUser?.uid}");
          }
          
          print("DEBUG: 用户已认证，重新调用函数进行数据迁移");
          
          // 重新调用函数进行实际的数据迁移
          final migrationResponse = await callable.call<Map<String, dynamic>>({
            'transferCode': recoveryCode
          });
          
          print("DEBUG: 数据迁移响应: ${migrationResponse.data}");
          
          if (migrationResponse.data['success'] == true) {
            print("DEBUG: 数据迁移成功 - 用户名: $username");
            
            // 强制刷新用户数据
            print("DEBUG: 强制刷新用户相关的 providers");
            ref.invalidate(usernameProvider);
            ref.invalidate(userProfileProvider);
            ref.invalidate(authStateChangesProvider);
            
            // 等待数据同步
            print("DEBUG: 等待数据同步...");
            await Future.delayed(Duration(seconds: 2));
            
            // 验证数据是否已同步
            try {
              final newUsername = await ref.read(usernameProvider.future);
              print("DEBUG: 验证用户名同步结果: $newUsername");
              if (newUsername == null || newUsername.isEmpty) {
                print("DEBUG: 警告 - 用户名同步失败，但继续流程");
              }
            } catch (e) {
              print("DEBUG: 验证用户名时出错: $e");
            }
          } else {
            throw Exception('数据迁移失败: ${migrationResponse.data['message'] ?? '未知错误'}');
          }
        } else {
          print("DEBUG: 不需要认证或数据迁移已完成 - 用户名: $username");
        }
        
        // 刷新所有相关的 providers
        if (mounted) {
          print("DEBUG: 开始刷新 providers");
          ref.refresh(usernameProvider);
          ref.refresh(userProfileProvider);
          
          // 再次验证数据状态
          print("DEBUG: 验证最终数据状态...");
          try {
            final finalUsername = await ref.read(usernameProvider.future);
            final hasUsername = ref.read(hasUsernameProvider);
            print("DEBUG: 最终用户名: $finalUsername");
            print("DEBUG: hasUsername 状态: $hasUsername");
          } catch (e) {
            print("DEBUG: 验证最终数据状态时出错: $e");
          }
          
          // 显示成功消息
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('账号恢复成功！欢迎回来，$username'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          
          print("DEBUG: 等待 providers 更新...");
          
          // 等待 providers 更新后跳转到主界面
          await Future.delayed(Duration(milliseconds: 3000)); // 增加等待时间
          
          if (mounted && context.mounted) {
            print("DEBUG: 准备跳转到主界面");
            print("DEBUG: 当前路由: ${GoRouter.of(context).routerDelegate.currentConfiguration}");
            context.go('/');
            print("DEBUG: 跳转命令已执行");
          } else {
            print("DEBUG: 无法跳转 - mounted: $mounted, context.mounted: ${context.mounted}");
          }
        } else {
          print("DEBUG: Widget 未挂载，无法刷新 providers");
        }
        
        print("DEBUG: 账号恢复流程完成");
      } else {
        print("DEBUG: Cloud Function 返回失败");
        throw Exception('恢复失败: ${response.data['message'] ?? '未知错误'}');
      }
      
    } on FirebaseFunctionsException catch (e) {
      print("=== DEBUG: FirebaseFunctionsException 捕获 ===");
      print("DEBUG: 错误代码: ${e.code}");
      print("DEBUG: 错误消息: ${e.message}");
      print("DEBUG: 错误详情: ${e.details}");
      
      if (mounted) {
        setState(() {
          switch (e.code) {
            case 'not-found':
              _errorText = '恢复代码无效，请检查后重试';
              break;
            case 'already-exists':
              _errorText = '此恢复代码已被使用，或当前账号已有数据';
              break;
            case 'unauthenticated':
              _errorText = '认证失败，请重启应用后重试';
              break;
            default:
              _errorText = "恢复失败: ${e.message}";
          }
        });
      }
    } catch (e) {
      print("=== DEBUG: 通用异常捕获 ===");
      print("DEBUG: 异常类型: ${e.runtimeType}");
      print("DEBUG: 异常消息: $e");
      print("DEBUG: 异常堆栈: ${StackTrace.current}");
      
      if (mounted) {
        setState(() {
          _errorText = "恢复失败: $e";
        });
      }
    } finally {
      print("DEBUG: _recoverAccount 方法结束");
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
