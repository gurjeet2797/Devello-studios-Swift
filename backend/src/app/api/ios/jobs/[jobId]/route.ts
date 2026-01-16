import { NextRequest, NextResponse } from 'next/server';
import { validateSupabaseAuth } from '@/lib/auth';
import { getPredictionStatus } from '@/lib/replicate';
import type { IOSJobResponse } from '@/types/api';

interface RouteContext {
  params: Promise<{ jobId: string }>;
}

export async function GET(request: NextRequest, context: RouteContext) {
  // Validate authentication
  const auth = await validateSupabaseAuth(request);
  if (!auth.authenticated) {
    return NextResponse.json(
      {
        ok: false,
        error: auth.error,
        code: 'UNAUTHORIZED',
      } satisfies IOSJobResponse,
      { status: 401 }
    );
  }

  try {
    const { jobId } = await context.params;

    if (!jobId) {
      return NextResponse.json(
        {
          ok: false,
          error: 'Job ID is required',
          code: 'INVALID_REQUEST',
        } satisfies IOSJobResponse,
        { status: 400 }
      );
    }

    // Get prediction status from Replicate
    const prediction = await getPredictionStatus(jobId);

    // Map Replicate status to iOS expected format
    let status: string;
    switch (prediction.status) {
      case 'starting':
      case 'processing':
        status = 'processing';
        break;
      case 'succeeded':
        status = 'succeeded';
        break;
      case 'failed':
      case 'canceled':
        status = 'failed';
        break;
      default:
        status = 'processing';
    }

    // Extract output URL
    let outputUrl: string | undefined;
    if (prediction.output) {
      if (typeof prediction.output === 'string') {
        outputUrl = prediction.output;
      } else if (Array.isArray(prediction.output) && prediction.output.length > 0) {
        outputUrl = prediction.output[0];
      }
    }

    return NextResponse.json({
      ok: true,
      status: status,
      output_url: outputUrl,
      request_id: prediction.id,
      job_id: prediction.id,
      error: prediction.error,
    } satisfies IOSJobResponse);
  } catch (error) {
    console.error('Job status error:', error);
    const message = error instanceof Error ? error.message : 'Unknown error';

    return NextResponse.json(
      {
        ok: false,
        error: message,
        code: 'PROCESSING_ERROR',
      } satisfies IOSJobResponse,
      { status: 500 }
    );
  }
}
