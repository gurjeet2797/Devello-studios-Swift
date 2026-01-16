import { jwtVerify } from 'jose';
import { NextRequest } from 'next/server';

export interface AuthResult {
  authenticated: boolean;
  userId?: string;
  error?: string;
}

export async function validateSupabaseAuth(request: NextRequest): Promise<AuthResult> {
  const authHeader = request.headers.get('authorization');

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return {
      authenticated: false,
      error: 'Missing or invalid Authorization header',
    };
  }

  const token = authHeader.substring(7);

  const jwtSecret = process.env.SUPABASE_JWT_SECRET;
  if (!jwtSecret) {
    console.error('SUPABASE_JWT_SECRET not configured');
    return {
      authenticated: false,
      error: 'Server configuration error',
    };
  }

  try {
    const secret = new TextEncoder().encode(jwtSecret);
    const { payload } = await jwtVerify(token, secret, {
      issuer: process.env.SUPABASE_URL,
    });

    return {
      authenticated: true,
      userId: payload.sub,
    };
  } catch (error) {
    console.error('JWT verification failed:', error);
    return {
      authenticated: false,
      error: 'Invalid or expired token',
    };
  }
}
