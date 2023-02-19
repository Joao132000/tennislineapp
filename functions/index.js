const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Delete messages older than 30 days from the "posts" collection
exports.deleteOldPosts = functions.pubsub.schedule('every 24 hours').onRun(async (context) => {
  const cutoff = Date.now() - (30 * 24 * 60 * 60 * 1000); // Calculate cutoff time (30 days ago)
  const snapshot = await admin.firestore().collection('posts').where('timeStamp', '<', cutoff).get(); // Get all posts older than cutoff time
  const batch = admin.firestore().batch(); // Create batch operation to delete posts
  snapshot.forEach((doc) => batch.delete(doc.ref)); // Add each post to the batch operation
  return batch.commit(); // Commit the batch operation to delete all posts
});

