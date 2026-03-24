/**
 * BCA API Client
 *
 * Low-level HTTP client for BCA Developer API.
 * Handles authentication, signature generation, and error handling.
 */

import { getConfig } from '../../../_shared/config.ts';
import { ExternalApiError } from '../../../_shared/errors.ts';
import { BcaAuthManager, getBcaAuthManager } from './bca_auth.ts';
import type { BcaApiHeaders, BcaCreateVaRequest, BcaCreateVaResponse, BcaVaInquiryResponse, BcaErrorResponse } from './bca_types.ts';

/**
 * BCA API Client
 *
 * Provides methods for making authenticated requests to BCA API.
 * Automatically handles token management and signature generation.
 */
export class BcaApiClient {
  private readonly authManager: BcaAuthManager;
  private readonly config: ReturnType<typeof getConfig>;

  constructor(authManager?: BcaAuthManager) {
    this.authManager = authManager ?? getBcaAuthManager();
    this.config = getConfig();
  }

  /**
   * Makes an authenticated request to BCA API.
   *
   * @param method - HTTP method
   * @param path - API path (relative to base URL)
   * @param body - Request body (for POST/PUT)
   * @returns Promise resolving to parsed response
   * @throws ExternalApiError on API failure
   */
  private async request<T>(
    method: 'GET' | 'POST' | 'PUT' | 'DELETE',
    path: string,
    body?: Record<string, unknown>
  ): Promise<T> {
    const accessToken = await this.authManager.getAccessToken();
    const timestamp = this.authManager.getTimestamp();

    // Build signature
    const signature = await this.authManager.generateSignature(
      method,
      path,
      accessToken,
      body ?? '',
      timestamp
    );

    // Build headers
    const headers: BcaApiHeaders = {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${accessToken}`,
      'X-BCA-Key': this.config.bca.clientId,
      'X-BCA-Timestamp': timestamp,
      'X-BCA-Signature': signature,
    };

    const url = `${this.config.bca.apiBaseUrl}${path}`;

    const response = await fetch(url, {
      method,
      headers,
      body: body ? JSON.stringify(body) : undefined,
    });

    // Parse response
    const responseData = await response.json();

    if (!response.ok) {
      const errorData = responseData as BcaErrorResponse;
      throw new ExternalApiError(
        `BCA API error: ${errorData.ErrorMessage?.English ?? response.statusText}`,
        'BCA_API_ERROR',
        {
          status: response.status,
          errorCode: errorData.ErrorCode,
          message: errorData.ErrorMessage,
        }
      );
    }

    return responseData as T;
  }

  /**
   * Creates a new Virtual Account.
   *
   * @param request - VA creation request payload
   * @returns Promise resolving to VA creation response
   * @throws ExternalApiError if VA creation fails
   */
  async createVa(request: BcaCreateVaRequest): Promise<BcaCreateVaResponse> {
    return this.request<BcaCreateVaResponse>(
      'POST',
      '/billing/virtual-account/v1',
      request as unknown as Record<string, unknown>
    );
  }

  /**
   * Gets the status of an existing Virtual Account.
   *
   * @param companyCode - BCA-assigned company code
   * @param customerNumber - 10-digit customer number
   * @returns Promise resolving to VA inquiry response
   * @throws ExternalApiError if inquiry fails
   */
  async getVaStatus(
    companyCode: string,
    customerNumber: string
  ): Promise<BcaVaInquiryResponse> {
    // GET request with query parameters
    const path = `/billing/virtual-account/v1/${companyCode}/${customerNumber}`;

    return this.request<BcaVaInquiryResponse>('GET', path);
  }

  /**
   * Parses a VA number into company code and customer number.
   * BCA VA format: Company Code (8 digits) + Customer Number (10 digits)
   *
   * @param vaNumber - Full VA number (18 digits)
   * @returns Object with companyCode and customerNumber
   * @throws Error if VA number format is invalid
   */
  parseVaNumber(vaNumber: string): { companyCode: string; customerNumber: string } {
    // Remove any spaces or dashes
    const cleanVaNumber = vaNumber.replace(/[\s-]/g, '');

    // BCA VA is 18 digits: 8 (company code) + 10 (customer number)
    if (cleanVaNumber.length !== 18) {
      throw new Error(
        `Invalid BCA VA number format: expected 18 digits, got ${cleanVaNumber.length}`
      );
    }

    return {
      companyCode: cleanVaNumber.slice(0, 8),
      customerNumber: cleanVaNumber.slice(8),
    };
  }
}

/**
 * Singleton instance of BcaApiClient.
 */
let apiClientInstance: BcaApiClient | null = null;

/**
 * Gets the singleton BcaApiClient instance.
 *
 * @returns BcaApiClient instance
 */
export function getBcaApiClient(): BcaApiClient {
  if (!apiClientInstance) {
    apiClientInstance = new BcaApiClient();
  }
  return apiClientInstance;
}