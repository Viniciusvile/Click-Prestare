const path = require('path');

const levels = {
  ERROR: 0,
  WARN: 1,
  INFO: 2,
  DEBUG: 3,
};

const currentLevel = process.env.LOG_LEVEL || 'INFO';

function log(level, message, ...args) {
  if (levels[level] <= levels[currentLevel]) {
    const timestamp = new Date().toISOString();
    console.log(`[${timestamp}] [${level}] ${message}`, ...args);
  }
}

module.exports = {
  info: (msg, ...args) => log('INFO', msg, ...args),
  error: (msg, ...args) => log('ERROR', msg, ...args),
  warn: (msg, ...args) => log('WARN', msg, ...args),
  debug: (msg, ...args) => log('DEBUG', msg, ...args),
};
