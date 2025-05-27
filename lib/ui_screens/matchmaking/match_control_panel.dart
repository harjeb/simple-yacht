import 'package:flutter/material.dart';

class MatchControlPanel extends StatelessWidget {
  final bool isInQueue;
  final VoidCallback? onStartMatching;
  final VoidCallback? onCancelMatching;
  final VoidCallback? onViewHistory;
  final VoidCallback? onViewStats;

  const MatchControlPanel({
    Key? key,
    required this.isInQueue,
    this.onStartMatching,
    this.onCancelMatching,
    this.onViewHistory,
    this.onViewStats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '匹配控制',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (!isInQueue) ...[
              ElevatedButton.icon(
                onPressed: onStartMatching,
                icon: const Icon(Icons.play_arrow),
                label: const Text('开始匹配'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onViewHistory,
                      icon: const Icon(Icons.history),
                      label: const Text('历史记录'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onViewStats,
                      icon: const Icon(Icons.bar_chart),
                      label: const Text('统计数据'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: onCancelMatching,
                icon: const Icon(Icons.stop),
                label: const Text('取消匹配'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '匹配提示：',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                '• 系统会自动寻找ELO相近的对手\n'
                '• 等待时间越长，匹配范围越大\n'
                '• 最长等待时间为2分钟',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 