/**
 * BCA Developer API Types
 *
 * TypeScript types that map exactly to the BCA Developer API sandbox
 * request/response format for Virtual Account operations.
 *
 * @see https://developer.bca.co.id/
 */

// ============================================================
// OAUTH2 TOKEN
// ============================================================

/**
 * Request body for BCA OAuth2 token endpoint.
 * Uses client credentials grant type.
 */
export interface BcaTokenRequest {
  /** Always "client_credentials" for server-to-server auth */
  grant_type: 'client_credentials';
}

/**
 * Response from BCA OAuth2 token endpoint.
 */
export interface BcaTokenResponse {
  /** The access token to use in API calls */
  access_token: string;

  /** Token type, always "Bearer" */
  token_type: 'Bearer';

  /** Token lifetime in seconds (typically 3600 = 1 hour) */
  expires_in: number;

  /** Token scope */
  scope: string;
}

// ============================================================
// VIRTUAL ACCOUNT CREATION
// ============================================================

/**
 * Request body for creating a BCA Virtual Account.
 * BCA VA format: Company Code (8 digits) + Customer Number (10 digits)
 */
export interface BcaCreateVaRequest {
  /** BCA-assigned company code for VA (8 digits) */
  CompanyCode: string;

  /** Customer number (10 digits), unique per VA */
  CustomerNumber: string;

  /** Request ID for idempotency */
  RequestID: string;

  /** Request timestamp in ISO format */
  RequestTimeStamp: string;

  /** Customer name to display in VA (max 30 chars) */
  CustomerName: string;

  /** Total amount in IDR (integer, no decimals) */
  TotalAmount: number;

  /** Number of digits for amount (always "IDR" for currency code) */
  CurrencyCode: 'IDR';

  /** Additional transaction details */
  TransactionDetails: Array<{
    /** Customer number (same as parent) */
    CustomerNumber: string;
    /** Additional ID for the transaction */
    AdditionalId: string;
    /** Transaction description */
    DetailDescription: string;
  }>;

  /** VA validity period (hours) */
  ValidityPeriod: number;
}

/**
 * Response from BCA VA creation endpoint.
 */
export interface BcaCreateVaResponse {
  /** BCA-assigned company code */
  CompanyCode: string;

  /** Customer number for this VA */
  CustomerNumber: string;

  /** Full Virtual Account number (CompanyCode + CustomerNumber) */
  VirtualAccountNo: string;

  /** Customer name as registered */
  CustomerName: string;

  /** Total amount in IDR */
  TotalAmount: string;

  /** Payment due date/time in ISO format */
  ExpiredDate: string;

  /** Status message from BCA */
  Status: string;
}

// ============================================================
// VIRTUAL ACCOUNT INQUIRY
// ============================================================

/**
 * Response from BCA VA inquiry endpoint.
 * Used to check the current status of a VA.
 */
export interface BcaVaInquiryResponse {
  /** BCA-assigned company code */
  CompanyCode: string;

  /** Customer number for this VA */
  CustomerNumber: string;

  /** Full Virtual Account number */
  VirtualAccountNo: string;

  /** Customer name as registered */
  CustomerName: string;

  /** Total amount in IDR (as string) */
  TotalAmount: string;

  /** Payment status: 1 = Active, 2 = Paid, etc. */
  Status: string;

  /** Payment date if status is paid */
  PaymentDate?: string;

  /** Payment time if status is paid */
  PaymentTime?: string;

  /** Additional details */
  DetailBilling: Array<{
    BillId: string;
    BillReferenceNo: string;
    BillAmount: string;
    BillStatus: string;
  }>;
}

// ============================================================
// VIRTUAL ACCOUNT PAYMENT NOTIFICATION (CALLBACK)
// ============================================================

/**
 * Callback payload from BCA when a VA is paid.
 * BCA sends this to the registered callback URL.
 */
export interface BcaVaPaymentCallback {
  /** BCA-assigned company code */
  CompanyCode: string;

  /** Customer number for this VA */
  CustomerNumber: string;

  /** Full Virtual Account number */
  VirtualAccountNo: string;

  /** Customer name */
  CustomerName: string;

  /** Amount paid in IDR */
  PaidAmount: string;

  /** Currency code */
  CurrencyCode: string;

  /** Payment date (YYYY-MM-DD) */
  PaymentDate: string;

  /** Payment time (HH:mm:ss) */
  PaymentTime: string;

  /** Reference number from BCA */
  ReferenceNo: string;

  /** Additional transaction details */
  DetailBilling: Array<{
    BillId: string;
    BillReferenceNo: string;
    BillAmount: string;
    BillStatus: string;
  }>;
}

// ============================================================
// API ERROR RESPONSE
// ============================================================

/**
 * Error response from BCA API.
 */
export interface BcaErrorResponse {
  /** Error code from BCA */
  ErrorCode: string;

  /** Error message in Indonesian */
  ErrorMessage: {
    Indonesian: string;
    English: string;
  };

  /** HTTP status code */
  status?: number;
}

// ============================================================
// HELPER TYPES
// ============================================================

/**
 * BCA API request headers.
 * Required for all authenticated API calls.
 */
export interface BcaApiHeaders {
  /** Content type */
  'Content-Type': 'application/json';

  /** OAuth2 access token */
  Authorization: string;

  /** BCA API key (client ID) */
  'X-BCA-Key': string;

  /** Request timestamp in ISO format */
  'X-BCA-Timestamp': string;

  /** HMAC-SHA256 signature */
  'X-BCA-Signature': string;
}

/**
 * Normalized VA status from BCA.
 * Maps BCA's numeric status to our enum.
 */
export type BcaVaStatusCode = 'ACTIVE' | 'PAID' | 'EXPIRED' | 'FAILED';

/**
 * Maps BCA status code string to our normalized enum.
 *
 * @param status - BCA status string from API
 * @returns Normalized status code
 */
export function normalizeBcaStatus(status: string): BcaVaStatusCode {
  switch (status) {
    case '1':
    case 'ACTIVE':
      return 'ACTIVE';
    case '2':
    case 'PAID':
      return 'PAID';
    case '3':
    case 'EXPIRED':
      return 'EXPIRED';
    default:
      return 'FAILED';
  }
}