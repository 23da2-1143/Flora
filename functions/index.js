// Firebase Functions to assign admin role to a user by email
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.addAdmin = functions.https.onCall(async (data, context) => {
  // Only allow authenticated users (you may restrict further)
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Request has no authentication.');
  }

  const email = data.email;
  if (!email) {
    throw new functions.https.HttpsError('invalid-argument', 'Email is required.');
  }

  try {
    const user = await admin.auth().getUserByEmail(email);
    // Set custom claim "admin": true
    await admin.auth().setCustomUserClaims(user.uid, { admin: true });
    return { message: `Admin claim set for ${email}` };
  } catch (error) {
    console.error('Error setting admin claim:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});
