/**
 * Payment Gateway Abstract Interface
 *
 * All payment gateways (BCA VA, Midtrans, etc.) must implement this interface.
 * This allows the application to work with multiple payment providers
 * through a unified API.
 */

/**
 * Parameters for creating a new Virtual Account.
 */
export interface CreateVaParams {
  /** Unique identifier for the order */
  orderId: string;

  /** Human-readable order number, e.g. "OTM-20240101-0001" */
  orderNumber: string;

  /** Payment amount in IDR (integer, no decimals) */
  amount: number;

  /** Customer's full name for VA display */
  customerName: string;

  /** Customer's email for notifications */
  customerEmail: string;

  /** VA expiry time in hours from creation (default: 24) */
  expiryHours?: number;
}

/**
 * Result of a successful Virtual Account creation.
 */
export interface VaResult {
  /** The full Virtual Account number */
  vaNumber: string;

  /** Date/time when the VA expires */
  expiryDate: Date;

  /** Payment amount in IDR */
  amount: number;

  /** VA status (always ACTIVE after creation) */
  status: 'ACTIVE';

  /** Raw response from the payment gateway for audit/debug */
  rawResponse: Record<string, unknown>;
}

/**
 * Result of checking a Virtual Account's payment status.
 */
export interface VaStatusResult {
  /** The Virtual Account number */
  vaNumber: string;

  /** Current status of the VA */
  status: 'ACTIVE' | 'PAID' | 'EXPIRED';

  /** Date/time when payment was received (if status is PAID) */
  paidAt?: Date;

  /** Payment amount in IDR */
  amount: number;
}

/**
 * Payment Gateway Interface
 *
 * Abstract interface that all payment gateways must implement.
 * Provides methods for creating, checking, and canceling Virtual Accounts.
 */
export interface PaymentGateway {
  /** Human-readable name of the payment gateway */
  readonly name: string;

  /**
   * Creates a new Virtual Account for an order.
   *
   * @param params - VA creation parameters
   * @returns Promise resolving to VA details
   * @throws PaymentError if VA creation fails
   */
  createVirtualAccount(params: CreateVaParams): Promise<VaResult>;

  /**
   * Checks the payment status of an existing Virtual Account.
   *
   * @param vaNumber - The VA number to check
   * @returns Promise resolving to VA status details
   * @throws PaymentError if status check fails
   */
  checkVaStatus(vaNumber: string): Promise<VaStatusResult>;

  /**
   * Cancels an existing Virtual Account.
   * Some gateways may not support cancellation (VA expires naturally).
   *
   * @param vaNumber - The VA number to cancel
   * @returns Promise resolving when cancellation is complete
   * @throws PaymentError if cancellation fails or is not supported
   */
  cancelVirtualAccount(vaNumber: string): Promise<void>;
}

/**
 * Payment method identifiers.
 * Extend this as new payment methods are added.
 */
export type PaymentMethod = 'bca_va';
// Future: | 'mandiri_va' | 'gopay' | 'ovo' | 'dana'