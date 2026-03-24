/**
 * Helper functions for consistent JSON API responses.
 * All functions return a Deno Response object with correct headers.
 */

import type { PaginationMeta } from './types.ts';
import { AppError } from './errors.ts';

/** Standard JSON API response headers */
const JSON_HEADERS = {
  'Content-Type': 'application/json',
  'Cache-Control': 'no-store',
};

/**
 * Creates a successful JSON response.
 *
 * @param data - The response data payload
 * @param status - HTTP status code (default 200)
 * @returns Deno Response object with JSON body
 */
export function successResponse<T>(
  data: T,
  status = 200
): Response {
  const body = {
    success: true,
    data,
  };

  return new Response(JSON.stringify(body), {
    status,
    headers: JSON_HEADERS,
  });
}

/**
 * Creates an error JSON response from an AppError.
 *
 * @param error - The AppError to serialize
 * @returns Deno Response object with JSON error body
 */
export function errorResponse(error: AppError): Response {
  const body = {
    success: false,
    error: error.toJSON(),
  };

  return new Response(JSON.stringify(body), {
    status: error.statusCode,
    headers: JSON_HEADERS,
  });
}

/**
 * Creates a paginated JSON response for list endpoints.
 *
 * @param data - Array of items for the current page
 * @param total - Total number of items across all pages
 * @param page - Current page number (1-indexed)
 * @param limit - Number of items per page
 * @returns Deno Response object with paginated data and metadata
 */
export function paginatedResponse<T>(
  data: T[],
  total: number,
  page: number,
  limit: number
): Response {
  const meta: PaginationMeta = {
    total,
    page,
    limit,
    totalPages: Math.ceil(total / limit),
  };

  const body = {
    success: true,
    data,
    meta,
  };

  return new Response(JSON.stringify(body), {
    status: 200,
    headers: JSON_HEADERS,
  });
}

/**
 * Creates a "no content" response (HTTP 204).
 * Used for successful DELETE operations or actions with no response body.
 *
 * @returns Deno Response object with 204 status
 */
export function noContentResponse(): Response {
  return new Response(null, {
    status: 204,
    headers: JSON_HEADERS,
  });
}

/**
 * Creates a response for OPTIONS requests (CORS preflight).
 *
 * @param allowedMethods - Array of allowed HTTP methods
 * @param allowedOrigin - Allowed origin for CORS
 * @returns Deno Response object with CORS headers
 */
export function corsOptionsResponse(
  allowedMethods: string[],
  allowedOrigin = '*'
): Response {
  return new Response(null, {
    status: 204,
    headers: {
      'Access-Control-Allow-Origin': allowedOrigin,
      'Access-Control-Allow-Methods': allowedMethods.join(', '),
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      'Access-Control-Max-Age': '86400', // 24 hours
    },
  });
}

/**
 * Wraps a response with CORS headers.
 *
 * @param response - The original response
 * @param allowedOrigin - Allowed origin for CORS
 * @returns New Response object with CORS headers added
 */
export function withCors(response: Response, allowedOrigin = '*'): Response {
  const newHeaders = new Headers(response.headers);
  newHeaders.set('Access-Control-Allow-Origin', allowedOrigin);

  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers: newHeaders,
  });
}