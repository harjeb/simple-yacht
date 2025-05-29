import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:simple_yacht/models/game_room.dart';
import 'package:simple_yacht/state_management/providers/user_providers.dart';
import 'package:simple_yacht/state_management/providers/game_providers.dart';
import 'package:simple_yacht/widgets/dice_widget.dart';
import 'package:simple_yacht/widgets/scoreboard_widget.dart';

class MultiplayerGameScreen extends ConsumerStatefulWidget {
  final String roomId;
  
  const MultiplayerGameScreen({
    super.key,
    required this.roomId,
  });

  @override
  ConsumerState<MultiplayerGameScreen> createState() => _MultiplayerGameScreenState();
}

class _MultiplayerGameScreenState extends ConsumerState<MultiplayerGameScreen> {
  bool _isMyTurn = true; // 临时数据
  bool _isGameOver = false;
  int _currentRound = 1;
  int _maxRounds = 13;
  
  // 临时对手数据
  final Map<String, dynamic> _opponent = {
    'username': 'Opponent',
    'score': 85,
    'status': 'waiting', // 'rolling', 'selecting', 'waiting'
  };

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    try {
      // TODO: 实现游戏初始化逻辑
      // await ref.read(multiplayerServiceProvider).initializeGame(widget.roomId);
      
      // 初始化游戏状态
      ref.read(gameStateProvider.notifier).resetAndStartNewGame();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.genericError}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _endTurn() async {
    if (!_isMyTurn) return;
    
    setState(() {
      _isMyTurn = false;
    });

    try {
      // TODO: 实现结束回合的逻辑
      // await ref.read(multiplayerServiceProvider).endTurn(widget.roomId);
      
      // 模拟对手回合
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _currentRound++;
        if (_currentRound > _maxRounds) {
          _isGameOver = true;
          _showGameResult();
        } else {
          _isMyTurn = true;
        }
      });
    } catch (e) {
      setState(() {
        _isMyTurn = true;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.genericError}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showGameResult() {
    final gameState = ref.read(gameStateProvider);
    final myScore = gameState.totalScore;
    final opponentScore = _opponent['score'] as int;
    
    String resultText;
    if (myScore > opponentScore) {
      resultText = AppLocalizations.of(context)!.youWin;
    } else if (myScore < opponentScore) {
      resultText = AppLocalizations.of(context)!.youLose;
    } else {
      resultText = AppLocalizations.of(context)!.gameDraw;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.gameResult),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              resultText,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text('你的分数: $myScore'),
            Text('对手分数: $opponentScore'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/multiplayer_lobby');
            },
            child: Text(AppLocalizations.of(context)!.backToLobby),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _playAgain();
            },
            child: Text(AppLocalizations.of(context)!.playAgain),
          ),
        ],
      ),
    );
  }

  Future<void> _playAgain() async {
    try {
      // TODO: 实现再玩一局的逻辑
      // await ref.read(multiplayerServiceProvider).requestRematch(widget.roomId);
      
      // 重置游戏状态
      ref.read(gameStateProvider.notifier).resetAndStartNewGame();
      setState(() {
        _isMyTurn = true;
        _isGameOver = false;
        _currentRound = 1;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.genericError}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _leaveGame() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('离开游戏'),
        content: Text('确定要离开游戏吗？游戏将被终止。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.confirmButtonLabel),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // TODO: 实现离开游戏的逻辑
        // await ref.read(multiplayerServiceProvider).leaveGame(widget.roomId);
        
        if (mounted) {
          context.go('/multiplayer_lobby');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppLocalizations.of(context)!.genericError}: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final gameState = ref.watch(gameStateProvider);
    final usernameAsync = ref.watch(usernameProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.multiplayerGame} - 回合 $_currentRound/$_maxRounds'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _leaveGame,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: 实现游戏设置
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 对手信息栏
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  child: Icon(Icons.person),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _opponent['username'],
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '分数: ${_opponent['score']}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _isMyTurn ? Colors.grey : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _isMyTurn ? l10n.opponentTurn : '对手操作中...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 回合状态指示器
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            color: _isMyTurn ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
            child: Text(
              _isMyTurn ? l10n.yourTurn : l10n.opponentTurn,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _isMyTurn ? Colors.green : Colors.grey,
              ),
            ),
          ),
          
          // 游戏区域
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 骰子区域
                  DiceWidget(),
                  
                  const SizedBox(height: 16),
                  
                  // 计分板
                  Expanded(
                    child: ScoreboardWidget(),
                  ),
                ],
              ),
            ),
          ),
          
          // 当前玩家信息
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  child: Icon(Icons.person),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      usernameAsync.when(
                        data: (username) => Text(
                          username ?? 'Unknown',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        loading: () => Text(
                          l10n.loadingLabel,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        error: (_, __) => Text(
                          l10n.errorLabel,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        '分数: ${gameState.totalScore}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                if (_isMyTurn && !_isGameOver)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      l10n.yourTurn,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
