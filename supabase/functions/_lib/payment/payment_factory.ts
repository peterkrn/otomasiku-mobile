/**
 * Payment Gateway Factory
 *
 * Factory function to get the correct payment gateway implementation
 * based on the payment method. Uses singleton pattern for efficiency.
 */

import type { Config } from '../../_shared/config.ts';
import type { PaymentGateway, PaymentMethod } from './payment_gateway.ts';
import { BcaVaService, getBcaVaService } from './bca/bca_va_service.ts';

/**
 * Map of payment method to gateway instance.
 * Populated lazily as gateways are requested.
 */
const gatewayCache = new Map<PaymentMethod, PaymentGateway>();

/**
 * Gets the payment gateway implementation for the specified method.
 *
 * @param method - Payment method identifier
 * @param _config - Optional config (used for testing)
 * @returns PaymentGateway implementation
 * @throws Error if payment method is not supported
 */
export function getPaymentGateway(
  method: PaymentMethod,
  _config?: Config
): PaymentGateway {
  // Check cache first
  const cached = gatewayCache.get(method);
  if (cached) {
    return cached;
  }

  // Create new gateway instance based on method
  let gateway: PaymentGateway;

  switch (method) {
    case 'bca_va':
      gateway = getBcaVaService();
      break;

    // Future payment methods:
    // case 'mandiri_va':
    //   gateway = getMandiriVaService();
    //   break;
    // case 'gopay':
    //   gateway = getGopayService();
    //   break;

    default:
      throw new Error(`Unsupported payment method: ${method}`);
  }

  // Cache for future use
  gatewayCache.set(method, gateway);

  return gateway;
}

/**
 * Clears the gateway cache. Useful for testing.
 */
export function clearGatewayCache(): void {
  gatewayCache.clear();
}

/**
 * Lists all supported payment methods.
 *
 * @returns Array of supported payment method identifiers
 */
export function getSupportedPaymentMethods(): PaymentMethod[] {
  return ['bca_va'];
  // Future: return ['bca_va', 'mandiri_va', 'gopay', 'ovo', 'dana'];
}