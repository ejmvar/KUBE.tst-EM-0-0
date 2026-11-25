import { createRoot } from 'react-dom/client';
import { page } from 'vitest/browser';
import { afterEach, expect, test, vi } from 'vitest';
import { App } from './App.jsx';

let root;
let container;

afterEach(() => {
  root?.unmount();
  container?.remove();
  vi.unstubAllGlobals();
});

function renderApp(responses, statuses = {}) {
  vi.stubGlobal('fetch', async (path) => {
    if (!Object.hasOwn(responses, path)) throw new Error(`Unexpected request: ${path}`);
    return new Response(responses[path], { status: statuses[path] });
  });
  container = document.createElement('div');
  document.body.append(container);
  root = createRoot(container);
  root.render(<App />);
}

function responseFor(path) {
  return page.getByRole('region', { name: path, exact: true }).getByRole('status');
}

const responses = {
  '/api/': 'A sample joke.\n(Served by: backend-demo)\n',
  '/api/health': 'Ok',
  '/api/health/hostname': '(Served by: backend-demo)\n',
};

test('shows the response under each backend route', async () => {
  renderApp(responses);

  await expectAllResponses();
});

async function expectAllResponses() {
  await expect.element(responseFor('/').getByText('A sample joke. (Served by: backend-demo)', { exact: true })).toBeVisible();
  await expect.element(responseFor('/health').getByText('Ok', { exact: true })).toBeVisible();
  await expect.element(responseFor('/health/hostname').getByText('(Served by: backend-demo)', { exact: true })).toBeVisible();
}

test('renders the desktop response list', async () => {
  await page.viewport(1024, 768);
  renderApp(responses);

  await expectAllResponses();
  await expect.element(page.getByRole('main')).toMatchScreenshot('desktop');
});

test('shows a failed check without hiding other responses on mobile', async () => {
  const hostname = '(Served by: backend-deployment-abcdefghij-0123456789)';
  await page.viewport(375, 667);
  renderApp({ ...responses, '/api/health/hostname': hostname }, { '/api/health': 503 });

  await expect.element(responseFor('/').getByText('A sample joke. (Served by: backend-demo)', { exact: true })).toBeVisible();
  await expect.element(responseFor('/health').getByText('HTTP 503', { exact: true })).toBeVisible();
  await expect.element(responseFor('/health/hostname').getByText(hostname, { exact: true })).toBeVisible();
  expect(document.documentElement.scrollWidth).toBeLessThanOrEqual(375);
  await expect.element(page.getByRole('main')).toMatchScreenshot('mobile-health-error');
});
