const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();

/**
 * Generates a custom authentication token for the given UID.
 * This is used for account recovery via transfer code.
 *
 * @param {{uid: string}} data - The data for the request, expecting a UID.
 * @param {functions.https.CallableContext} context - The context of the
 * function call.
 * @returns {Promise<{token: string}>} A promise that resolves with the
 * custom token.
 * @throws {functions.https.HttpsError} Throws an error if UID is not
 * provided or if token generation fails.
 */
exports.generateCustomAuthToken = functions.https.onCall(
    async (data, context) => {
      console.log('=== generateCustomAuthToken Cloud Function 调用开始 ===');
      console.log('原始传入 data 对象:', data);

      // 尝试从不同位置提取 uid
      let uid = null;
      if (data && typeof data === 'object') {
        if (data.uid) {
          uid = data.uid;
          console.log('从 data.uid 提取的 UID:', uid);
        } else if (data.data && typeof data.data === 'object' && data.data.uid) {
          uid = data.data.uid;
          console.log('从 data.data.uid 提取的 UID:', uid);
        }
      }

      console.log('最终提取的 UID:', uid);

      if (!uid) {
        console.error('错误: 未能提取到 uid 参数');
        throw new functions.https.HttpsError(
            'invalid-argument',
            'The function must be called with a "uid" argument.',
        );
      }

      try {
        console.log('开始生成自定义令牌...');
        const customToken = await admin.auth().createCustomToken(uid);
        console.log('自定义令牌生成成功');
        return {token: customToken};
      } catch (error) {
        console.error('Error creating custom token:', error);
        throw new functions.https.HttpsError(
            'internal',
            'Unable to create custom token.',
            error,
        );
      }
    });

/**
 * Deletes a user's data from Firestore and their Firebase
 * Authentication record.
 *
 * @param {{uid: string}} data - The data for the request, expecting a UID.
 * @param {functions.https.CallableContext} context - The context of the
 * function call.
 * @returns {Promise<{success: boolean, message: string}>} A promise that
 * resolves with a success status.
 * @throws {functions.https.HttpsError} Throws an error if UID is not
 * provided or if deletion fails.
 */
exports.deleteUserData = functions.https.onCall(async (data, context) => {
  console.log('=== deleteUserData Cloud Function 调用开始 ===');

  // 安全地记录接收到的数据，避免循环引用
  console.log('原始传入 data 对象:', data);
  try {
    console.log('序列化后的 data 对象:', JSON.stringify(data));
  } catch (jsonError) {
    console.warn('警告: 序列化 data 对象失败:', jsonError.message);
    console.log('data 对象 (无法序列化):', data);
  }

  if (data && typeof data === 'object') {
    console.log('data 对象键:', Object.keys(data));
    if ('data' in data && data.data && typeof data.data === 'object') {
      console.log('嵌套的 data.data 对象键:', Object.keys(data.data));
    }
  }

  // 安全地记录上下文信息，避免循环引用
  console.log('上下文信息:', {
    auth: context.auth ? {
      uid: context.auth.uid,
      token: !!context.auth.token,
    } : null,
    app: context.app ? {
      appId: context.app.appId || 'unknown',
      projectId: context.app.projectId || 'unknown',
    } : null,
    hasRawRequest: !!context.rawRequest,
    instanceIdToken: context.instanceIdToken ? 'present' : 'absent',
  });

  // 尝试从 data.uid 或 data.data.uid 提取 uid
  let uid = null;
  if (data && typeof data === 'object') {
    if (data.uid) {
      uid = data.uid;
      console.log('从 data.uid 提取的 UID:', uid);
    } else if (data.data && typeof data.data === 'object' && data.data.uid) {
      uid = data.data.uid;
      console.log('从 data.data.uid 提取的 UID:', uid);
    }
  }

  console.log('最终提取的 UID:', uid);

  if (!uid) {
    console.error('错误: 最终未能提取到 uid 参数。请检查客户端调用和传入的 data 结构。');
    throw new functions.https.HttpsError(
        'invalid-argument',
        'The function must be called with a "uid" argument.',
    );
  }

  // 在开发环境中，如果没有认证上下文，允许继续执行（用于调试）
  if (!context.auth) {
    console.warn('警告: 没有认证上下文，这可能是 App Check 验证失败导致的');
    console.warn('在开发环境中继续执行...');
  } else if (context.auth.uid !== uid) {
    console.error('权限错误: 认证用户 UID 与请求 UID 不匹配');
    console.error('认证 UID:', context.auth.uid, '请求 UID:', uid);
    throw new functions.https.HttpsError(
        'permission-denied',
        'You do not have permission to delete this user.',
    );
  }

  try {
    console.log('开始删除用户数据...');

    // 1. 删除 Firestore 用户文档
    console.log('步骤 1: 删除 Firestore 用户文档');
    const userDocRef = db.collection('users').doc(uid);

    // 检查文档是否存在
    const userDoc = await userDocRef.get();
    if (userDoc.exists) {
      console.log('用户文档存在，开始删除...');
      await userDocRef.delete();
      console.log('Firestore 用户文档删除成功');
    } else {
      console.log('用户文档不存在，跳过 Firestore 删除');
    }

    // 2. 删除 Firebase Auth 用户
    console.log('步骤 2: 删除 Firebase Auth 用户');
    try {
      await admin.auth().deleteUser(uid);
      console.log('Firebase Auth 用户删除成功');
    } catch (authError) {
      console.error('删除 Firebase Auth 用户时出错:', authError);
      // 如果用户已经不存在，继续执行
      if (authError.code === 'auth/user-not-found') {
        console.log('用户在 Firebase Auth 中不存在，继续执行');
      } else {
        throw authError; // 重新抛出其他认证错误
      }
    }

    console.log(`成功删除用户数据，UID: ${uid}`);
    return {success: true, message: 'User data deleted successfully.'};
  } catch (error) {
    console.error(`删除用户数据时发生错误，UID: ${uid}`);
    console.error('错误详情:', error);
    console.error('错误类型:', error.constructor.name);
    console.error('错误代码:', error.code);
    console.error('错误消息:', error.message);

    throw new functions.https.HttpsError(
        'internal',
        'Unable to delete user data: ' + error.message,
        {
          originalError: error.message,
          errorCode: error.code,
          uid: uid,
        },
    );
  }
});

