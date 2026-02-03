type Idea = {
  id: string;
  text: string;
  status?: string | null;
  source?: string | null;
  created_at?: string | null;
  user_id?: string | null;
};

async function fetchIdeas(): Promise<{ ideas: Idea[]; error?: string }> {
  const supabaseUrl = process.env.SUPABASE_URL;
  const supabaseAnonKey = process.env.SUPABASE_ANON_KEY;

  if (!supabaseUrl || !supabaseAnonKey) {
    return { ideas: [], error: 'Missing SUPABASE_URL or SUPABASE_ANON_KEY' };
  }

  const url = new URL('/rest/v1/ideas', supabaseUrl);
  url.searchParams.set('select', 'id,text,status,source,created_at,user_id');
  url.searchParams.set('order', 'created_at.desc');
  url.searchParams.set('limit', '50');

  const response = await fetch(url, {
    headers: {
      apikey: supabaseAnonKey,
      Authorization: `Bearer ${supabaseAnonKey}`,
    },
    cache: 'no-store',
  });

  if (!response.ok) {
    const text = await response.text();
    return { ideas: [], error: text || 'Failed to load ideas' };
  }

  const ideas = (await response.json()) as Idea[];
  return { ideas };
}

export default async function IdeasPage() {
  const { ideas, error } = await fetchIdeas();

  return (
    <main style={{ padding: '2rem', fontFamily: 'system-ui, sans-serif' }}>
      <h1>Devello Ideas</h1>
      <p>Latest submissions from the Devello Studios community.</p>

      {error ? (
        <div style={{ marginTop: '1rem', color: 'crimson' }}>{error}</div>
      ) : null}

      <div style={{ marginTop: '1.5rem', display: 'grid', gap: '1rem' }}>
        {ideas.length === 0 && !error ? (
          <div>No ideas yet. Be the first to submit one!</div>
        ) : null}

        {ideas.map((idea) => (
          <div
            key={idea.id}
            style={{
              border: '1px solid #e5e7eb',
              borderRadius: '12px',
              padding: '1rem',
              background: '#ffffff',
            }}
          >
            <div style={{ fontSize: '1rem', fontWeight: 600 }}>{idea.text}</div>
            <div style={{ marginTop: '0.5rem', fontSize: '0.85rem', color: '#6b7280' }}>
              Status: {idea.status ?? 'submitted'}
            </div>
            <div style={{ marginTop: '0.25rem', fontSize: '0.8rem', color: '#9ca3af' }}>
              Source: {idea.source ?? 'unknown'}
            </div>
          </div>
        ))}
      </div>
    </main>
  );
}
