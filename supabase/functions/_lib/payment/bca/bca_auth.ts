/**
 * BCA OAuth2 Authentication Manager
 *
 * Handles OAuth2 client credentials flow for BCA API authentication.
 * Caches access tokens in memory with expiry tracking to minimize
 * token requests.
 *
 * Also provides HMAC-SHA256 signature generation for BCA API requests,
 * which is required for all authenticated calls.
 */

import { getConfig } from '../../../_shared/config.ts';
import { ExternalApiError } from '../../../_shared/errors.ts';
import type { BcaTokenResponse } from './bca_types.ts';

/**
 * Cached token data with expiry.
 */
interface CachedToken {
  accessToken: string;
  expiresAt: number; // Unix timestamp in milliseconds
}

/**
 * BCA Authentication Manager
 *
 * Manages OAuth2 tokens and request signatures for BCA API.
 */
export class BcaAuthManager {
  private cachedToken: CachedToken | null = null;

  /**
   * Gets a valid BCA access token.
   * Returns cached token if still valid, otherwise fetches a new one.
   *
   * @returns Promise resolving to the access token string
   * @throws ExternalApiError if token fetch fails
   */
  async getAccessToken(): Promise<string> {
    // Return cached token if still valid (with 5 minute buffer)
    if (this.cachedToken && Date.now() < this.cachedToken.expiresAt - 5 * 60 * 1000) {
      return this.cachedToken.accessToken;
    }

    // Fetch new token
    const config = getConfig();
    const tokenUrl = `${config.bca.apiBaseUrl}/api/oauth/token`;

    // Create Basic Auth header (client_id:client_secret base64 encoded)
    const credentials = btoa(`${config.bca.clientId}:${config.bca.clientSecret}`);

    const response = await fetch(tokenUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': `Basic ${credentials}`,
      },
      body: 'grant_type=client_credentials',
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new ExternalApiError(
        `Failed to obtain BCA access token: ${response.status}`,
        'BCA_TOKEN_ERROR',
        { status: response.status, body: errorText }
      );
    }

    const data: BcaTokenResponse = await response.json();

    // Cache the token with expiry
    this.cachedToken = {
      accessToken: data.access_token,
      expiresAt: Date.now() + data.expires_in * 1000,
    };

    return data.access_token;
  }

  /**
   * Generates HMAC-SHA256 signature for BCA API request.
   *
   * BCA requires a signature for all authenticated API calls.
   * The signature is generated from:
   * - HTTP method (GET, POST, etc.)
   * - Relative URL path
   * - Access token
   * - Request body (for POST/PUT) or empty string
   * - Timestamp
   *
   * @param httpMethod - HTTP method in uppercase
   * @param relativeUrl - Relative URL path starting with /
   * @param accessToken - BCA access token
   * @param body - Request body object or empty string
   * @param timestamp - ISO format timestamp
   * @returns HMAC-SHA256 signature as lowercase hex string
   */
  async generateSignature(
    httpMethod: string,
    relativeUrl: string,
    accessToken: string,
    body: string | Record<string, unknown>,
    timestamp: string
  ): Promise<string> {
    const config = getConfig();

    // Convert body to JSON string if object
    const bodyString = typeof body === 'string' ? body : JSON.stringify(body);

    // Generate SHA256 hash of body (lowercase hex)
    const bodyHash = await this.sha256(bodyString);

    // Build string to sign
    // Format: METHOD:RelativeURL:AccessToken:BodyHash:Timestamp
    const stringToSign = [
      httpMethod.toUpperCase(),
      relativeUrl,
      accessToken,
      bodyHash,
      timestamp,
    ].join(':');

    // Generate HMAC-SHA256 with client secret as key
    const signature = await this.hmacSha256(stringToSign, config.bca.clientSecret);

    return signature;
  }

  /**
   * Generates ISO 8601 timestamp for BCA API requests.
   * Format: YYYY-MM-DDTHH:mm:ss.sssZ
   *
   * @returns ISO timestamp string
   */
  getTimestamp(): string {
    return new Date().toISOString();
  }

  /**
   * Computes SHA256 hash of a string.
   *
   * @param data - Input string
   * @returns Hex-encoded hash string (lowercase)
   */
  private async sha256(data: string): Promise<string> {
    const encoder = new TextEncoder();
    const dataBuffer = encoder.encode(data);

    const hashBuffer = await crypto.subtle.digest('SHA-256', dataBuffer);

    // Convert to hex string
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
  }

  /**
   * Computes HMAC-SHA256 of a string with a secret key.
   *
   * @param data - Input string
   * @param secret - Secret key string
   * @returns Hex-encoded HMAC string (lowercase)
   */
  private async hmacSha256(data: string, secret: string): Promise<string> {
    const encoder = new TextEncoder();

    // Import the secret key
    const keyBuffer = encoder.encode(secret);
    const key = await crypto.subtle.importKey(
      'raw',
      keyBuffer,
      { name: 'HMAC', hash: 'SHA-256' },
      false,
      ['sign']
    );

    // Sign the data
    const dataBuffer = encoder.encode(data);
    const signatureBuffer = await crypto.subtle.sign('HMAC', key, dataBuffer);

    // Convert to hex string
    const signatureArray = Array.from(new Uint8Array(signatureBuffer));
    return signatureArray.map(b => b.toString(16).padStart(2, '0')).join('');
  }

  /**
   * Clears the cached token.
   * Use this when token is rejected by BCA API.
   */
  clearToken(): void {
    this.cachedToken = null;
  }
}

/**
 * Singleton instance of BcaAuthManager.
 * Reuse across requests for token caching.
 */
let authManagerInstance: BcaAuthManager | null = null;

/**
 * Gets the singleton BcaAuthManager instance.
 * Creates one if it doesn't exist.
 *
 * @returns BcaAuthManager instance
 */
export function getBcaAuthManager(): BcaAuthManager {
  if (!authManagerInstance) {
    authManagerInstance = new BcaAuthManager();
  }
  return authManagerInstance;
}