/**
 * 设置唯一用户名
 * 使用Firestore事务确保用户名唯一性
 */
exports.setUniqueUsername = functions.https.onCall(async (data, context) => {
  // 验证认证
  if (!context.auth) {
    throw new functions.https.HttpsError(
        'unauthenticated',
        'The function must be called while authenticated.',
    );
  }

  const {username} = data;
  const userId = context.auth.uid;

  if (!username || typeof username !== 'string') {
    throw new functions.https.HttpsError(
        'invalid-argument',
        'Username must be a non-empty string.',
    );
  }

  // 验证用户名格式
  if (username.length < 3 || username.length > 15) {
    throw new functions.https.HttpsError(
        'invalid-argument',
        'Username must be between 3 and 15 characters.',
    );
  }

  if (!/^[a-zA-Z0-9_]+$/.test(username)) {
    throw new functions.https.HttpsError(
        'invalid-argument',
        'Username can only contain letters, numbers, and underscores.',
    );
  }

  const normalizedUsername = username.toLowerCase();

  try {
    const result = await db.runTransaction(async (transaction) => {
      // 检查用户名是否已存在
      const usernameDoc = await transaction.get(
          db.collection('usernames').doc(normalizedUsername),
      );

      if (usernameDoc.exists && usernameDoc.data().userId !== userId) {
        throw new functions.https.HttpsError(
            'already-exists',
            'Username is already taken.',
        );
      }

      // 获取用户当前数据
      const userDoc = await transaction.get(db.collection('users').doc(userId));
      const userData = userDoc.exists ? userDoc.data() : {};

      // 如果用户已有用户名，需要清理旧的用户名记录
      if (userData.normalizedUsername &&
          userData.normalizedUsername !== normalizedUsername) {
        transaction.delete(
            db.collection('usernames').doc(userData.normalizedUsername),
        );
      }

      // 设置新的用户名记录
      transaction.set(db.collection('usernames').doc(normalizedUsername), {
        userId: userId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // 更新用户文档
      transaction.set(db.collection('users').doc(userId), {
        ...userData,
        username: username,
        normalizedUsername: normalizedUsername,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        // 初始化游戏数据（如果是新用户）
        elo: userData.elo || 1200,
        wins: userData.wins || 0,
        losses: userData.losses || 0,
        draws: userData.draws || 0,
        totalGames: userData.totalGames || 0,
      }, {merge: true});

      return {success: true};
    });

    return result;
  } catch (error) {
    console.error('Error setting username:', error);
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    throw new functions.https.HttpsError(
        'internal',
        'Unable to set username.',
    );
  }
});

/**
 * 计算动态ELO匹配范围
 * @param {object} queueEntry 队列条目
 * @return {number} 当前匹配范围
 */
function calculateDynamicEloRange(queueEntry) {
  const now = admin.firestore.Timestamp.now();
  const joinedAt = queueEntry.createdAt;
  const waitTimeMs = now.toMillis() - joinedAt.toMillis();
  const waitTimeSeconds = Math.floor(waitTimeMs / 1000);

  // 每30秒扩大100分，初始范围100分
  const intervals = Math.floor(waitTimeSeconds / 30);
  const baseRange = 100;
  const expansion = intervals * 100;
  const maxRange = 500;

  return Math.min(baseRange + expansion, maxRange);
}

/**
 * 加入匹配队列 (优化版本)
 */
exports.joinMatchmakingQueueOptimized = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
        'unauthenticated',
        'The function must be called while authenticated.',
    );
  }

  const userId = context.auth.uid;
  const {gameMode = 'random'} = data;

  try {
    // 获取用户信息
    const userDoc = await db.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      throw new functions.https.HttpsError(
          'not-found',
          'User profile not found.',
      );
    }

    const userData = userDoc.data();
    const userElo = userData.elo || 1200;

    // 检查是否已在队列中
    const existingQueue = await db.collection('matchmakingQueue')
        .doc(userId).get();
    if (existingQueue.exists) {
      return {
        success: true,
        message: 'Already in queue',
        queueId: userId,
      };
    }

    // 获取所有等待中的队列条目，按等待时间排序
    const waitingQueue = await db.collection('matchmakingQueue')
        .where('gameMode', '==', gameMode)
        .where('status', '==', 'waiting')
        .orderBy('createdAt', 'asc')
        .get();

    let matchedOpponent = null;

    // 遍历队列，寻找合适的对手
    for (const queueDoc of waitingQueue.docs) {
      const queueData = queueDoc.data();
      const opponentElo = queueData.elo;

      // 计算对手的动态匹配范围
      const opponentRange = calculateDynamicEloRange(queueData);

      // 检查双方是否在彼此的匹配范围内
      const eloDistance = Math.abs(userElo - opponentElo);
      if (eloDistance <= opponentRange) {
        matchedOpponent = {
          id: queueData.userId,
          data: queueData,
          doc: queueDoc,
        };
        break;
      }
    }

    if (matchedOpponent) {
      // 找到对手，创建游戏房间
      const opponentId = matchedOpponent.id;
      const opponentData = matchedOpponent.data;

      // 创建游戏房间
      const roomId = `${userId}_${opponentId}_${Date.now()}`;
      const gameRoomData = {
        roomId: roomId,
        player1: userId,
        player2: opponentId,
        players: [userId, opponentId],
        gameMode: gameMode,
        status: 'active',
        currentPlayer: userId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        lastActivity: admin.firestore.FieldValue.serverTimestamp(),
        matchingInfo: {
          player1Elo: userElo,
          player2Elo: opponentData.elo,
          eloDistance: Math.abs(userElo - opponentData.elo),
          opponentWaitTime: admin.firestore.Timestamp.now().toMillis() -
              opponentData.createdAt.toMillis(),
          matchRange: calculateDynamicEloRange(opponentData),
        },
        gameState: {
          round: 1,
          player1Score: 0,
          player2Score: 0,
          isGameOver: false,
        },
      };

      // 使用事务创建房间并清理队列
      await db.runTransaction(async (transaction) => {
        // 创建游戏房间
        transaction.set(db.collection('gameRooms').doc(roomId), gameRoomData);

        // 删除队列条目
        transaction.delete(db.collection('matchmakingQueue').doc(userId));
        transaction.delete(matchedOpponent.doc.ref);
      });

      return {
        success: true,
        matched: true,
        roomId: roomId,
        opponent: {
          id: opponentId,
          username: opponentData.username,
          elo: opponentData.elo,
        },
        matchingInfo: gameRoomData.matchingInfo,
      };
    } else {
      // 没有找到对手，加入队列
      const queueData = {
        userId: userId,
        username: userData.username,
        elo: userElo,
        gameMode: gameMode,
        status: 'waiting',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        lastActivity: admin.firestore.FieldValue.serverTimestamp(),
        // 新增字段用于统计和监控
        currentMatchRange: 100, // 初始范围
        matchAttempts: 0,
        statistics: {
          totalWaitTime: 0,
          averageWaitTime: 0,
          matchSuccessRate: 0,
        },
      };

      await db.collection('matchmakingQueue').doc(userId).set(queueData);

      return {
        success: true,
        matched: false,
        message: 'Added to matchmaking queue',
        queueId: userId,
        currentRange: 100,
        estimatedWaitTime: '30-60 seconds',
      };
    }
  } catch (error) {
    console.error('Error joining matchmaking queue:', error);
    throw new functions.https.HttpsError(
        'internal',
        'Unable to join matchmaking queue.',
    );
  }
});

