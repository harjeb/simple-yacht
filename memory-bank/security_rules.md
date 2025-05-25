# Firestore 安全规则

## 设计原则

*   **默认拒绝**: 所有路径默认不允许读写，除非明确授权。
*   **最小权限**: 用户和服务仅被授予执行其预期功能所必需的权限。
*   **用户数据隔离**: 用户只能访问和修改自己的数据。
*   **认证要求**: 大多数写操作和敏感读操作都需要用户认证。
*   **数据验证**: 在规则层面进行基本的数据类型、格式和值验证。复杂验证和唯一性约束建议通过 Cloud Functions 实现。

## Firestore 安全规则

```firestore
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    // 用户集合
    match /users/{userId} {
      // 允许用户读取自己的数据
      allow read: if request.auth != null && request.auth.uid == userId;

      // 允许新用户创建自己的文档 (注册)
      // 确保创建者是文档的所有者
      // 确保提供了必要的字段 (例如 username, transferCode, createdAt)
      // 确保 transferCode 格式正确 (如果需要)
      allow create: if request.auth != null && request.auth.uid == userId
                      && request.resource.data.containsKey('username')
                      && request.resource.data.username is string
                      && request.resource.data.username.size() > 0
                      && request.resource.data.username.size() <= 50 // 示例长度限制
                      && request.resource.data.containsKey('transferCode')
                      && request.resource.data.transferCode is string
                      // && request.resource.data.transferCode.matches('^[A-Z0-9]{18}$') // 如果引继码有固定格式
                      && request.resource.data.containsKey('createdAt')
                      && request.resource.data.createdAt == request.time; // 强制服务器时间戳

      // 允许用户更新自己的数据
      // 不允许修改 createdAt 或 transferCode (如果这些是服务器管理的或一次性设置的)
      allow update: if request.auth != null && request.auth.uid == userId
                      && !('createdAt' in request.resource.data) // 不允许客户端修改 createdAt
                      && !('transferCode' in request.resource.data && request.resource.data.transferCode != resource.data.transferCode); // 如果引继码不允许修改

      // 通常不直接允许客户端删除用户文档，应通过 Cloud Function 处理
      allow delete: if false;
    }

    // 排行榜集合 (假设集合名为 'scores')
    // 可以根据实际情况调整为 'leaderboard'
    match /scores/{scoreId} {
      // 允许任何人读取排行榜
      allow read: if true;

      // 只允许认证用户创建新的分数条目
      // 验证提交的数据
      allow create: if request.auth != null
                      && request.resource.data.userId == request.auth.uid // 分数必须与当前用户关联
                      && request.resource.data.score is number // 分数必须是数字
                      && request.resource.data.score >= 0       // 分数不能为负
                      && request.resource.data.containsKey('username') // 必须包含用户名
                      && request.resource.data.username is string
                      && request.resource.data.containsKey('timestamp')
                      && request.resource.data.timestamp == request.time; // 强制服务器时间戳

      // 通常不允许用户修改或删除排行榜条目
      allow update: if false;
      allow delete: if false;
    }

    // 备用排行榜集合名称 (如果使用 'leaderboard' 而不是 'scores')
    match /leaderboard/{scoreId} {
       allow read: if true;
       allow create: if request.auth != null
                      && request.resource.data.userId == request.auth.uid
                      && request.resource.data.score is number
                      && request.resource.data.score >= 0
                      && request.resource.data.containsKey('username')
                      && request.resource.data.username is string
                      && request.resource.data.containsKey('timestamp')
                      && request.resource.data.timestamp == request.time;
      allow update: if false;
      allow delete: if false;
    }
  }
}
```

## 补充说明：Cloud Functions

对于安全规则难以直接实现的复杂逻辑，建议使用 Cloud Functions：

*   **用户名唯一性检查**: 在用户创建或用户名更新时，通过 Cloud Function 查询数据库以确保唯一性。
*   **引继码唯一性检查**: 类似于用户名，在生成和分配引继码时，通过 Cloud Function 保证其唯一性。
*   **复杂数据验证**: 例如，如果分数提交有更复杂的规则（如基于用户等级的最高分数限制），这些也更适合在 Cloud Function 中处理。
*   **原子操作**: 对于需要原子性（例如，更新用户统计数据和写入排行榜条目必须同时成功或失败）的操作，Cloud Functions 提供了更好的事务控制能力。
*   **用户账户删除**: 安全地删除用户账户及其所有相关数据应通过 Cloud Function 执行，以确保数据一致性和完整性。

**时间戳:**
*   [2025-05-25 12:03:05] - 创建 Firestore 安全规则文档。