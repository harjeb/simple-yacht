import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/generated/app_localizations.dart';
import 'package:myapp/state_management/providers/user_providers.dart';
import 'package:myapp/services/multiplayer_service.dart';

class MultiplayerLobbyScreen extends ConsumerWidget { // Changed to ConsumerWidget
  const MultiplayerLobbyScreen({super.key});

  @override
  ConsumerState<MultiplayerLobbyScreen> createState() => _MultiplayerLobbyScreenState();
}

class _MultiplayerLobbyScreenState extends ConsumerState<MultiplayerLobbyScreen> {
  final TextEditingController _roomCodeController = TextEditingController();
  bool _isLoading = false;
  int _onlinePlayersCount = 0;

  @override
  void initState() {
    super.initState();
    _loadOnlinePlayersCount();
  }

  @override
  void dispose() {
    _roomCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadOnlinePlayersCount() async {
    try {
      // TODO: 实现获取在线玩家数量的逻辑
      // final count = await ref.read(multiplayerServiceProvider).getOnlinePlayersCount();
      setState(() {
        _onlinePlayersCount = 42; // 临时数据
      });
    } catch (e) {
      // 处理错误
      setState(() {
        _onlinePlayersCount = 0;
      });
    }
  }

  Future<void> _quickMatch() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 导航到匹配界面
      if (mounted) {
        context.go('/matchmaking');
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

  Future<void> _createRoom() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: 实现创建房间逻辑
      // final roomId = await ref.read(multiplayerServiceProvider).createRoom();
      // if (mounted) {
      //   context.go('/multiplayer_room/$roomId');
      // }
      
      // 临时导航到示例房间
      if (mounted) {
        context.go('/multiplayer_room/DEMO123');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.invalidRoomCode),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.multiplayerLobby),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 用户信息卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          child: Icon(Icons.person, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              usernameAsync.when(
                                data: (username) => Text(
                                  username ?? 'Unknown',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                loading: () => Text(
                                  l10n.loadingLabel,
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                error: (_, __) => Text(
                                  l10n.errorLabel,
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // TODO: 添加ELO评级和胜率
                              Text(
                                'ELO: 1200 | 胜率: 65%',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 实时在线状态卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.people, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      l10n.onlinePlayers(_onlinePlayersCount),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 游戏模式选择
            Text(
              '游戏模式',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            
            const SizedBox(height: 16),
            
            // 快速匹配按钮
            ElevatedButton.icon(
              onPressed: isLoading ? null : quickMatch, // Simplified
              icon: const Icon(Icons.flash_on),
              label: Text(l10n.quickMatch),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // 创建房间按钮
            ElevatedButton.icon(
              onPressed: isLoading ? null : createRoom, // Simplified
              icon: const Icon(Icons.add),
              label: Text(l10n.createRoom),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // 加入房间区域
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.joinRoom,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: roomCodeController, // Simplified
                      decoration: InputDecoration(
                        hintText: l10n.enterRoomCode,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.meeting_room),
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : () => joinRoom(roomCodeController.text.trim()), // Simplified
                      icon: const Icon(Icons.login),
                      label: Text(l10n.joinRoom),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // 加载指示器
            if (isLoading) // Simplified
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
  // Removed dispose method as _roomCodeController is now local to build or would be managed by Riverpod.
}

// It's recommended to add these to your ARB files:
// "onlinePlayersLoading": "在线玩家: 加载中...",
// "onlinePlayersError": "在线玩家: 错误",