/**
 * 获取匹配队列状态
 */
exports.getMatchmakingStatus = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
        'unauthenticated',
        'The function must be called while authenticated.',
    );
  }

  const userId = context.auth.uid;

  try {
    const queueDoc = await db.collection('matchmakingQueue').doc(userId).get();

    if (!queueDoc.exists) {
      return {
        success: true,
        inQueue: false,
        message: 'Not in queue',
      };
    }

    const queueData = queueDoc.data();
    const currentRange = calculateDynamicEloRange(queueData);
    const waitTimeMs = admin.firestore.Timestamp.now().toMillis() - queueData.createdAt.toMillis();
    const waitTimeSeconds = Math.floor(waitTimeMs / 1000);

    // 更新队列条目的当前范围
    await db.collection('matchmakingQueue').doc(userId).update({
      currentMatchRange: currentRange,
      lastActivity: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      success: true,
      inQueue: true,
      status: queueData.status,
      currentRange: currentRange,
      waitTime: waitTimeSeconds,
      estimatedTimeToMaxRange: Math.max(0, 120 - waitTimeSeconds), // 2分钟到最大范围
      queuePosition: await getQueuePosition(userId, queueData.gameMode),
      onlinePlayersCount: await getOnlinePlayersCount(queueData.gameMode),
    };
  } catch (error) {
    console.error('Error getting matchmaking status:', error);
    throw new functions.https.HttpsError(
        'internal',
        'Unable to get matchmaking status.',
    );
  }
});

/**
 * 获取队列中的位置
 */
async function getQueuePosition(userId, gameMode) {
  try {
    const queueSnapshot = await db.collection('matchmakingQueue')
        .where('gameMode', '==', gameMode)
        .where('status', '==', 'waiting')
        .orderBy('createdAt', 'asc')
        .get();

    let position = 1;
    for (const doc of queueSnapshot.docs) {
      if (doc.id === userId) {
        return position;
      }
      position++;
    }
    return -1; // 不在队列中
  } catch (error) {
    console.error('Error getting queue position:', error);
    return -1;
  }
}

/**
 * 获取在线玩家数量
 */
async function getOnlinePlayersCount(gameMode) {
  try {
    const [queueSnapshot, activeRoomsSnapshot] = await Promise.all([
      db.collection('matchmakingQueue')
          .where('gameMode', '==', gameMode)
          .where('status', '==', 'waiting')
          .get(),
      db.collection('gameRooms')
          .where('gameMode', '==', gameMode)
          .where('status', '==', 'active')
          .get(),
    ]);

    const queueCount = queueSnapshot.size;
    const activePlayersCount = activeRoomsSnapshot.size * 2; // 每个房间2个玩家

    return queueCount + activePlayersCount;
  } catch (error) {
    console.error('Error getting online players count:', error);
    return 0;
  }
}

/**
 * 离开匹配队列
 */
exports.leaveMatchmakingQueue = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
        'unauthenticated',
        'The function must be called while authenticated.',
    );
  }

  const userId = context.auth.uid;

  try {
    await db.collection('matchmakingQueue').doc(userId).delete();
    return {success: true, message: 'Left matchmaking queue'};
  } catch (error) {
    console.error('Error leaving matchmaking queue:', error);
    throw new functions.https.HttpsError(
        'internal',
        'Unable to leave matchmaking queue.',
    );
  }
});

