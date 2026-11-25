# Minihealth

A single React page that shows the HTTP status and successful response body
for the backend's `/`, `/health`, and `/health/hostname` endpoints.

## Run locally

1. From the repository root, start Flask with `make backend-local-serve`.
2. With Node.js 22.12+ on the 22.x line, 24.x, or 26+, run:

   ```sh
   cd front/minihealth
   npm ci
   npm run dev
   ```

3. Open the URL printed by Vite.

Vite forwards `/api/`, `/api/health`, and `/api/health/hostname` to Flask
without the `/api` prefix. It defaults to `http://127.0.0.1:8080`.
Set `MINIHEALTH_BACKEND_URL` when starting Vite to use a different backend
origin. `npm run build` produces static files in `dist/`. Vite preview uses
the same proxy; a production host serving `dist/` must provide its own
equivalent `/api` routing.

## Test and review visual changes

From this directory:

```sh
npx playwright install chromium
npm test
```

Tests run in headless Chromium and use fixed responses, so Flask does not
need to be running. The checked-in Linux baselines cover desktop success and
a mobile health failure. Compare on Linux for consistent rendering.
After an intentional UI change, run `npm test -- --update` and review the
changed PNGs in `src/__screenshots__/` before accepting them.
