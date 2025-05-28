import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/generated/app_localizations.dart';
import 'package:myapp/state_management/providers/user_providers.dart';

class MultiplayerRoomScreen extends ConsumerStatefulWidget {
  final String roomId;
  
  const MultiplayerRoomScreen({
    super.key,
    required this.roomId,
  });

  @override
  ConsumerState<MultiplayerRoomScreen> createState() => _MultiplayerRoomScreenState();
}

class _MultiplayerRoomScreenState extends ConsumerState<MultiplayerRoomScreen> {
  bool _isHost = true; // 临时数据，实际应从服务获取
  bool _isReady = false;
  bool _isLoading = false;
  
  // 临时玩家数据
  final List<Map<String, dynamic>> _players = [
    {
      'id': '1',
      'username': 'Player1',
      'isHost': true,
      'isReady': true,
      'elo': 1200,
    },
    {
      'id': '2',
      'username': 'Waiting...',
      'isHost': false,
      'isReady': false,
      'elo': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadRoomData();
  }

  Future<void> _loadRoomData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: 实现加载房间数据的逻辑
      // final roomData = await ref.read(multiplayerServiceProvider).getRoomData(widget.roomId);
      // setState(() {
      //   _players = roomData.players;
      //   _isHost = roomData.isCurrentUserHost;
      // });
      
      await Future.delayed(const Duration(seconds: 1)); // 模拟加载
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.genericError}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _copyRoomCode() async {
    await Clipboard.setData(ClipboardData(text: widget.roomId));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.roomCodeCopied),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _toggleReady() async {
    if (_isHost) return; // 房主不需要准备状态
    
    setState(() {
      _isReady = !_isReady;
    });

    try {
      // TODO: 实现切换准备状态的逻辑
      // await ref.read(multiplayerServiceProvider).setPlayerReady(widget.roomId, _isReady);
    } catch (e) {
      // 回滚状态
      setState(() {
        _isReady = !_isReady;
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

  Future<void> _startGame() async {
    if (!_isHost) return;
    
    // 检查所有玩家是否准备就绪
    final allPlayersReady = _players.where((p) => !p['isHost']).every((p) => p['isReady']);
    if (!allPlayersReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.waitingForPlayers),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: 实现开始游戏的逻辑
      // await ref.read(multiplayerServiceProvider).startGame(widget.roomId);
      
      if (mounted) {
        context.go('/multiplayer_game/${widget.roomId}');
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _leaveRoom() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.leaveRoom),
        content: Text('确定要离开房间吗？'),
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
        // TODO: 实现离开房间的逻辑
        // await ref.read(multiplayerServiceProvider).leaveRoom(widget.roomId);
        
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
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.roomCode} #${widget.roomId}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _leaveRoom,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 房间信息卡片
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${l10n.roomCode}: ${widget.roomId}',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              IconButton(
                                onPressed: _copyRoomCode,
                                icon: const Icon(Icons.copy),
                                tooltip: l10n.copyRoomCode,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '游戏设置: 标准模式 | 13回合',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '房间状态: 等待玩家',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 玩家列表
                  Text(
                    '玩家列表',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Expanded(
                    child: ListView.builder(
                      itemCount: _players.length,
                      itemBuilder: (context, index) {
                        final player = _players[index];
                        final isWaiting = player['username'] == 'Waiting...';
                        
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: isWaiting
                                  ? const Icon(Icons.hourglass_empty)
                                  : const Icon(Icons.person),
                            ),
                            title: Row(
                              children: [
                                Text(player['username']),
                                if (player['isHost'])
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      l10n.roomHost,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: isWaiting
                                ? null
                                : Text('ELO: ${player['elo'] ?? 'N/A'}'),
                            trailing: isWaiting
                                ? null
                                : player['isHost']
                                    ? const Icon(Icons.star, color: Colors.amber)
                                    : Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: player['isReady']
                                              ? Colors.green
                                              : Colors.grey,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          player['isReady']
                                              ? l10n.playerReady
                                              : l10n.playerNotReady,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 控制按钮区域
                  if (_isHost) ...[
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _startGame,
                      icon: const Icon(Icons.play_arrow),
                      label: Text(l10n.startGame),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ] else ...[
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _toggleReady,
                      icon: Icon(_isReady ? Icons.check : Icons.hourglass_empty),
                      label: Text(_isReady ? l10n.playerReady : l10n.playerNotReady),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: _isReady ? Colors.green : Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _leaveRoom,
                    icon: const Icon(Icons.exit_to_app),
                    label: Text(l10n.leaveRoom),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
