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
  const uid = data.uid;

  if (!uid) {
    throw new functions.https.HttpsError(
        "invalid-argument",
        "The function must be called with a \"uid\" argument.",
    );
  }

  if (context.auth && context.auth.uid !== uid) {
    throw new functions.https.HttpsError(
        "permission-denied",
        "You do not have permission to delete this user.",
    );
  }

  try {
    const userDocRef = db.collection("users").doc(uid);
    await userDocRef.delete();

    await admin.auth().deleteUser(uid);

    console.log(`Successfully deleted user data for UID: ${uid}`);
    return {success: true, message: "User data deleted successfully."};
  } catch (error) {
    console.error(`Error deleting user data for UID ${uid}:`, error);
    throw new functions.https.HttpsError(
        "internal",
        "Unable to delete user data.",
        error,
    );
  }
});
