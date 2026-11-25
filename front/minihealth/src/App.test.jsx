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

function renderApp(responses) {
  vi.stubGlobal('fetch', async (path) => {
    if (!Object.hasOwn(responses, path)) throw new Error(`Unexpected request: ${path}`);
    return new Response(responses[path]);
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

  await expect.element(responseFor('/').getByText('A sample joke. (Served by: backend-demo)', { exact: true })).toBeVisible();
  await expect.element(responseFor('/health').getByText('Ok', { exact: true })).toBeVisible();
  await expect.element(responseFor('/health/hostname').getByText('(Served by: backend-demo)', { exact: true })).toBeVisible();
});
