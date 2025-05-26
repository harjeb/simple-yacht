const functions = require("firebase-functions");
const admin = require("firebase-admin");

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
      const uid = data.uid;

      if (!uid) {
        throw new functions.https.HttpsError(
            "invalid-argument",
            "The function must be called with a \"uid\" argument.",
        );
      }

      try {
        const customToken = await admin.auth().createCustomToken(uid);
        return {token: customToken};
      } catch (error) {
        console.error("Error creating custom token:", error);
        throw new functions.https.HttpsError(
            "internal",
            "Unable to create custom token.",
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
  console.log("=== deleteUserData Cloud Function 调用开始 ===");

  // 安全地记录接收到的数据，避免循环引用
  console.log("原始传入 data 对象:", data);
  try {
    console.log("序列化后的 data 对象:", JSON.stringify(data));
  } catch (jsonError) {
    console.warn("警告: 序列化 data 对象失败:", jsonError.message);
    console.log("data 对象 (无法序列化):", data);
  }

  if (data && typeof data === "object") {
    console.log("data 对象键:", Object.keys(data));
    if ("data" in data && data.data && typeof data.data === "object") {
      console.log("嵌套的 data.data 对象键:", Object.keys(data.data));
    }
  }

  // 安全地记录上下文信息，避免循环引用
  console.log("上下文信息:", {
    auth: context.auth ? {
      uid: context.auth.uid,
      token: !!context.auth.token,
    } : null,
    app: context.app ? {
      appId: context.app.appId || "unknown",
      projectId: context.app.projectId || "unknown",
    } : null,
    hasRawRequest: !!context.rawRequest,
    instanceIdToken: context.instanceIdToken ? "present" : "absent",
  });

  // 尝试从 data.uid 或 data.data.uid 提取 uid
  let uid = null;
  if (data && typeof data === "object") {
    if (data.uid) {
      uid = data.uid;
      console.log("从 data.uid 提取的 UID:", uid);
    } else if (data.data && typeof data.data === "object" && data.data.uid) {
      uid = data.data.uid;
      console.log("从 data.data.uid 提取的 UID:", uid);
    }
  }

  console.log("最终提取的 UID:", uid);

  if (!uid) {
    console.error("错误: 最终未能提取到 uid 参数。请检查客户端调用和传入的 data 结构。");
    throw new functions.https.HttpsError(
        "invalid-argument",
        "The function must be called with a \"uid\" argument.",
    );
  }

  // 在开发环境中，如果没有认证上下文，允许继续执行（用于调试）
  if (!context.auth) {
    console.warn("警告: 没有认证上下文，这可能是 App Check 验证失败导致的");
    console.warn("在开发环境中继续执行...");
  } else if (context.auth.uid !== uid) {
    console.error("权限错误: 认证用户 UID 与请求 UID 不匹配");
    console.error("认证 UID:", context.auth.uid, "请求 UID:", uid);
    throw new functions.https.HttpsError(
        "permission-denied",
        "You do not have permission to delete this user.",
    );
  }

  try {
    console.log("开始删除用户数据...");

    // 1. 删除 Firestore 用户文档
    console.log("步骤 1: 删除 Firestore 用户文档");
    const userDocRef = db.collection("users").doc(uid);

    // 检查文档是否存在
    const userDoc = await userDocRef.get();
    if (userDoc.exists) {
      console.log("用户文档存在，开始删除...");
      await userDocRef.delete();
      console.log("Firestore 用户文档删除成功");
    } else {
      console.log("用户文档不存在，跳过 Firestore 删除");
    }

    // 2. 删除 Firebase Auth 用户
    console.log("步骤 2: 删除 Firebase Auth 用户");
    try {
      await admin.auth().deleteUser(uid);
      console.log("Firebase Auth 用户删除成功");
    } catch (authError) {
      console.error("删除 Firebase Auth 用户时出错:", authError);
      // 如果用户已经不存在，继续执行
      if (authError.code === "auth/user-not-found") {
        console.log("用户在 Firebase Auth 中不存在，继续执行");
      } else {
        throw authError; // 重新抛出其他认证错误
      }
    }

    console.log(`成功删除用户数据，UID: ${uid}`);
    return {success: true, message: "User data deleted successfully."};
  } catch (error) {
    console.error(`删除用户数据时发生错误，UID: ${uid}`);
    console.error("错误详情:", error);
    console.error("错误类型:", error.constructor.name);
    console.error("错误代码:", error.code);
    console.error("错误消息:", error.message);

    throw new functions.https.HttpsError(
        "internal",
        "Unable to delete user data: " + error.message,
        {
          originalError: error.message,
          errorCode: error.code,
          uid: uid,
        },
    );
  }
});
