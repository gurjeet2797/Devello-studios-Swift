import { NextRequest, NextResponse } from 'next/server';
import { validateSupabaseAuth } from '@/lib/auth';
import { createLightingPrediction } from '@/lib/replicate';
import type { IOSLightingRequest, IOSActionResponse } from '@/types/api';

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
    const body: IOSLightingRequest = await request.json();

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

    // Default to Dramatic Daylight if no style specified
    const style = body.style || 'Dramatic Daylight';

    // Create Replicate prediction
    const prediction = await createLightingPrediction(body.image_url, style);

    // Return immediately with job ID for polling
    return NextResponse.json({
      ok: true,
      status: 'processing',
      job_id: prediction.id,
      request_id: prediction.id,
      input_url: body.image_url,
      model: 'flux-kontext-max',
    } satisfies IOSActionResponse);
  } catch (error) {
    console.error('Lighting prediction error:', error);
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
