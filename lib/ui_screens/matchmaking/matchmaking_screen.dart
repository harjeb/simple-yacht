import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/matchmaking_service.dart';
import '../../models/matchmaking_queue.dart';
import '../../models/game_enums.dart';
import 'match_status_card.dart';
import 'match_info_panel.dart';
import 'match_control_panel.dart';

class MatchmakingScreen extends StatefulWidget {
  const MatchmakingScreen({Key? key}) : super(key: key);

  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen> {
  final MatchmakingService _matchmakingService = MatchmakingService();
  StreamSubscription<MatchmakingQueue?>? _statusSubscription;
  Timer? _updateTimer;
  
  MatchmakingQueue? _currentStatus;
  int _currentEloRange = 100;
  int _queuePosition = 0;
  int _onlinePlayersCount = 0;
  int _currentEloRating = 1200;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _startStatusListener();
    _startUpdateTimer();
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _updateTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final eloRating = await _matchmakingService.getCurrentEloRating();
      setState(() {
        _currentEloRating = eloRating;
      });
    } catch (e) {
      _showErrorSnackBar('加载数据失败: $e');
    }
  }

  void _startStatusListener() {
    _statusSubscription = _matchmakingService.watchMatchmakingStatus().listen(
      (status) {
        setState(() {
          _currentStatus = status;
        });
        
        if (status?.status == MatchmakingStatus.matched) {
          _handleMatchFound();
        } else if (status?.status == MatchmakingStatus.timeout) {
          _handleMatchTimeout();
        }
      },
      onError: (error) {
        _showErrorSnackBar('监听匹配状态失败: $error');
      },
    );
  }

  void _startUpdateTimer() {
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentStatus?.status == MatchmakingStatus.searching) {
        setState(() {
          _currentEloRange = _matchmakingService.calculateCurrentEloRange(
            _currentStatus!.joinedAt,
          );
        });
        
        // 检查超时
        if (_matchmakingService.isMatchmakingTimeout(_currentStatus!.joinedAt)) {
          _handleMatchTimeout();
        }
      }
    });
  }

  Future<void> _startMatching() async {
    try {
      await _matchmakingService.joinQueue(
        playerName: '玩家', // 这里应该从用户配置获取
        gameMode: GameMode.multiplayer,
        eloRating: _currentEloRating,
      );
      
      _showSuccessSnackBar('已加入匹配队列');
    } catch (e) {
      _showErrorSnackBar('加入队列失败: $e');
    }
  }

  Future<void> _cancelMatching() async {
    try {
      await _matchmakingService.cancelMatching();
      _showSuccessSnackBar('已取消匹配');
    } catch (e) {
      _showErrorSnackBar('取消匹配失败: $e');
    }
  }

  void _handleMatchFound() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('找到对手！'),
        content: const Text('准备开始游戏...'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 这里应该导航到游戏界面
              _showSuccessSnackBar('游戏即将开始');
            },
            child: const Text('开始游戏'),
          ),
        ],
      ),
    );
  }

  void _handleMatchTimeout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('匹配超时'),
        content: const Text('未能在规定时间内找到合适的对手，请稍后再试。'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _matchmakingService.leaveQueue();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showMatchHistory() {
    // 这里应该导航到历史记录页面
    _showInfoSnackBar('历史记录功能开发中');
  }

  void _showMatchStats() {
    // 这里应该导航到统计页面
    _showInfoSnackBar('统计功能开发中');
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isInQueue = _currentStatus?.status == MatchmakingStatus.searching;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('双人匹配'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadInitialData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MatchStatusCard(
                matchmakingStatus: _currentStatus,
                onCancel: _cancelMatching,
              ),
              const SizedBox(height: 16),
              MatchInfoPanel(
                matchmakingStatus: _currentStatus,
                currentEloRange: _currentEloRange,
                queuePosition: _queuePosition,
                onlinePlayersCount: _onlinePlayersCount,
              ),
              const SizedBox(height: 16),
              MatchControlPanel(
                isInQueue: isInQueue,
                onStartMatching: _startMatching,
                onCancelMatching: _cancelMatching,
                onViewHistory: _showMatchHistory,
                onViewStats: _showMatchStats,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '当前ELO评分',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_currentEloRating',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 