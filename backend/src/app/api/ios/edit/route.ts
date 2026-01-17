import { NextRequest, NextResponse } from 'next/server';
import { createGeneralEdit } from '@/lib/gemini';
import type { IOSSingleEditRequest, IOSActionResponse } from '@/types/api';

export const maxDuration = 60;

export async function POST(request: NextRequest) {
  try {
    const body: IOSSingleEditRequest = await request.json();

    if (!body.image_base64) {
      return NextResponse.json(
        {
          ok: false,
          error: 'image_base64 is required',
        } satisfies IOSActionResponse,
        { status: 400 }
      );
    }

    if (!body.hotspot) {
      return NextResponse.json(
        {
          ok: false,
          error: 'hotspot is required',
        } satisfies IOSActionResponse,
        { status: 400 }
      );
    }

    if (!body.prompt || body.prompt.trim().length === 0) {
      return NextResponse.json(
        {
          ok: false,
          error: 'prompt is required',
        } satisfies IOSActionResponse,
        { status: 400 }
      );
    }

    const result = await createGeneralEdit(body.image_base64, body.hotspot, body.prompt);

    if (!result.success) {
      return NextResponse.json(
        {
          ok: false,
          error: result.error || 'Edit processing failed',
        } satisfies IOSActionResponse,
        { status: 500 }
      );
    }

    return NextResponse.json({
      ok: true,
      image_base64: result.imageBase64,
    } satisfies IOSActionResponse);
  } catch (error) {
    console.error('Edit error:', error);
    const message = error instanceof Error ? error.message : 'Unknown error';

    return NextResponse.json(
      {
        ok: false,
        error: message,
      } satisfies IOSActionResponse,
      { status: 500 }
    );
  }
}
