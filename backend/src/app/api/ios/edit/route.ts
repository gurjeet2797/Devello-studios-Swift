import { NextRequest, NextResponse } from 'next/server';
import { validateSupabaseAuth } from '@/lib/auth';
import { createGeneralEdit } from '@/lib/gemini';
import type { IOSSingleEditRequest, IOSActionResponse } from '@/types/api';

export const maxDuration = 60; // Gemini can take up to 60 seconds

export async function POST(request: NextRequest) {
  // Validate authentication
  const auth = await validateSupabaseAuth(request);
  if (!auth.authenticated) {
    return NextResponse.json(
      {
        ok: false,
        error: auth.error,
        code: 'UNAUTHORIZED',
      } satisfies IOSActionResponse,
      { status: 401 }
    );
  }

  try {
    // Parse request body
    const body: IOSSingleEditRequest = await request.json();

    if (!body.image_url) {
      return NextResponse.json(
        {
          ok: false,
          error: 'image_url is required',
          code: 'INVALID_REQUEST',
        } satisfies IOSActionResponse,
        { status: 400 }
      );
    }

    if (!body.hotspot) {
      return NextResponse.json(
        {
          ok: false,
          error: 'hotspot is required',
          code: 'INVALID_REQUEST',
        } satisfies IOSActionResponse,
        { status: 400 }
      );
    }

    if (!body.prompt || body.prompt.trim().length === 0) {
      return NextResponse.json(
        {
          ok: false,
          error: 'prompt is required',
          code: 'INVALID_REQUEST',
        } satisfies IOSActionResponse,
        { status: 400 }
      );
    }

    // Create general edit with Gemini (synchronous)
    const result = await createGeneralEdit(body.image_url, body.hotspot, body.prompt);

    if (!result.success) {
      return NextResponse.json(
        {
          ok: false,
          error: result.error || 'Edit processing failed',
          code: 'PROCESSING_ERROR',
        } satisfies IOSActionResponse,
        { status: 500 }
      );
    }

    // Generate a unique request ID
    const requestId = `edit-${Date.now()}-${Math.random().toString(36).substring(7)}`;

    // Return with the data URL as output
    return NextResponse.json({
      ok: true,
      status: 'succeeded',
      output_url: result.imageDataUrl,
      request_id: requestId,
      input_url: body.image_url,
      model: 'gemini-2.0-flash-exp',
    } satisfies IOSActionResponse);
  } catch (error) {
    console.error('Edit prediction error:', error);
    const message = error instanceof Error ? error.message : 'Unknown error';

    return NextResponse.json(
      {
        ok: false,
        error: message,
        code: 'PROCESSING_ERROR',
      } satisfies IOSActionResponse,
      { status: 500 }
    );
  }
}
