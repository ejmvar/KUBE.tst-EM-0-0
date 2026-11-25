import { playwright } from '@vitest/browser-playwright';
import { defineConfig } from 'vitest/config';

const proxy = {
  '^/api/(?:health(?:/hostname)?)?$': {
    target: process.env.MINIHEALTH_BACKEND_URL || 'http://127.0.0.1:8080',
    changeOrigin: true,
    rewrite: (path) => path.slice('/api'.length),
  },
};

export default defineConfig({
  server: { proxy },
  preview: { proxy },
  test: {
    browser: {
      enabled: true,
      headless: true,
      provider: playwright(),
      instances: [{ browser: 'chromium' }],
    },
  },
});
