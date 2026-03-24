/**
 * Custom error class hierarchy for Otomasiku API.
 * Each error carries a message, HTTP status code, and machine-readable code.
 */

/**
 * Base error class for all application errors.
 * Extends the native Error class with additional properties for API responses.
 */
export class AppError extends Error {
  /** HTTP status code */
  public readonly statusCode: number;

  /** Machine-readable error code for client translation */
  public readonly code: string;

  /** Optional additional details about the error */
  public readonly details?: unknown;

  constructor(
    message: string,
    statusCode: number,
    code: string,
    details?: unknown
  ) {
    super(message);
    this.name = this.constructor.name;
    this.statusCode = statusCode;
    this.code = code;
    this.details = details;

    // Maintains proper stack trace for where error was thrown (V8 engines)
    if (Error.captureStackTrace) {
      Error.captureStackTrace(this, this.constructor);
    }
  }

  /**
   * Converts error to a JSON-serializable object for API responses.
   */
  toJSON(): { code: string; message: string; details?: unknown } {
    const result: { code: string; message: string; details?: unknown } = {
      code: this.code,
      message: this.message,
    };
    if (this.details !== undefined) {
      result.details = this.details;
    }
    return result;
  }
}

/**
 * Validation error (HTTP 400).
 * Used for invalid request data, missing fields, format errors.
 */
export class ValidationError extends AppError {
  constructor(message: string, code = 'VALIDATION_ERROR', details?: unknown) {
    super(message, 400, code, details);
  }
}

/**
 * Authentication error (HTTP 401).
 * Used for missing/invalid JWT, expired tokens.
 */
export class AuthError extends AppError {
  constructor(message: string, code = 'UNAUTHORIZED', details?: unknown) {
    super(message, 401, code, details);
  }
}

/**
 * Forbidden error (HTTP 403).
 * Used when user is authenticated but lacks permission.
 */
export class ForbiddenError extends AppError {
  constructor(message: string, code = 'FORBIDDEN', details?: unknown) {
    super(message, 403, code, details);
  }
}

/**
 * Not found error (HTTP 404).
 * Used when requested resource does not exist.
 */
export class NotFoundError extends AppError {
  constructor(message: string, code = 'NOT_FOUND', details?: unknown) {
    super(message, 404, code, details);
  }
}

/**
 * Conflict error (HTTP 409).
 * Used for duplicate resources, state conflicts.
 */
export class ConflictError extends AppError {
  constructor(message: string, code = 'CONFLICT', details?: unknown) {
    super(message, 409, code, details);
  }
}

/**
 * Payment error (HTTP 402).
 * Used for payment gateway failures, VA creation errors.
 */
export class PaymentError extends AppError {
  constructor(message: string, code = 'PAYMENT_ERROR', details?: unknown) {
    super(message, 402, code, details);
  }
}

/**
 * External API error (HTTP 502).
 * Used for failures calling third-party services (BCA API, etc.).
 */
export class ExternalApiError extends AppError {
  constructor(message: string, code = 'EXTERNAL_API_ERROR', details?: unknown) {
    super(message, 502, code, details);
  }
}

/**
 * Internal server error (HTTP 500).
 * Used for unexpected errors, unhandled exceptions.
 */
export class InternalError extends AppError {
  constructor(message: string, code = 'INTERNAL_ERROR', details?: unknown) {
    super(message, 500, code, details);
  }
}

/**
 * Type guard to check if an error is an AppError.
 */
export function isAppError(error: unknown): error is AppError {
  return error instanceof AppError;
}

/**
 * Converts unknown errors to AppError.
 * Useful for catch blocks where error type is unknown.
 */
export function toAppError(error: unknown): AppError {
  if (isAppError(error)) {
    return error;
  }

  if (error instanceof Error) {
    return new InternalError(error.message, 'INTERNAL_ERROR', {
      originalError: error.name,
      stack: error.stack,
    });
  }

  return new InternalError('An unexpected error occurred', 'INTERNAL_ERROR', {
    originalError: String(error),
  });
}