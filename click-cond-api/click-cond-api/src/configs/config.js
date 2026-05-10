module.exports = {
    jwt: {
      secretKey: process.env.JWT_SECRET || 'fallback-secret-for-dev-only',
    },
    defaults: {
      userimage: 'https://www.shutterstock.com/image-vector/default-avatar-profile-icon-social-600nw-1906669723.jpg',
    }
  };
  