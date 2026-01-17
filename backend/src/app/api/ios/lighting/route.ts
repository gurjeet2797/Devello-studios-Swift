import { NextRequest, NextResponse } from 'next/server';
import { createLightingEdit } from '@/lib/gemini';
import type { IOSLightingRequest, IOSActionResponse } from '@/types/api';

export const maxDuration = 60;

export async function POST(request: NextRequest) {
  try {
    const body: IOSLightingRequest = await request.json();

    if (!body.image_base64) {
      return NextResponse.json(
        {
          ok: false,
          error: 'image_base64 is required',
        } satisfies IOSActionResponse,
        { status: 400 }
      );
    }

    const style = body.style || 'Dramatic Daylight';
    const result = await createLightingEdit(body.image_base64, style);

    if (!result.success) {
      return NextResponse.json(
        {
          ok: false,
          error: result.error || 'Lighting processing failed',
        } satisfies IOSActionResponse,
        { status: 500 }
      );
    }

    return NextResponse.json({
      ok: true,
      image_base64: result.imageBase64,
    } satisfies IOSActionResponse);
  } catch (error) {
    console.error('Lighting error:', error);
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
