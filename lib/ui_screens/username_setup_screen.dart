import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_yacht/state_management/providers/user_providers.dart';
import 'package:simple_yacht/generated/app_localizations.dart'; // For localization
import 'package:cloud_firestore/cloud_firestore.dart'; // For FirebaseException
import 'package:simple_yacht/services/auth_service.dart'; // For authStateChangesProvider
import 'package:simple_yacht/services/user_service.dart'; // For userAccountServiceProvider, functionsProvider
import 'package:cloud_functions/cloud_functions.dart'; // For FirebaseFunctionsException, HttpsCallable
import 'package:simple_yacht/services/local_storage_service.dart'; // For local username storage
import 'dart:math' as math;
import 'package:simple_yacht/state_management/providers/service_providers.dart'; // Import new service providers
import 'package:simple_yacht/core_logic/score_entry.dart'; // For ScoreEntry
import 'package:simple_yacht/state_management/providers/personal_best_score_provider.dart'; // For personalBestScoreProvider

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
      print("DEBUG: 原始响应数据: ${response.data}"); // 更详细的原始数据日志
      
      if (response.data['success'] == true) {
        print("DEBUG: 进入 success == true 分支");
        Map<String, dynamic> finalUserData = response.data['userData'] as Map<String, dynamic>;
        print("DEBUG: finalUserData 内容: $finalUserData"); // 打印 finalUserData
        String recoveredUsername = finalUserData['username'] as String;
        final String? recoveredUid = finalUserData['uid'] as String?; // 获取 UID

        print("DEBUG: 初始提取的用户名: $recoveredUsername, UID: $recoveredUid");
        
        // 提取 personalBestScore 和 personalBestScoreTimestamp
        final dynamic rawScoreValue = finalUserData['personalBestScore'];
        final dynamic rawTimestampData = finalUserData['personalBestScoreTimestamp'];

        print("DEBUG: 从 finalUserData 提取的 rawScoreValue: $rawScoreValue");
        print("DEBUG: 从 finalUserData 提取的 rawTimestampData: $rawTimestampData");

        ScoreEntry? recoveredPersonalBestScore;

        if (rawScoreValue is int && rawTimestampData != null) {
          try {
            Timestamp firestoreTimestamp;
            if (rawTimestampData is Map && rawTimestampData.containsKey('_seconds') && rawTimestampData.containsKey('_nanoseconds')) {
              final int seconds = rawTimestampData['_seconds'] as int;
              final int nanoseconds = rawTimestampData['_nanoseconds'] as int;
              firestoreTimestamp = Timestamp(seconds, nanoseconds);
              print("DEBUG: 从 _seconds 和 _nanoseconds 构建 Timestamp: $firestoreTimestamp");
            } else if (rawTimestampData is Timestamp) {
              firestoreTimestamp = rawTimestampData;
              print("DEBUG: rawTimestampData 已经是 Timestamp 对象: $firestoreTimestamp");
            } else {
              throw Exception("无法识别的时间戳格式: $rawTimestampData");
            }

            recoveredPersonalBestScore = ScoreEntry(
              username: recoveredUsername, // 使用已恢复的用户名
              score: rawScoreValue,
              timestamp: firestoreTimestamp.toDate(),
            );
            print("DEBUG: 成功创建 ScoreEntry: ${recoveredPersonalBestScore.toJson()}");
          } catch (e) {
            print("DEBUG: 创建 ScoreEntry 时出错: $e");
            print("DEBUG: 出错时的 rawScoreValue: $rawScoreValue, rawTimestampData: $rawTimestampData");
          }
        } else {
          print("DEBUG: Cloud Function 返回的 personalBestScore 不是 int 或 personalBestScoreTimestamp 为 null。");
          if (rawScoreValue != null) print("DEBUG: rawScoreValue 类型: ${rawScoreValue.runtimeType}");
          if (rawTimestampData != null) print("DEBUG: rawTimestampData 类型: ${rawTimestampData.runtimeType}");
        }

        // 检查是否需要认证
        if (response.data['requiresAuthentication'] == true && recoveredUid != null) {
          print("DEBUG: 需要认证，先进行匿名登录或自定义令牌登录");
          
          final authService = ref.read(authServiceProvider);
          // 理论上，如果 recoverAccountByTransferCode 返回了 UID，我们应该用这个 UID 生成自定义令牌并登录
          // 但当前 Cloud Function 的逻辑是，如果未认证，它只返回数据，不进行迁移。
          // 如果已认证，它会进行迁移。
          // 此处的逻辑需要与 Cloud Function 的实际行为对齐。
          // 假设如果 requiresAuthentication 为 true，则表示之前未认证，现在需要客户端处理认证和后续的数据保存。

          // 简化：如果需要认证，我们期望客户端已经通过某种方式（如匿名登录）获得了 currentUser
          // 并且 Cloud Function 在第二次调用时（已认证）会完成数据迁移。
          // 此处的逻辑主要处理 Cloud Function 返回的数据。

          if (authService.currentUser == null) {
            print("DEBUG: 进行匿名登录 (作为后备)"); // 或者这里应该处理自定义令牌登录
            await authService.signInAnonymously();
            print("DEBUG: 匿名登录完成");
          }
          
          // 检查widget状态
          if (!mounted) {
            print("DEBUG: Widget已销毁，停止处理");
            return;
          }
          
          // 如果是 requiresAuthentication == true 的情况，Cloud Function 第一次调用只返回数据
          // 客户端需要再次调用（在认证后）来完成迁移，或者客户端自行处理数据保存。
          // 根据当前 Cloud Function 的实现，如果未认证，它不会执行迁移。
          // 因此，如果 requiresAuthentication 为 true，我们需要在这里保存数据。
          
          print("DEBUG: 重新调用函数进行数据迁移 (如果需要，或客户端自行处理)");
          // 这里的逻辑可能需要调整，取决于 Cloud Function 的确切行为和客户端的认证策略
          // 假设如果 requiresAuthentication 为 true，我们已经获得了需要保存的数据。
          // Cloud Function 的第二次调用（已认证）会处理服务器端迁移。
        }
        
        // 检查widget状态
        if (!mounted) {
          print("DEBUG: Widget已销毁，停止处理");
          return;
        }

        // 1. 将用户名和最高分显式保存到本地存储
        final localStorageService = ref.read(localStorageServiceProvider);
        try {
          print("DEBUG: 尝试保存用户名 '$recoveredUsername' 到本地存储...");
          await localStorageService.saveUsername(recoveredUsername);
          print("DEBUG: 用户名 '$recoveredUsername' 已成功保存到本地存储。");

          if (recoveredPersonalBestScore != null) {
            print("DEBUG: 尝试为用户 '$recoveredUsername' 保存最高分到本地存储: ${recoveredPersonalBestScore.toJson()}");
            await localStorageService.saveSpecificUserPersonalBest(recoveredUsername, recoveredPersonalBestScore);
            print("DEBUG: 最高分已为用户 '$recoveredUsername' 保存到本地存储。");
          } else {
            print("DEBUG: 没有最高分数据可为用户 '$recoveredUsername' 保存 (recoveredPersonalBestScore is null)。");
            // 可选：如果需要，可以在这里清除该用户本地的旧最高分
            // await localStorageService.clearSpecificUserPersonalBest(recoveredUsername);
            print("DEBUG: 跳过为用户 '$recoveredUsername' 保存最高分，因为 recoveredPersonalBestScore 为 null。");
          }

        } catch (e) {
          print("DEBUG: 保存用户名或最高分到本地存储失败: $e");
        }
        
        // 2. 刷新providers
        print("DEBUG: 刷新 providers");
        // ref.invalidate(userProvider); // userProvider 未定义，且 usernameProvider 和 userProfileProvider 已通过 refresh 处理
        ref.refresh(usernameProvider); // 确保 usernameProvider 先刷新
        ref.refresh(personalBestScoreProvider); // 然后刷新 personalBestScoreProvider
        ref.refresh(userProfileProvider); // 也刷新 userProfileProvider
        
        // 显示成功消息
        if (mounted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('账号恢复成功！欢迎回来，$recoveredUsername'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        
        // 等待一下然后跳转
        await Future.delayed(const Duration(milliseconds: 1000));
        
        // 最终检查并跳转
        if (mounted && context.mounted) {
          print("DEBUG: 跳转到主界面");
          context.go('/');
          print("DEBUG: 跳转命令已执行");
        } else {
          print("DEBUG: 无法跳转 - widget已销毁");
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