/**
 * 创建好友对战房间
 */
exports.createFriendBattle = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
        'unauthenticated',
        'The function must be called while authenticated.',
    );
  }

  const userId = context.auth.uid;
  const {friendId} = data;

  if (!friendId) {
    throw new functions.https.HttpsError(
        'invalid-argument',
        'Friend ID is required.',
    );
  }

  try {
    // 验证好友关系
    const friendshipQuery = await db.collection('friendships')
        .where('user1', 'in', [userId, friendId])
        .where('user2', 'in', [userId, friendId])
        .where('status', '==', 'accepted')
        .limit(1)
        .get();

    if (friendshipQuery.empty) {
      throw new functions.https.HttpsError(
          'permission-denied',
          'You are not friends with this user.',
      );
    }

    // 获取双方用户信息
    const [userDoc, friendDoc] = await Promise.all([
      db.collection('users').doc(userId).get(),
      db.collection('users').doc(friendId).get(),
    ]);

    if (!userDoc.exists || !friendDoc.exists) {
      throw new functions.https.HttpsError(
          'not-found',
          'User profile not found.',
      );
    }

    // 创建游戏房间
    const roomId = `friend_${userId}_${friendId}_${Date.now()}`;
    const gameRoomData = {
      roomId: roomId,
      player1: userId,
      player2: null, // 等待好友加入
      players: [userId],
      gameMode: 'friend',
      status: 'waiting',
      invitedPlayer: friendId,
      currentPlayer: userId,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      lastActivity: admin.firestore.FieldValue.serverTimestamp(),
      gameState: {
        round: 1,
        player1Score: 0,
        player2Score: 0,
        isGameOver: false,
      },
    };

    await db.collection('gameRooms').doc(roomId).set(gameRoomData);

    return {
      success: true,
      roomId: roomId,
      message: 'Friend battle room created',
    };
  } catch (error) {
    console.error('Error creating friend battle:', error);
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    throw new functions.https.HttpsError(
        'internal',
        'Unable to create friend battle.',
    );
  }
});

/**
 * 加入好友对战房间
 */
exports.joinFriendBattle = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
        'unauthenticated',
        'The function must be called while authenticated.',
    );
  }

  const userId = context.auth.uid;
  const {roomId} = data;

  if (!roomId) {
    throw new functions.https.HttpsError(
        'invalid-argument',
        'Room ID is required.',
    );
  }

  try {
    const result = await db.runTransaction(async (transaction) => {
      const roomDoc = await transaction.get(
          db.collection('gameRooms').doc(roomId),
      );

      if (!roomDoc.exists) {
        throw new functions.https.HttpsError(
            'not-found',
            'Game room not found.',
        );
      }

      const roomData = roomDoc.data();

      // 验证用户是否被邀请
      if (roomData.invitedPlayer !== userId) {
        throw new functions.https.HttpsError(
            'permission-denied',
            'You are not invited to this room.',
        );
      }

      // 验证房间状态
      if (roomData.status !== 'waiting') {
        throw new functions.https.HttpsError(
            'failed-precondition',
            'Room is not available for joining.',
        );
      }

      // 更新房间状态
      transaction.update(db.collection('gameRooms').doc(roomId), {
        player2: userId,
        players: [roomData.player1, userId],
        status: 'active',
        lastActivity: admin.firestore.FieldValue.serverTimestamp(),
      });

      return {success: true, message: 'Joined friend battle'};
    });

    return result;
  } catch (error) {
    console.error('Error joining friend battle:', error);
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    throw new functions.https.HttpsError(
        'internal',
        'Unable to join friend battle.',
    );
  }
});

/**
 * 提交游戏结果并更新ELO评级
 */
