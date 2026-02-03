import { NextResponse } from 'next/server';
import { createLightingEdit } from '@/lib/gemini';
import type { IOSLightingRequest } from '@/types/api';

const MAX_IMAGE_BASE64_BYTES = 6_000_000; // ~6MB base64 payload

function jsonError(message: string, status: number) {
  return NextResponse.json({ ok: false, error: message }, { status });
}

function isLikelyBase64(value: string) {
  return /^[A-Za-z0-9+/=\n\r]+$/.test(value);
}

export async function POST(request: Request) {
  let body: IOSLightingRequest;
  try {
    body = (await request.json()) as IOSLightingRequest;
  } catch {
    return jsonError('Invalid JSON body', 400);
  }

  if (!body?.image_base64 || typeof body.image_base64 !== 'string') {
    return jsonError('Missing image_base64', 400);
  }

  if (body.image_base64.length > MAX_IMAGE_BASE64_BYTES) {
    return jsonError('image_base64 payload too large', 413);
  }

  if (!isLikelyBase64(body.image_base64)) {
    return jsonError('image_base64 must be base64 encoded', 400);
  }

  const style = typeof body.style === 'string' ? body.style : 'Dramatic Daylight';

  const result = await createLightingEdit(body.image_base64, style);
  if (!result.success || !result.imageBase64) {
    return jsonError(result.error ?? 'Lighting edit failed', 500);
  }

  return NextResponse.json({ ok: true, image_base64: result.imageBase64 });
}
