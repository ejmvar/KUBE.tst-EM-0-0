import { useEffect, useState } from 'react';
import './style.css';

const paths = ['/', '/health', '/health/hostname'];

function Endpoint({ path, index }) {
  const [result, setResult] = useState(null);

  useEffect(() => {
    const controller = new AbortController();

    async function check() {
      try {
        const response = await fetch(`/api${path}`, {
          signal: controller.signal,
          cache: 'no-store',
        });
        const text = response.ok ? (await response.text()).trimEnd() : '';
        if (!controller.signal.aborted) {
          setResult({ status: `HTTP ${response.status}`, text, failed: !response.ok });
        }
      } catch {
        if (!controller.signal.aborted) {
          setResult({ status: 'Request failed', text: '', failed: true });
        }
      }
    }

    check();
    return () => controller.abort();
  }, [path]);

  const id = `endpoint-${index}`;

  return (
    <section aria-labelledby={id}>
      <h2 id={id}><code>{path}</code></h2>
      <div role="status">
        <p className={result?.failed ? 'http-status error' : 'http-status'}>
          {result?.status ?? 'Loading…'}
        </p>
        {result?.text ? <pre>{result.text}</pre> : null}
      </div>
    </section>
  );
}

export function App() {
  return (
    <main>
      <header>
        <h1>Minihealth</h1>
        <p>Responses from the backend.</p>
      </header>
      {paths.map((path, index) => <Endpoint key={path} path={path} index={index} />)}
    </main>
  );
}
