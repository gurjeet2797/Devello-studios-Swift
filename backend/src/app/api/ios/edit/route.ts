import { NextResponse } from 'next/server';
import { createGeneralEdit } from '@/lib/gemini';
import type { IOSSingleEditRequest } from '@/types/api';

const MAX_IMAGE_BASE64_BYTES = 6_000_000; // ~6MB base64 payload

function jsonError(message: string, status: number) {
  return NextResponse.json({ ok: false, error: message }, { status });
}

function isLikelyBase64(value: string) {
  return /^[A-Za-z0-9+/=\n\r]+$/.test(value);
}

export async function POST(request: Request) {
  let body: IOSSingleEditRequest;
  try {
    body = (await request.json()) as IOSSingleEditRequest;
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

  if (!body?.hotspot || typeof body.hotspot.x !== 'number' || typeof body.hotspot.y !== 'number') {
    return jsonError('Missing hotspot coordinates', 400);
  }

  const { x, y } = body.hotspot;
  if (x < 0 || x > 1 || y < 0 || y > 1) {
    return jsonError('Hotspot coordinates must be between 0 and 1', 400);
  }

  if (!body?.prompt || typeof body.prompt !== 'string' || body.prompt.trim().length === 0) {
    return jsonError('Missing prompt', 400);
  }

  const result = await createGeneralEdit(body.image_base64, { x, y }, body.prompt);
  if (!result.success || !result.imageBase64) {
    return jsonError(result.error ?? 'Edit failed', 500);
  }

  return NextResponse.json({ ok: true, image_base64: result.imageBase64 });
}