exports.submitGameResult = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
        'unauthenticated',
        'The function must be called while authenticated.',
    );
  }

  const userId = context.auth.uid;
  const {roomId, playerScore, opponentScore} = data;

  if (!roomId || playerScore === undefined || opponentScore === undefined) {
    throw new functions.https.HttpsError(
        'invalid-argument',
        'Room ID and scores are required.',
    );
  }

  try {
    const result = await db.runTransaction(async (transaction) => {
      const roomDoc = await transaction.get(
          db.collection('gameRooms').doc(roomId),
      );

      if (!roomDoc.exists) {
        throw new functions.https.HttpsError(
            'not-found',
            'Game room not found.',
        );
      }

      const roomData = roomDoc.data();

      // 验证用户是否是房间参与者
      if (!roomData.players.includes(userId)) {
        throw new functions.https.HttpsError(
            'permission-denied',
            'You are not a participant in this room.',
        );
      }

      // 验证游戏是否已结束
      if (roomData.status === 'completed') {
        throw new functions.https.HttpsError(
            'failed-precondition',
            'Game has already been completed.',
        );
      }

      const player1Id = roomData.player1;
      const player2Id = roomData.player2;
      const isPlayer1 = userId === player1Id;
      const opponentId = isPlayer1 ? player2Id : player1Id;

      // 获取双方用户数据
      const [player1Doc, player2Doc] = await Promise.all([
        transaction.get(db.collection('users').doc(player1Id)),
        transaction.get(db.collection('users').doc(player2Id)),
      ]);

      const player1Data = player1Doc.data();
      const player2Data = player2Doc.data();

      // 计算ELO变化（仅对随机匹配）
      let eloChanges = {player1: 0, player2: 0};
      if (roomData.gameMode === 'random') {
        eloChanges = calculateEloChange(
            player1Data.elo || 1200,
            player2Data.elo || 1200,
            playerScore,
            opponentScore,
            isPlayer1,
        );
      }

      // 确定游戏结果
      let winner = null;
      if (playerScore > opponentScore) {
        winner = userId;
      } else if (opponentScore > playerScore) {
        winner = opponentId;
      }

      // 更新房间状态
      transaction.update(db.collection('gameRooms').doc(roomId), {
        status: 'completed',
        winner: winner,
        finalScores: {
          [player1Id]: isPlayer1 ? playerScore : opponentScore,
          [player2Id]: isPlayer1 ? opponentScore : playerScore,
        },
        completedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // 更新用户统计（仅对随机匹配更新ELO）
      const updatePlayer1Stats = {
        totalGames: (player1Data.totalGames || 0) + 1,
        lastGameAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      const updatePlayer2Stats = {
        totalGames: (player2Data.totalGames || 0) + 1,
        lastGameAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      if (roomData.gameMode === 'random') {
        updatePlayer1Stats.elo = (player1Data.elo || 1200) + eloChanges.player1;
        updatePlayer2Stats.elo = (player2Data.elo || 1200) + eloChanges.player2;
      }

      // 更新胜负记录
      if (winner === player1Id) {
        updatePlayer1Stats.wins = (player1Data.wins || 0) + 1;
        updatePlayer2Stats.losses = (player2Data.losses || 0) + 1;
      } else if (winner === player2Id) {
        updatePlayer1Stats.losses = (player1Data.losses || 0) + 1;
        updatePlayer2Stats.wins = (player2Data.wins || 0) + 1;
      } else {
        updatePlayer1Stats.draws = (player1Data.draws || 0) + 1;
        updatePlayer2Stats.draws = (player2Data.draws || 0) + 1;
      }

      transaction.update(db.collection('users').doc(player1Id), updatePlayer1Stats);
      transaction.update(db.collection('users').doc(player2Id), updatePlayer2Stats);

      // 记录ELO历史（仅对随机匹配）
      if (roomData.gameMode === 'random') {
        const matchId = `${roomId}_${Date.now()}`;
        transaction.set(
            db.collection('eloHistory').doc(player1Id)
                .collection('matches').doc(matchId),
            {
              opponentId: player2Id,
              opponentUsername: player2Data.username,
              myScore: isPlayer1 ? playerScore : opponentScore,
              opponentScore: isPlayer1 ? opponentScore : playerScore,
              eloChange: eloChanges.player1,
              newElo: (player1Data.elo || 1200) + eloChanges.player1,
              result: winner === player1Id ? 'win' : (winner === null ? 'draw' : 'loss'),
              gameMode: roomData.gameMode,
              timestamp: admin.firestore.FieldValue.serverTimestamp(),
            },
        );

        transaction.set(
            db.collection('eloHistory').doc(player2Id)
                .collection('matches').doc(matchId),
            {
              opponentId: player1Id,
              opponentUsername: player1Data.username,
              myScore: isPlayer1 ? opponentScore : playerScore,
              opponentScore: isPlayer1 ? playerScore : opponentScore,
              eloChange: eloChanges.player2,
              newElo: (player2Data.elo || 1200) + eloChanges.player2,
              result: winner === player2Id ? 'win' : (winner === null ? 'draw' : 'loss'),
              gameMode: roomData.gameMode,
              timestamp: admin.firestore.FieldValue.serverTimestamp(),
            },
        );
      }

      return {
        success: true,
        winner: winner,
        eloChanges: roomData.gameMode === 'random' ? eloChanges : null,
        finalScores: {
          [player1Id]: isPlayer1 ? playerScore : opponentScore,
          [player2Id]: isPlayer1 ? opponentScore : playerScore,
        },
      };
    });

    return result;
  } catch (error) {
    console.error('Error submitting game result:', error);
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    throw new functions.https.HttpsError(
        'internal',
        'Unable to submit game result.',
    );
  }
});

/**
 * 计算ELO评级变化
 * @param {number} player1Elo 玩家1当前ELO
 * @param {number} player2Elo 玩家2当前ELO
 * @param {number} player1Score 玩家1得分
 * @param {number} player2Score 玩家2得分
 * @param {boolean} isPlayer1 当前用户是否为玩家1
 * @return {object} ELO变化值
 */
function calculateEloChange(player1Elo, player2Elo, player1Score, player2Score, isPlayer1) {
  const K = 32; // ELO K因子

  // 计算期望得分
  const expectedScore1 = 1 / (1 + Math.pow(10, (player2Elo - player1Elo) / 400));
  const expectedScore2 = 1 / (1 + Math.pow(10, (player1Elo - player2Elo) / 400));

  // 计算实际得分
  let actualScore1; let actualScore2;
  if (player1Score > player2Score) {
    actualScore1 = 1;
    actualScore2 = 0;
  } else if (player1Score < player2Score) {
    actualScore1 = 0;
    actualScore2 = 1;
  } else {
    actualScore1 = 0.5;
    actualScore2 = 0.5;
  }

  // 计算ELO变化
  const eloChange1 = Math.round(K * (actualScore1 - expectedScore1));
  const eloChange2 = Math.round(K * (actualScore2 - expectedScore2));

  return {
    player1: eloChange1,
    player2: eloChange2,
  };
}

/**
 * 获取排行榜数据 (支持多种类型)
 */
exports.getLeaderboard = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
        'unauthenticated',
        'The function must be called while authenticated.',
    );
  }

  const {
    leaderboardType = 'total', // total, daily, weekly, monthly, ladder
    limit = 50,
    offset = 0,
  } = data;

  try {
    let query;
    const now = new Date();

    switch (leaderboardType) {
      case 'daily':
        // 日榜：今天的数据
        const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());
        query = db.collection('users')
            .where('lastGameAt', '>=', admin.firestore.Timestamp.fromDate(todayStart))
            .orderBy('elo', 'desc');
        break;

      case 'weekly':
        // 周榜：本周的数据
        const weekStart = new Date(now);
        weekStart.setDate(now.getDate() - now.getDay());
        weekStart.setHours(0, 0, 0, 0);
        query = db.collection('users')
            .where('lastGameAt', '>=', admin.firestore.Timestamp.fromDate(weekStart))
            .orderBy('elo', 'desc');
        break;

      case 'monthly':
        // 月榜：本月的数据
        const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);
        query = db.collection('users')
            .where('lastGameAt', '>=', admin.firestore.Timestamp.fromDate(monthStart))
            .orderBy('elo', 'desc');
        break;

      case 'ladder':
        // 天梯分排名：按ELO分段
        query = db.collection('users')
            .where('totalGames', '>', 0)
            .orderBy('elo', 'desc');
        break;

      case 'total':
      default:
        // 总榜：所有时间的数据
        query = db.collection('users')
            .where('totalGames', '>', 0)
            .orderBy('elo', 'desc');
        break;
    }

    const snapshot = await query
        .limit(Math.min(limit, 100))
        .offset(offset)
        .get();

    const leaderboard = [];
    let rank = offset + 1;

    snapshot.forEach((doc) => {
      const userData = doc.data();
      const userElo = userData.elo || 1200;

      leaderboard.push({
        rank: rank++,
        userId: doc.id,
        username: userData.username,
        elo: userElo,
        ladderTier: getLadderTier(userElo),
        wins: userData.wins || 0,
        losses: userData.losses || 0,
        draws: userData.draws || 0,
        totalGames: userData.totalGames || 0,
        winRate: userData.totalGames > 0 ?
          Math.round((userData.wins || 0) / userData.totalGames * 100) : 0,
        lastGameAt: userData.lastGameAt,
      });
    });

    return {
      success: true,
      leaderboardType: leaderboardType,
      leaderboard: leaderboard,
      hasMore: snapshot.size === limit,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    };
  } catch (error) {
    console.error('Error getting leaderboard:', error);
    throw new functions.https.HttpsError(
        'internal',
        'Unable to get leaderboard.',
    );
  }
});

