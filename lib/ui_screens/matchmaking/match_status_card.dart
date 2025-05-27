import 'package:flutter/material.dart';
import '../../models/matchmaking_queue.dart';

class MatchStatusCard extends StatelessWidget {
  final MatchmakingQueue? matchmakingStatus;
  final VoidCallback? onCancel;

  const MatchStatusCard({
    Key? key,
    this.matchmakingStatus,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (matchmakingStatus == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('未在匹配队列中'),
        ),
      );
    }

    final status = matchmakingStatus!;
    final waitTime = DateTime.now().difference(status.joinedAt);
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '匹配状态',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                _buildStatusIcon(status.status),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatusText(status.status),
            const SizedBox(height: 8),
            Text(
              '等待时间: ${_formatDuration(waitTime)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'ELO评分: ${status.eloRating}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (status.status == MatchmakingStatus.searching) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onCancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('取消匹配'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(MatchmakingStatus status) {
    switch (status) {
      case MatchmakingStatus.searching:
        return const CircularProgressIndicator();
      case MatchmakingStatus.matched:
        return const Icon(Icons.check_circle, color: Colors.green, size: 32);
      case MatchmakingStatus.cancelled:
        return const Icon(Icons.cancel, color: Colors.red, size: 32);
      case MatchmakingStatus.timeout:
        return const Icon(Icons.access_time, color: Colors.orange, size: 32);
    }
  }

  Widget _buildStatusText(MatchmakingStatus status) {
    String text;
    Color color;
    
    switch (status) {
      case MatchmakingStatus.searching:
        text = '正在寻找对手...';
        color = Colors.blue;
        break;
      case MatchmakingStatus.matched:
        text = '找到对手！准备开始游戏';
        color = Colors.green;
        break;
      case MatchmakingStatus.cancelled:
        text = '匹配已取消';
        color = Colors.red;
        break;
      case MatchmakingStatus.timeout:
        text = '匹配超时';
        color = Colors.orange;
        break;
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}
