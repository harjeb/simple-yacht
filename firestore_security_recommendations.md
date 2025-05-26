# Firestore 安全规则改进建议

## 🚨 紧急修复项

### 1. 排行榜读取权限限制
```javascript
// 当前 (危险)
allow read: true;

// 建议修改为
allow read: if request.auth != null;
```

### 2. transferCode 查询权限收紧
```javascript
// 建议移除或严格限制
// allow list: if false; // 完全禁用
// 或者仅允许 Cloud Function 访问
```

### 3. 时间戳验证强化
```javascript
allow create: if request.auth != null
                && request.resource.data.userId == request.auth.uid
                && request.resource.data.score is number
                && request.resource.data.score >= 0
                && request.resource.data.score <= 1000 // 添加合理上限
                && 'username' in request.resource.data
                && request.resource.data.username is string
                && request.resource.data.username.size() > 0
                && request.resource.data.username.size() <= 50
                && 'timestamp' in request.resource.data
                && request.resource.data.timestamp == request.time; // 强制服务器时间
```

## 🔒 生产环境安全规则

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    // 用户集合 - 严格权限控制
    match /users/{userId} {
      // 仅允许用户读取自己的数据
      allow read: if request.auth != null && request.auth.uid == userId;

      // 禁用 transferCode 查询 - 通过 Cloud Function 处理
      allow list: if false;

      // 用户创建 - 增强验证
      allow create: if request.auth != null 
                      && request.auth.uid == userId
                      && 'username' in request.resource.data
                      && request.resource.data.username is string
                      && request.resource.data.username.size() > 0
                      && request.resource.data.username.size() <= 50
                      && request.resource.data.username.matches('^[a-zA-Z0-9_\\-\\.]{1,50}$') // 用户名格式验证
                      && 'transferCode' in request.resource.data
                      && request.resource.data.transferCode is string
                      && request.resource.data.transferCode.matches('^[A-Z0-9]{18}$')
                      && 'createdAt' in request.resource.data;

      // 用户更新 - 防止关键字段修改
      allow update: if request.auth != null 
                      && request.auth.uid == userId
                      && !('createdAt' in request.resource.data)
                      && !('transferCode' in request.resource.data);

      allow delete: if false;
    }

    // 排行榜集合 - 安全访问控制
    match /leaderboards/{leaderboardId}/scores/{scoreId} {
      // 仅认证用户可读取排行榜
      allow read: if request.auth != null;

      // 分数创建 - 严格验证
      allow create: if request.auth != null
                      && request.resource.data.userId == request.auth.uid
                      && request.resource.data.score is number
                      && request.resource.data.score >= 0
                      && request.resource.data.score <= 1000 // 游戏分数上限
                      && 'username' in request.resource.data
                      && request.resource.data.username is string
                      && request.resource.data.username.size() > 0
                      && request.resource.data.username.size() <= 50
                      && request.resource.data.username.matches('^[a-zA-Z0-9_\\-\\.]{1,50}$')
                      && 'timestamp' in request.resource.data
                      && request.resource.data.timestamp == request.time; // 强制服务器时间

      allow update: if false;
      allow delete: if false;
    }
  }
}
```

## 🔧 代码修改建议

### 1. 服务器端时间戳使用
在 `leaderboard_service.dart` 中：
```dart
// 当前
'timestamp': Timestamp.now(),

// 建议修改为
'timestamp': FieldValue.serverTimestamp(),
```

### 2. transferCode 查询通过 Cloud Function
创建专用的 Cloud Function 处理 transferCode 验证，避免客户端直接查询。

## 📋 部署检查清单

- [ ] 更新 firestore.rules 文件
- [ ] 部署安全规则：`firebase deploy --only firestore:rules`
- [ ] 验证索引配置
- [ ] 测试认证用户访问
- [ ] 测试未认证用户访问被拒绝
- [ ] 验证分数提交限制
- [ ] 测试时间戳验证

## ⚠️ 风险评估

**当前风险等级：高**
- 数据泄露风险：高
- 恶意操作风险：中
- 性能影响风险：低

**修复后风险等级：低**
- 数据泄露风险：低
- 恶意操作风险：低
- 性能影响风险：低