/**
 * 获取天梯等级
 * @param {number} elo ELO分数
 * @return {object} 天梯等级信息
 */
function getLadderTier(elo) {
  if (elo >= 2400) {
    return {
      tier: 'grandmaster',
      name: '宗师',
      color: '#ff6b35',
      minElo: 2400,
      maxElo: null,
    };
  } else if (elo >= 2200) {
    return {
      tier: 'master',
      name: '大师',
      color: '#9c27b0',
      minElo: 2200,
      maxElo: 2399,
    };
  } else if (elo >= 2000) {
    return {
      tier: 'diamond',
      name: '钻石',
      color: '#2196f3',
      minElo: 2000,
      maxElo: 2199,
    };
  } else if (elo >= 1800) {
    return {
      tier: 'platinum',
      name: '铂金',
      color: '#00bcd4',
      minElo: 1800,
      maxElo: 1999,
    };
  } else if (elo >= 1600) {
    return {
      tier: 'gold',
      name: '黄金',
      color: '#ffc107',
      minElo: 1600,
      maxElo: 1799,
    };
  } else if (elo >= 1400) {
    return {
      tier: 'silver',
      name: '白银',
      color: '#9e9e9e',
      minElo: 1400,
      maxElo: 1599,
    };
  } else {
    return {
      tier: 'bronze',
      name: '青铜',
      color: '#795548',
      minElo: 0,
      maxElo: 1399,
    };
  }
}

/**
 * 获取用户在各排行榜中的排名
 */
exports.getUserRankings = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
        'unauthenticated',
        'The function must be called while authenticated.',
    );
  }

  const userId = context.auth.uid;

  try {
    const userDoc = await db.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      throw new functions.https.HttpsError(
          'not-found',
          'User profile not found.',
      );
    }

    const userData = userDoc.data();
    const userElo = userData.elo || 1200;

    // 并行获取各排行榜中的排名
    const [totalRank, dailyRank, weeklyRank, monthlyRank] = await Promise.all([
      getUserRankInLeaderboard(userId, userElo, 'total'),
      getUserRankInLeaderboard(userId, userElo, 'daily'),
      getUserRankInLeaderboard(userId, userElo, 'weekly'),
      getUserRankInLeaderboard(userId, userElo, 'monthly'),
    ]);

    return {
      success: true,
      userInfo: {
        username: userData.username,
        elo: userElo,
        ladderTier: getLadderTier(userElo),
        totalGames: userData.totalGames || 0,
        wins: userData.wins || 0,
        losses: userData.losses || 0,
        draws: userData.draws || 0,
        winRate: userData.totalGames > 0 ?
          Math.round((userData.wins || 0) / userData.totalGames * 100) : 0,
      },
      rankings: {
        total: totalRank,
        daily: dailyRank,
        weekly: weeklyRank,
        monthly: monthlyRank,
      },
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    };
  } catch (error) {
    console.error('Error getting user rankings:', error);
    throw new functions.https.HttpsError(
        'internal',
        'Unable to get user rankings.',
    );
  }
});

/**
 * 获取用户在特定排行榜中的排名
 * @param {string} userId 用户ID
 * @param {number} userElo 用户ELO
 * @param {string} leaderboardType 排行榜类型
 * @return {Promise<object>} 排名信息
 */
