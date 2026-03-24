/**
 * Supabase client factory for Edge Functions.
 * Provides both user-scoped and admin (service role) clients.
 */

import { createClient, SupabaseClient } from 'npm:@supabase/supabase-js@2';
import type { AuthUser } from './types.ts';
import { AuthError } from './errors.ts';
import { getConfig } from './config.ts';

/**
 * Creates a Supabase client using the user's JWT from the Authorization header.
 * This client respects RLS policies and is scoped to the authenticated user.
 *
 * @param req - The incoming Request object
 * @returns SupabaseClient scoped to the authenticated user
 * @throws AuthError if Authorization header is missing or invalid
 */
export function createSupabaseClient(req: Request): SupabaseClient {
  const config = getConfig();

  // Extract JWT from Authorization header
  const authHeader = req.headers.get('Authorization');

  if (!authHeader) {
    throw new AuthError(
      'Authorization header is required',
      'MISSING_AUTH_HEADER'
    );
  }

  // Support both "Bearer <token>" and raw token
  const token = authHeader.startsWith('Bearer ')
    ? authHeader.slice(7)
    : authHeader;

  if (!token) {
    throw new AuthError(
      'Invalid authorization token',
      'INVALID_AUTH_TOKEN'
    );
  }

  // Create client with the user's JWT
  return createClient(config.supabaseUrl, config.supabaseAnonKey, {
    global: {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    },
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  });
}

/**
 * Creates a Supabase admin client using the service role key.
 * This client bypasses RLS policies and has full database access.
 * Use only for server-side operations like writing orders or VA records.
 *
 * @returns SupabaseClient with admin privileges
 */
export function createServiceClient(): SupabaseClient {
  const config = getConfig();

  return createClient(
    config.supabaseUrl,
    config.supabaseServiceRoleKey,
    {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    }
  );
}

/**
 * Extracts the authenticated user from a Supabase client.
 * Validates that the user exists and returns their profile.
 *
 * @param client - Supabase client with user JWT
 * @returns The authenticated user's profile
 * @throws AuthError if user is not authenticated or profile not found
 */
export async function getAuthenticatedUser(client: SupabaseClient): Promise<AuthUser> {
  const {
    data: { user },
    error: authError,
  } = await client.auth.getUser();

  if (authError || !user) {
    throw new AuthError(
      'Invalid or expired authentication token',
      'INVALID_TOKEN'
    );
  }

  return {
    id: user.id,
    email: user.email ?? '',
    role: user.user_metadata?.role,
  };
}

/**
 * Verifies that a resource belongs to the authenticated user.
 * Use this for ownership checks before accessing user-scoped data.
 *
 * @param userId - The user ID to check against
 * @param authUser - The authenticated user from getAuthenticatedUser
 * @throws AuthError if user IDs don't match
 */
export function verifyOwnership(userId: string, authUser: AuthUser): void {
  if (userId !== authUser.id) {
    throw new AuthError(
      'You do not have permission to access this resource',
      'FORBIDDEN'
    );
  }
}