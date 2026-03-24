/**
 * Edge Function: Create BCA Virtual Account
 *
 * Creates a new BCA Virtual Account for an order.
 * This function:
 * 1. Authenticates the user from JWT
 * 2. Validates the order exists and belongs to the user
 * 3. Checks no active VA already exists for this order
 * 4. Creates a new VA via BCA API
 * 5. Records the VA in the database
 * 6. Returns the VA details
 */

import { createSupabaseClient, createServiceClient, getAuthenticatedUser } from '../_shared/db.ts';
import { successResponse, errorResponse, withCors, corsOptionsResponse } from '../_shared/response.ts';
import { ValidationError, NotFoundError, ConflictError, PaymentError } from '../_shared/errors.ts';
import { toAppError } from '../_shared/errors.ts';
import { getPaymentGateway } from '../_lib/payment/payment_factory.ts';
import type { Order, BcaVaRecord } from '../_shared/types.ts';

/**
 * Request body schema for create-bca-va
 */
interface CreateVaRequest {
  orderId: string;
}

/**
 * Validates the request body.
 *
 * @param body - Request body
 * @returns Validated request
 * @throws ValidationError if validation fails
 */
function validateRequest(body: unknown): CreateVaRequest {
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
 * Main handler for create-bca-va Edge Function.
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

    // Fetch the order
    const { data: order, error: orderError } = await supabase
      .from('orders')
      .select('*')
      .eq('id', orderId)
      .single();

    if (orderError || !order) {
      throw new NotFoundError('Order not found', 'ORDER_NOT_FOUND');
    }

    // Verify ownership
    if (order.user_id !== user.id) {
      throw new NotFoundError('Order not found', 'ORDER_NOT_FOUND');
    }

    // Check order status - only pending orders can have VA created
    if (order.status !== 'pending') {
      throw new ConflictError(
        `Cannot create VA for order with status: ${order.status}`,
        'ORDER_NOT_PENDING'
      );
    }

    // Check if VA already exists and is active
    const serviceClient = createServiceClient();
    const { data: existingVa, error: vaError } = await serviceClient
      .from('bca_va_transactions')
      .select('*')
      .eq('order_id', orderId)
      .eq('status', 'ACTIVE')
      .maybeSingle();

    if (vaError) {
      throw new PaymentError('Failed to check existing VA', 'VA_CHECK_FAILED', vaError);
    }

    if (existingVa) {
      // Return existing VA instead of creating new one
      return successResponse({
        vaNumber: existingVa.va_number,
        expiryDate: existingVa.expiry_date,
        amount: existingVa.amount,
        status: 'ACTIVE' as const,
        existing: true,
      });
    }

    // Get user profile for customer details
    const { data: profile, error: profileError } = await supabase
      .from('user_profiles')
      .select('*')
      .eq('id', user.id)
      .single();

    if (profileError || !profile) {
      throw new NotFoundError('User profile not found', 'PROFILE_NOT_FOUND');
    }

    // Get BCA VA service
    const bcaVaService = getPaymentGateway('bca_va');

    // Create Virtual Account
    const vaResult = await bcaVaService.createVirtualAccount({
      orderId,
      orderNumber: order.order_number,
      amount: order.total,
      customerName: profile.name,
      customerEmail: profile.email,
      expiryHours: 24, // 24-hour expiry
    });

    // Write VA record to database using service client (bypasses RLS)
    const { error: insertError } = await serviceClient
      .from('bca_va_transactions')
      .insert({
        order_id: orderId,
        va_number: vaResult.vaNumber,
        amount: vaResult.amount,
        status: 'ACTIVE',
        expiry_date: vaResult.expiryDate.toISOString(),
        raw_response: vaResult.rawResponse,
      });

    if (insertError) {
      throw new PaymentError('Failed to save VA record', 'VA_SAVE_FAILED', insertError);
    }

    // Update order with VA number and payment deadline
    const { error: updateError } = await serviceClient
      .from('orders')
      .update({
        va_number: vaResult.vaNumber,
        payment_deadline: vaResult.expiryDate.toISOString(),
        payment_method: 'bca_va',
      })
      .eq('id', orderId);

    if (updateError) {
      throw new PaymentError('Failed to update order', 'ORDER_UPDATE_FAILED', updateError);
    }

    // Return VA details
    return successResponse({
      vaNumber: vaResult.vaNumber,
      expiryDate: vaResult.expiryDate,
      amount: vaResult.amount,
      status: vaResult.status,
      existing: false,
    });
  } catch (error) {
    return errorResponse(toAppError(error));
  }
}

// Register the Edge Function
Deno.serve(handler);