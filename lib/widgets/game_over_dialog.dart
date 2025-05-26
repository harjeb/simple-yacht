import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/state_management/providers/game_providers.dart'; // 假设游戏状态提供者在这里
// import 'package:myapp/l10n/app_localizations.dart'; // 如果需要本地化

class GameOverDialog extends ConsumerWidget {
  final int finalScore;

  const GameOverDialog({
    super.key,
    required this.finalScore,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final localizations = AppLocalizations.of(context)!; // 如果需要本地化

    return AlertDialog(
      title: const Text(
        '游戏结束!', // localizations.gameOverTitle,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🎉 恭喜你完成了游戏! 🎉', // localizations.gameOverCongratulations,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          Text(
            '你的最终得分是:', // localizations.yourFinalScore,
            style: TextStyle(fontSize: 16),
          ),
          Text(
            '$finalScore',
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 20),
          // 可以添加更多庆祝性视觉元素，例如一个简单的动画或图片
          // Image.asset('assets/images/celebration.png', height: 100),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton(
          onPressed: () {
            // 重置游戏状态
            ref.read(gameStateProvider.notifier).resetAndStartNewGame();
            // 关闭弹窗
            Navigator.of(context).pop();
            // 可选：导航回主屏幕或其他地方
            // context.go('/');
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
          child: const Text(
            '重新开始', // localizations.resetGameButton,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}

// 辅助函数，用于在游戏屏幕上显示此对话框
void showGameOverDialog(BuildContext context, int score) {
  showDialog(
    context: context,
    barrierDismissible: false, // 用户必须点击按钮才能关闭
    builder: (BuildContext dialogContext) {
      return GameOverDialog(finalScore: score);
    },
  );
}