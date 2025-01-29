module.exports = {
  testEnvironment: 'jsdom',
  setupFilesAfterEnv: [
    '<rootDir>/tests/testUtils.js',
    '@testing-library/jest-dom/extend-expect'
  ],
  testMatch: ['<rootDir>/tests/e2e/**/*.test.js'],
};
