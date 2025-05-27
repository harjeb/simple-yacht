exports.recoverAccountByTransferCode = functions.https.onCall(
    async (data, context) => {
      console.log('=== recoverAccountByTransferCode 数据迁移方案开始 ===');
      
      // 验证用户已认证
      if (!context.auth) {
        throw new functions.https.HttpsError(
            'unauthenticated',
            'The function must be called while authenticated.',
        );
      }

      const currentUserId = context.auth.uid;
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
          transaction.set(currentUserRef, migrationData, { merge: true });

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

