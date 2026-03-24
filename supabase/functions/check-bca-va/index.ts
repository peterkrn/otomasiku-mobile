/**
 * Edge Function: Check BCA Virtual Account Status
 *
 * Checks the payment status of a BCA Virtual Account.
 * This function:
 * 1. Authenticates the user from JWT
 * 2. Fetches the VA record from database
 * 3. If already paid/expired, returns cached status
 * 4. Otherwise, queries BCA API for current status
 * 5. Updates database if status changed
 * 6. Returns the status
 */

import { createSupabaseClient, createServiceClient, getAuthenticatedUser } from '../_shared/db.ts';
import { successResponse, errorResponse, withCors, corsOptionsResponse } from '../_shared/response.ts';
import { ValidationError, NotFoundError, PaymentError } from '../_shared/errors.ts';
import { toAppError } from '../_shared/errors.ts';
import { getPaymentGateway } from '../_lib/payment/payment_factory.ts';
import type { BcaVaRecord, BcaVaStatus } from '../_shared/types.ts';

/**
 * Request body schema for check-bca-va
 */
interface CheckVaRequest {
  orderId: string;
}

/**
 * Validates the request body.
 *
 * @param body - Request body
 * @returns Validated request
 * @throws ValidationError if validation fails
 */
function validateRequest(body: unknown): CheckVaRequest {
  if (!body || typeof body !== 'object') {
    throw new ValidationError('Request body is required', 'MISSING_BODY');
  }

  const { orderId } = body as Record<string, unknown>;

  if (!orderId || typeof orderId !== 'string') {
    throw new ValidationError('orderId is required and must be a string', 'INVALID_ORDER_ID');
  }

  return { orderId };
}

/**
 * Main handler for check-bca-va Edge Function.
 */
async function handler(req: Request): Promise<Response> {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return corsOptionsResponse(['POST', 'OPTIONS']);
  }

  // Only allow POST
  if (req.method !== 'POST') {
    return errorResponse(new ValidationError('Method not allowed', 'METHOD_NOT_ALLOWED'));
  }

  try {
    // Authenticate user
    const supabase = createSupabaseClient(req);
    const user = await getAuthenticatedUser(supabase);

    // Parse and validate request
    const body = await req.json();
    const { orderId } = validateRequest(body);

    // Verify the order belongs to the user
    const { data: order, error: orderError } = await supabase
      .from('orders')
      .select('id, user_id')
      .eq('id', orderId)
      .single();

    if (orderError || !order) {
      throw new NotFoundError('Order not found', 'ORDER_NOT_FOUND');
    }

    if (order.user_id !== user.id) {
      throw new NotFoundError('Order not found', 'ORDER_NOT_FOUND');
    }

    // Fetch VA record from database
    const serviceClient = createServiceClient();
    const { data: vaRecord, error: vaError } = await serviceClient
      .from('bca_va_transactions')
      .select('*')
      .eq('order_id', orderId)
      .order('created_at', { ascending: false })
      .limit(1)
      .maybeSingle();

    if (vaError) {
      throw new PaymentError('Failed to fetch VA record', 'VA_FETCH_FAILED', vaError);
    }

    if (!vaRecord) {
      throw new NotFoundError('No Virtual Account found for this order', 'VA_NOT_FOUND');
    }

    // If already paid or expired, return cached status
    if (vaRecord.status === 'PAID' || vaRecord.status === 'EXPIRED') {
      return successResponse({
        vaNumber: vaRecord.va_number,
        status: vaRecord.status,
        amount: vaRecord.amount,
        expiryDate: vaRecord.expiry_date,
        updatedAt: vaRecord.updated_at,
        cached: true,
      });
    }

    // Check current status with BCA API
    const bcaVaService = getPaymentGateway('bca_va');
    const statusResult = await bcaVaService.checkVaStatus(vaRecord.va_number);

    // If status changed, update database
    if (statusResult.status !== vaRecord.status) {
      const newStatus = statusResult.status as BcaVaStatus;

      // Update VA record
      const { error: updateVaError } = await serviceClient
        .from('bca_va_transactions')
        .update({
          status: newStatus,
          updated_at: new Date().toISOString(),
        })
        .eq('id', vaRecord.id);

      if (updateVaError) {
        console.error('Failed to update VA status:', updateVaError);
        // Continue anyway - we can still return the status
      }

      // If paid, update order status
      if (newStatus === 'PAID') {
        const { error: updateOrderError } = await serviceClient
          .from('orders')
          .update({
            status: 'processing',
            updated_at: new Date().toISOString(),
          })
          .eq('id', orderId);

        if (updateOrderError) {
          console.error('Failed to update order status:', updateOrderError);
        }
      }
    }

    // Return current status
    return successResponse({
      vaNumber: statusResult.vaNumber,
      status: statusResult.status,
      amount: statusResult.amount,
      paidAt: statusResult.paidAt,
      expiryDate: vaRecord.expiry_date,
      cached: false,
    });
  } catch (error) {
    return errorResponse(toAppError(error));
  }
}

// Register the Edge Function
Deno.serve(handler);