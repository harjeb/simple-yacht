import 'package:flutter/material.dart';
import '../../models/matchmaking_queue.dart';
import '../../models/game_enums.dart';

class MatchInfoPanel extends StatelessWidget {
  final MatchmakingQueue? matchmakingStatus;
  final int currentEloRange;
  final int queuePosition;
  final int onlinePlayersCount;

  const MatchInfoPanel({
    Key? key,
    this.matchmakingStatus,
    required this.currentEloRange,
    required this.queuePosition,
    required this.onlinePlayersCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '匹配信息',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              '队列位置',
              queuePosition > 0 ? '#$queuePosition' : '未知',
              Icons.queue,
            ),
            _buildInfoRow(
              context,
              '在线玩家',
              '$onlinePlayersCount 人',
              Icons.people,
            ),
            if (matchmakingStatus != null) ...[
              _buildInfoRow(
                context,
                '当前ELO范围',
                '±$currentEloRange',
                Icons.trending_up,
              ),
              _buildInfoRow(
                context,
                '目标ELO',
                '${matchmakingStatus!.eloRating - currentEloRange} - ${matchmakingStatus!.eloRating + currentEloRange}',
                Icons.gps_fixed,
              ),
            ],
            const SizedBox(height: 8),
            _buildMatchmakingProgress(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchmakingProgress(BuildContext context) {
    if (matchmakingStatus == null || matchmakingStatus!.status != MatchmakingStatus.searching) {
      return const SizedBox.shrink();
    }

    final waitTime = DateTime.now().difference(matchmakingStatus!.joinedAt);
    final maxWaitTime = const Duration(minutes: 2);
    final progress = (waitTime.inMilliseconds / maxWaitTime.inMilliseconds).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          '匹配进度',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            progress < 0.8 ? Colors.blue : Colors.orange,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          progress >= 1.0 ? '即将超时' : '范围每30秒扩大100分',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: progress >= 0.8 ? Colors.orange : Colors.grey[600],
          ),
        ),
      ],
    );
  }
} 