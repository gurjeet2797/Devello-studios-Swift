export default function Home() {
  return (
    <main style={{ padding: '2rem', fontFamily: 'system-ui, sans-serif' }}>
      <h1>Devello iOS Backend</h1>
      <p>API endpoints available:</p>
      <ul>
        <li><code>POST /api/ios/lighting</code> - Create lighting prediction</li>
        <li><code>POST /api/ios/edit</code> - Create general edit</li>
      </ul>
      <p style={{ marginTop: '1rem' }}>
        View community ideas at <a href="/ideas">/ideas</a>.
      </p>
    </main>
  );
}
