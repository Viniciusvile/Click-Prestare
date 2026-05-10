const admin = require('firebase-admin');
const path = require('path');

const serviceAccount = require(path.resolve(__dirname, '../configs/firebase-service-account.json'));

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

module.exports = {
  async sendToTokens(tokens, title, body, data) {
    if (!tokens || tokens.length === 0) return;
    
    const message = {
      notification: { title, body },
      tokens: tokens,
      data: data || {},
    };

    try {
      const response = await admin.messaging().sendMulticast(message);
      console.log(`${response.successCount} messages were sent successfully`);
      return response;
    } catch (error) {
      console.error('Error sending multicast message:', error);
    }
  }
};
