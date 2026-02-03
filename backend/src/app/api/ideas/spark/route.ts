import { NextResponse } from 'next/server';
import { createIdeaSpark } from '@/lib/gemini';

function jsonError(message: string, status: number) {
  return NextResponse.json({ ok: false, error: message }, { status });
}

export async function POST(request: Request) {
  let body: { idea?: string };
  try {
    body = (await request.json()) as { idea?: string };
  } catch {
    return jsonError('Invalid JSON body', 400);
  }

  const idea = typeof body.idea === 'string' ? body.idea.trim() : '';
  if (!idea) {
    return jsonError('Missing idea', 400);
  }

  const result = await createIdeaSpark(idea);
  if (!result.success || !result.text) {
    return jsonError(result.error ?? 'Idea spark failed', 500);
  }

  return NextResponse.json({ ok: true, draft: result.text });
}
