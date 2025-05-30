import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_yacht/generated/app_localizations.dart';
import 'package:simple_yacht/state_management/providers/user_providers.dart';
// import 'package:simple_yacht/services/multiplayer_service.dart'; // Not used directly for online count
import 'package:simple_yacht/services/presence_service.dart'; // Import PresenceService provider
import 'package:simple_yacht/state_management/providers/multiplayer_providers.dart';
import 'package:simple_yacht/models/game_enums.dart';

class MultiplayerLobbyScreen extends ConsumerStatefulWidget {
  const MultiplayerLobbyScreen({super.key});

  @override
  ConsumerState<MultiplayerLobbyScreen> createState() => _MultiplayerLobbyScreenState();
}

class _MultiplayerLobbyScreenState extends ConsumerState<MultiplayerLobbyScreen> {
  final TextEditingController _roomCodeController = TextEditingController();
  bool _isLoading = false;
  // int _onlinePlayersCount = 0; // Removed, will use provider

  @override
  void initState() {
    super.initState();
    // _loadOnlinePlayersCount(); // Removed
  }

  @override
  void dispose() {
    _roomCodeController.dispose();
    super.dispose();
  }

  // Future<void> _loadOnlinePlayersCount() async { // Removed
  //   try {
  //     // TODO: 实现获取在线玩家数量的逻辑
  //     // final count = await ref.read(multiplayerServiceProvider).getOnlinePlayersCount();
  //     setState(() {
  //       _onlinePlayersCount = 42; // 临时数据
  //     });
  //   } catch (e) {
  //     // 处理错误
  //     setState(() {
  //       _onlinePlayersCount = 0;
  //     });
  //   }
  // }

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
      // 使用实际的MultiplayerService创建房间
      final roomId = await ref.read(multiplayerServiceProvider).createRoom(
        roomName: "Game Room",
        gameMode: GameMode.multiplayer, // 需要导入GameMode
      );
      
      if (mounted) {
        context.go('/multiplayer_room/$roomId');
      }
    } catch (e) {
      if (mounted) {
        final l10nScoped = AppLocalizations.of(context)!; // Scoped l10n
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10nScoped.invalidRoomCode),
            backgroundColor: Colors.red,
          )
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  } // End of _createRoom method

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final usernameAsync = ref.watch(usernameProvider);
    final onlinePlayersAsync = ref.watch(onlinePlayersCountProvider);

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
                              // usernameAsync.when( // Placeholder, replace with actual provider later
                              //   data: (username) => Text(
                              //     username ?? 'Unknown',
                              //     style: Theme.of(context).textTheme.headlineSmall,
                              //   ),
                              //   loading: () => Text(
                              //     "Loading...", // Placeholder
                              //     style: Theme.of(context).textTheme.headlineSmall,
                              //   ),
                              //   error: (_, __) => Text(
                              //     "Error", // Placeholder
                              //     style: Theme.of(context).textTheme.headlineSmall,
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
                              Text(
                                // TODO: 添加ELO评级和胜率
                                'ELO: 1200 | Win Rate: 65%', // Placeholder
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
                    onlinePlayersAsync.when(
                      data: (dataValue) { // dataValue here is the actual int value from the stream if successful
                        return Text(
                          l10n.onlinePlayers(dataValue), // dataValue should be int
                          style: Theme.of(context).textTheme.titleMedium,
                        );
                      },
                      loading: () => Text(
                        "Online Players: Loading...", // Placeholder for l10n.onlinePlayersLoading
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      error: (err, stack) => Text(
                        "Online Players: Error", // Placeholder for l10n.onlinePlayersError
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              "Game Modes", // Placeholder for l10n.gameModes
              style: Theme.of(context).textTheme.titleLarge,
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _quickMatch,
              icon: const Icon(Icons.flash_on),
              label: Text(l10n.quickMatch),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _createRoom,
              icon: const Icon(Icons.add),
              label: Text(l10n.createRoom),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            
            const SizedBox(height: 12),
            
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
                      controller: _roomCodeController,
                      decoration: InputDecoration(
                        hintText: l10n.enterRoomCode,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.meeting_room),
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : () => _joinRoom(_roomCodeController.text.trim()),
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
            
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _joinRoom(String roomId) async {
    final l10nScoped = AppLocalizations.of(context)!; // Scoped l10n
    if (roomId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Please enter a room code."), // Placeholder for l10n.pleaseEnterRoomCode
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      // TODO: Implement actual join room logic
      // final gameRoom = await ref.read(multiplayerServiceProvider).joinRoom(roomId);
      // if (mounted && gameRoom != null) {
      //   context.go('/multiplayer_room/$roomId');
      // } else if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text(AppLocalizations.of(context)!.roomNotFound)),
      //   );
      // }
      // Temporary:
      // 使用实际的MultiplayerService加入房间
      // await ref.read(multiplayerServiceProvider).joinRoom(roomId); // This was causing an error
      
      // if (mounted) { // This was causing an error
      //   context.go('/multiplayer_room/$roomId'); // This was causing an error
      // } // This was causing an error
    } catch (e) { // Added catch (e) here
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.genericError}: $e'), // Now correctly inside SnackBar
            backgroundColor: Colors.red,
          )
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
}

// It's recommended to add these to your ARB files:
// "onlinePlayersLoading": "在线玩家: 加载中...",
// "onlinePlayersError": "在线玩家: 错误",