async function getUserRankInLeaderboard(userId, userElo, leaderboardType) {
  try {
    let query;
    const now = new Date();

    switch (leaderboardType) {
      case 'daily':
        const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());
        query = db.collection('users')
            .where('lastGameAt', '>=', admin.firestore.Timestamp.fromDate(todayStart))
            .where('elo', '>', userElo)
            .orderBy('elo', 'desc');
        break;

      case 'weekly':
        const weekStart = new Date(now);
        weekStart.setDate(now.getDate() - now.getDay());
        weekStart.setHours(0, 0, 0, 0);
        query = db.collection('users')
            .where('lastGameAt', '>=', admin.firestore.Timestamp.fromDate(weekStart))
            .where('elo', '>', userElo)
            .orderBy('elo', 'desc');
        break;

      case 'monthly':
        const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);
        query = db.collection('users')
            .where('lastGameAt', '>=', admin.firestore.Timestamp.fromDate(monthStart))
            .where('elo', '>', userElo)
            .orderBy('elo', 'desc');
        break;

      case 'total':
      default:
        query = db.collection('users')
            .where('totalGames', '>', 0)
            .where('elo', '>', userElo)
            .orderBy('elo', 'desc');
        break;
    }

    const snapshot = await query.get();
    const rank = snapshot.size + 1;

    // 获取总人数
    let totalQuery;
    switch (leaderboardType) {
      case 'daily':
        const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());
        totalQuery = db.collection('users')
            .where('lastGameAt', '>=', admin.firestore.Timestamp.fromDate(todayStart));
        break;
      case 'weekly':
        const weekStart = new Date(now);
        weekStart.setDate(now.getDate() - now.getDay());
        weekStart.setHours(0, 0, 0, 0);
        totalQuery = db.collection('users')
            .where('lastGameAt', '>=', admin.firestore.Timestamp.fromDate(weekStart));
        break;
      case 'monthly':
        const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);
        totalQuery = db.collection('users')
            .where('lastGameAt', '>=', admin.firestore.Timestamp.fromDate(monthStart));
        break;
      case 'total':
      default:
        totalQuery = db.collection('users').where('totalGames', '>', 0);
        break;
    }

    const totalSnapshot = await totalQuery.get();
    const totalPlayers = totalSnapshot.size;

    return {
      rank: rank,
      totalPlayers: totalPlayers,
      percentile: totalPlayers > 0 ? Math.round((1 - (rank - 1) / totalPlayers) * 100) : 0,
    };
  } catch (error) {
    console.error(`Error getting rank for ${leaderboardType}:`, error);
    return {
      rank: -1,
      totalPlayers: 0,
      percentile: 0,
    };
  }
}

/**
 * 获取天梯分布统计
 */
exports.getLadderDistribution = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
        'unauthenticated',
        'The function must be called while authenticated.',
    );
  }

  try {
    const usersSnapshot = await db.collection('users')
        .where('totalGames', '>', 0)
        .get();

    const distribution = {
      bronze: 0,
      silver: 0,
      gold: 0,
      platinum: 0,
      diamond: 0,
      master: 0,
      grandmaster: 0,
    };

    let totalPlayers = 0;

    usersSnapshot.forEach((doc) => {
      const userData = doc.data();
      const elo = userData.elo || 1200;
      const tier = getLadderTier(elo).tier;

      distribution[tier]++;
      totalPlayers++;
    });

    // 计算百分比
    const distributionWithPercentage = {};
    Object.keys(distribution).forEach((tier) => {
      distributionWithPercentage[tier] = {
        count: distribution[tier],
        percentage: totalPlayers > 0 ?
          Math.round((distribution[tier] / totalPlayers) * 100) : 0,
      };
    });

    return {
      success: true,
      distribution: distributionWithPercentage,
      totalPlayers: totalPlayers,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    };
  } catch (error) {
    console.error('Error getting ladder distribution:', error);
    throw new functions.https.HttpsError(
        'internal',
        'Unable to get ladder distribution.',
    );
  }
});

/**
 * 更新排行榜缓存 (定时任务)
 */
exports.updateLeaderboardCache = functions.https.onCall(async (data, context) => {
  // 这个函数可以用于定期更新排行榜缓存
  // 或者在游戏结束后调用来更新相关排行榜

  if (!context.auth) {
    throw new functions.https.HttpsError(
        'unauthenticated',
        'The function must be called while authenticated.',
    );
  }

  try {
    const now = new Date();
    const leaderboardTypes = ['total', 'daily', 'weekly', 'monthly'];

    for (const type of leaderboardTypes) {
      // 获取前100名并缓存
      const leaderboardData = await exports.getLeaderboard({
        leaderboardType: type,
        limit: 100,
        offset: 0,
      }, context);

      // 将数据存储到缓存集合
      await db.collection('leaderboardCache').doc(type).set({
        data: leaderboardData.leaderboard,
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        type: type,
      });
    }

    return {
      success: true,
      message: 'Leaderboard cache updated successfully',
      updatedTypes: leaderboardTypes,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    };
  } catch (error) {
    console.error('Error updating leaderboard cache:', error);
    throw new functions.https.HttpsError(
        'internal',
        'Unable to update leaderboard cache.',
    );
  }
});

/**
 * 账号恢复 - 数据迁移方案
 * 将原用户数据迁移到当前匿名用户，避免复杂的认证流程
 */
