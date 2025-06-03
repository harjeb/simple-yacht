import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_yacht/generated/app_localizations.dart';
import 'package:simple_yacht/state_management/providers/user_providers.dart';
// import 'package:simple_yacht/services/multiplayer_service.dart'; // Not used directly for online count
import 'package:simple_yacht/services/presence_service.dart'; // Import PresenceService provider
import 'package:simple_yacht/state_management/providers/multiplayer_providers.dart';
import 'package:simple_yacht/models/game_enums.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 新增导入

class MultiplayerLobbyScreen extends ConsumerStatefulWidget {
  const MultiplayerLobbyScreen({super.key});

  @override
  ConsumerState<MultiplayerLobbyScreen> createState() => _MultiplayerLobbyScreenState();
}

class _MultiplayerLobbyScreenState extends ConsumerState<MultiplayerLobbyScreen> {
  final TextEditingController _roomCodeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _roomCodeController.dispose();
    super.dispose();
  }

  Future<void> _quickMatch() async {
    setState(() {
      _isLoading = true;
    });

    try {
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
      final roomId = await ref.read(multiplayerServiceProvider).createRoom(
        gameMode: GameMode.multiplayer, 
      );
      
      if (mounted) {
        context.go('/multiplayer_room/$roomId');
      }
    } catch (e) {
      if (mounted) {
        final l10nScoped = AppLocalizations.of(context)!; 
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
  } 

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
                              Text(
                                'ELO: 1000 | Win Rate: 50%', 
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
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.people, color: Colors.green),
                    const SizedBox(width: 8),
                    onlinePlayersAsync.when(
                      data: (dataValue) { 
                        return Text(
                          l10n.onlinePlayers(dataValue), 
                          style: Theme.of(context).textTheme.titleMedium,
                        );
                      },
                      loading: () => Text(
                        "Online Players: Loading...", 
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      error: (err, stack) => Text(
                        "Online Players: Error", 
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              "Game Modes", 
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

  Future<void> _joinRoom(String roomCodeInput) async { 
    final l10nScoped = AppLocalizations.of(context)!; 
    if (roomCodeInput.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("请输入房间代码."), // Replaced l10nScoped.pleaseEnterRoomCode
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
      await ref.read(multiplayerServiceProvider).joinRoomByCode(roomCodeInput);
      
      if (mounted) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('gameRooms')
            .where('roomCode', isEqualTo: roomCodeInput)
            .limit(1)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          final roomId = querySnapshot.docs.first.id;
          context.go('/multiplayer_room/$roomId');
        } else {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10nScoped.roomNotFound)),
          );
        }
      }
    } catch (e) { 
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10nScoped.genericError}: $e'), 
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
