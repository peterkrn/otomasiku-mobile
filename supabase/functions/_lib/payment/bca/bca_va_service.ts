/**
 * BCA Virtual Account Service
 *
 * Implements the PaymentGateway interface for BCA Virtual Account.
 * Provides business logic for VA creation, status checking, and cancellation.
 */

import type { Config } from '../../../_shared/config.ts';
import { PaymentError } from '../../../_shared/errors.ts';
import type { CreateVaParams, VaResult, VaStatusResult, PaymentGateway } from '../payment_gateway.ts';
import { BcaApiClient, getBcaApiClient } from './bca_client.ts';
import { normalizeBcaStatus } from './bca_types.ts';

/**
 * BCA Virtual Account Service
 *
 * Provides high-level methods for BCA VA operations.
 * Implements the PaymentGateway interface for seamless integration.
 */
export class BcaVaService implements PaymentGateway {
  readonly name = 'bca_va';

  private readonly client: BcaApiClient;
  private readonly config: Config;

  constructor(client?: BcaApiClient, config?: Config) {
    this.client = client ?? getBcaApiClient();
    this.config = config ?? ({} as Config); // Will be fetched from getConfig() in client
  }

  /**
   * Creates a new BCA Virtual Account for an order.
   *
   * @param params - VA creation parameters
   * @returns Promise resolving to VA details
   * @throws PaymentError if VA creation fails
   */
  async createVirtualAccount(params: CreateVaParams): Promise<VaResult> {
    try {
      // Generate 10-digit customer number from order number
      const customerNumber = this.generateCustomerNumber(params.orderNumber);

      // Build BCA request
      const bcaRequest = {
        CompanyCode: this.config.bca?.vaCompanyCode ?? '',
        CustomerNumber: customerNumber,
        RequestID: this.generateRequestId(),
        RequestTimeStamp: new Date().toISOString(),
        CustomerName: this.truncateName(params.customerName, 30),
        TotalAmount: params.amount,
        CurrencyCode: 'IDR' as const,
        TransactionDetails: [
          {
            CustomerNumber: customerNumber,
            AdditionalId: params.orderId,
            DetailDescription: `Pembayaran ${params.orderNumber}`,
          },
        ],
        ValidityPeriod: params.expiryHours ?? 24,
      };

      // Call BCA API
      const response = await this.client.createVa(bcaRequest);

      // Parse expiry date
      const expiryDate = new Date(response.ExpiredDate);

      return {
        vaNumber: response.VirtualAccountNo,
        expiryDate,
        amount: params.amount,
        status: 'ACTIVE',
        rawResponse: response as unknown as Record<string, unknown>,
      };
    } catch (error) {
      // Wrap non-PaymentError exceptions
      if (error instanceof PaymentError) {
        throw error;
      }

      throw new PaymentError(
        `Failed to create BCA Virtual Account: ${error instanceof Error ? error.message : 'Unknown error'}`,
        'VA_CREATION_FAILED',
        { originalError: error }
      );
    }
  }

  /**
   * Checks the payment status of an existing Virtual Account.
   *
   * @param vaNumber - The VA number to check
   * @returns Promise resolving to VA status details
   * @throws PaymentError if status check fails
   */
  async checkVaStatus(vaNumber: string): Promise<VaStatusResult> {
    try {
      // Parse VA number to extract company code and customer number
      const { companyCode, customerNumber } = this.client.parseVaNumber(vaNumber);

      // Call BCA inquiry API
      const response = await this.client.getVaStatus(companyCode, customerNumber);

      // Normalize status
      const status = normalizeBcaStatus(response.Status);

      // Parse payment date if paid
      let paidAt: Date | undefined;
      if (status === 'PAID' && response.PaymentDate && response.PaymentTime) {
        paidAt = new Date(`${response.PaymentDate}T${response.PaymentTime}`);
      }

      return {
        vaNumber: response.VirtualAccountNo,
        status,
        paidAt,
        amount: parseInt(response.TotalAmount, 10),
      };
    } catch (error) {
      if (error instanceof PaymentError) {
        throw error;
      }

      throw new PaymentError(
        `Failed to check VA status: ${error instanceof Error ? error.message : 'Unknown error'}`,
        'VA_STATUS_CHECK_FAILED',
        { vaNumber, originalError: error }
      );
    }
  }

  /**
   * Cancels an existing Virtual Account.
   *
   * NOTE: BCA VA uses time-based expiry and does not provide a cancel API.
   * This method is implemented as a stub for interface compliance.
   *
   * @param vaNumber - The VA number to cancel
   * @throws PaymentError always (cancellation not supported)
   */
  async cancelVirtualAccount(_vaNumber: string): Promise<void> {
    // TODO: BCA VA uses time-based expiry. No cancel API available.
    // VAs will automatically expire after the ValidityPeriod.
    throw new PaymentError(
      'BCA Virtual Account cancellation is not supported. VAs expire automatically based on validity period.',
      'VA_CANCEL_NOT_SUPPORTED'
    );
  }

  /**
   * Generates a 10-digit customer number from an order number.
   *
   * The order number format is "OTM-YYYYMMDD-XXXX" where XXXX is a sequence number.
   * We extract the date and sequence to create a unique 10-digit customer number.
   *
   * @param orderNumber - Order number (e.g., "OTM-20240101-0001")
   * @returns 10-digit customer number
   */
  private generateCustomerNumber(orderNumber: string): string {
    // Extract the sequence number part (last 4 digits)
    const match = orderNumber.match(/(\d{4})$/);
    const sequence = match ? match[1] : '0001';

    // Use current date + sequence for uniqueness
    const now = new Date();
    const datePart = now.getFullYear().toString().slice(-2) +
                     (now.getMonth() + 1).toString().padStart(2, '0') +
                     now.getDate().toString().padStart(2, '0');

    // Combine to create 10-digit number: 6 digits date + 4 digits sequence
    return `${datePart}${sequence}`;
  }

  /**
   * Generates a unique request ID for BCA API calls.
   * Uses timestamp + random suffix.
   *
   * @returns Unique request ID string
   */
  private generateRequestId(): string {
    const timestamp = Date.now().toString(36);
    const random = Math.random().toString(36).slice(2, 6);
    return `REQ-${timestamp}-${random}`.toUpperCase();
  }

  /**
   * Truncates a name to fit BCA's character limit.
   *
   * @param name - Customer name
   * @param maxLength - Maximum allowed length
   * @returns Truncated name
   */
  private truncateName(name: string, maxLength: number): string {
    if (name.length <= maxLength) {
      return name;
    }
    return name.slice(0, maxLength - 3) + '...';
  }
}

/**
 * Singleton instance of BcaVaService.
 */
let vaServiceInstance: BcaVaService | null = null;

/**
 * Gets the singleton BcaVaService instance.
 *
 * @returns BcaVaService instance
 */
export function getBcaVaService(): BcaVaService {
  if (!vaServiceInstance) {
    vaServiceInstance = new BcaVaService();
  }
  return vaServiceInstance;
}