exports.recoverAccountByTransferCode = functions.https.onCall(
    async (data, context) => {
      console.log('=== recoverAccountByTransferCode 数据迁移方案开始 ===');

      // 移除认证检查 - 允许未认证用户调用
      console.log('警告: 此函数允许未认证访问，仅用于账号恢复');

      // 由于没有认证，无法获取当前用户ID，改为返回数据让客户端处理
      let currentUserId = null;
      if (context.auth) {
        currentUserId = context.auth.uid;
        console.log('当前用户ID:', currentUserId);
      } else {
        console.log('未认证用户调用，将返回验证结果');
      }
      console.log('当前用户ID:', currentUserId);

      // 提取 transferCode
      let transferCode = null;
      if (data && typeof data === 'object') {
        if (data.transferCode) {
          transferCode = data.transferCode;
        } else if (data.data && typeof data.data === 'object' && data.data.transferCode) {
          transferCode = data.data.transferCode;
        }
      }

      if (!transferCode) {
        throw new functions.https.HttpsError(
            'invalid-argument',
            'Transfer code is required.',
        );
      }

      console.log('查找引继码:', transferCode);

      try {
        // 1. 查找原用户数据
        const usersSnapshot = await db.collection('users')
            .where('transferCode', '==', transferCode)
            .limit(1)
            .get();

        if (usersSnapshot.empty) {
          console.log('未找到对应的用户');
          throw new functions.https.HttpsError(
              'not-found',
              'Invalid transfer code.',
          );
        }

        const originalUserDoc = usersSnapshot.docs[0];
        const originalUserData = originalUserDoc.data();
        const originalUserId = originalUserDoc.id;

        console.log('找到原用户:', originalUserId, originalUserData.username);

        // 2. 检查是否已经被迁移过
        if (originalUserData.migratedTo) {
          console.log('用户数据已被迁移到:', originalUserData.migratedTo);
          throw new functions.https.HttpsError(
              'already-exists',
              'This transfer code has already been used.',
          );
        }

        // 3. 准备迁移数据
        const migrationData = {
          username: originalUserData.username,
          transferCode: originalUserData.transferCode,
          elo: originalUserData.elo || 1200,
          totalGames: originalUserData.totalGames || 0,
          wins: originalUserData.wins || 0,
          losses: originalUserData.losses || 0,
          winRate: originalUserData.winRate || 0,
          highestScore: originalUserData.highestScore || 0,
          averageScore: originalUserData.averageScore || 0,
          createdAt: originalUserData.createdAt,
          lastLoginAt: admin.firestore.FieldValue.serverTimestamp(),
          // 保留原始创建时间，更新最后登录时间
        };

        console.log('准备迁移数据:', Object.keys(migrationData));


        // 检查是否有认证，未认证用户只返回验证结果
        if (!currentUserId) {
          console.log('未认证用户，返回验证结果，不进行数据迁移');
          const response = {
            success: true,
            message: 'Transfer code validated successfully',
            userData: {
              originalUserId: originalUserId,
              username: originalUserData.username,
              transferCode: originalUserData.transferCode,
              elo: originalUserData.elo || 1200,
              totalGames: originalUserData.totalGames || 0,
              wins: originalUserData.wins || 0,
              losses: originalUserData.losses || 0,
              winRate: originalUserData.winRate || 0,
              highestScore: originalUserData.highestScore || 0,
              averageScore: originalUserData.averageScore || 0,
              createdAt: originalUserData.createdAt,
            },
            requiresAuthentication: true,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
          };
          console.log('返回响应数据:', JSON.stringify(response, null, 2));
          return response;
        }
        // 4. 使用事务进行数据迁移
        await db.runTransaction(async (transaction) => {
          // 获取当前用户文档引用
          const currentUserRef = db.collection('users').doc(currentUserId);
          const originalUserRef = db.collection('users').doc(originalUserId);

          // 检查当前用户是否已有数据
          const currentUserDoc = await transaction.get(currentUserRef);

          if (currentUserDoc.exists) {
            const currentData = currentUserDoc.data();
            // 如果当前用户已有用户名，说明已经设置过，不允许覆盖
            if (currentData.username && currentData.username !== originalUserData.username) {
              throw new functions.https.HttpsError(
                  'already-exists',
                  'Current user already has account data.',
              );
            }
          }

          // 更新当前用户数据
          transaction.set(currentUserRef, migrationData, {merge: true});

          // 标记原用户数据为已迁移
          transaction.update(originalUserRef, {
            migratedTo: currentUserId,
            migratedAt: admin.firestore.FieldValue.serverTimestamp(),
            // 保留原数据但标记为已迁移
          });

          console.log('事务执行完成 - 数据迁移成功');
        });

        // 5. 迁移排行榜数据
        try {
          const leaderboardSnapshot = await db.collection('leaderboards')
              .doc('global')
              .collection('scores')
              .where('userId', '==', originalUserId)
              .get();

          if (!leaderboardSnapshot.empty) {
            const batch = db.batch();
            leaderboardSnapshot.docs.forEach((doc) => {
              const scoreData = doc.data();
              // 更新排行榜记录的用户ID
              batch.update(doc.ref, {
                userId: currentUserId,
                migratedFrom: originalUserId,
                migratedAt: admin.firestore.FieldValue.serverTimestamp(),
              });
            });
            await batch.commit();
            console.log('排行榜数据迁移完成');
          }
        } catch (leaderboardError) {
          console.warn('排行榜数据迁移失败，但不影响主要功能:', leaderboardError);
        }

        // 6. 返回成功结果
        return {
          success: true,
          message: 'Account recovered successfully',
          userData: {
            username: migrationData.username,
            elo: migrationData.elo,
            totalGames: migrationData.totalGames,
            wins: migrationData.wins,
            losses: migrationData.losses,
            winRate: migrationData.winRate,
            highestScore: migrationData.highestScore,
            averageScore: migrationData.averageScore,
          },
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        };
      } catch (error) {
        console.error('账号恢复过程中发生错误:', error);
        if (error instanceof functions.https.HttpsError) {
          throw error;
        }
        throw new functions.https.HttpsError(
            'internal',
            'Unable to recover account. Please try again later.',
        );
      }
    });

