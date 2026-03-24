/**
 * Domain types for Otomasiku Marketplace
 * Mirrors the Dart domain models in TypeScript.
 * All monetary values are integers representing IDR (Rupiah), no decimals.
 */

// ============================================================
// ENUMS
// ============================================================

/** Product brand - Mitsubishi or Danfoss */
export type ProductBrand = 'mitsubishi' | 'danfoss';

/** Product category - industrial automation equipment types */
export type ProductCategory = 'inverter' | 'plc' | 'hmi' | 'servo';

/** Stock availability status */
export type StockStatus = 'inStock' | 'lowStock' | 'outOfStock' | 'leadTime';

/** Order lifecycle status */
export type OrderStatus = 'pending' | 'processing' | 'shipped' | 'delivered' | 'cancelled';

/** BCA Virtual Account status */
export type BcaVaStatus = 'ACTIVE' | 'PAID' | 'EXPIRED' | 'FAILED';

/** Project status for B2B bulk purchases */
export type ProjectStatus = 'planning' | 'active' | 'completed' | 'onHold';

// ============================================================
// USER & ADDRESS
// ============================================================

/**
 * User profile extending Supabase Auth users.
 * B2B context: buyers are companies with optional NPWP.
 */
export interface UserProfile {
  id: string;           // UUID, references auth.users
  email: string;
  name: string;
  company: string | null;
  phone: string;
  npwp: string | null;
  joinedAt: string;     // ISO 8601 timestamp
}

/**
 * Shipping/billing address for a user.
 * Multiple addresses per user, one can be default.
 */
export interface Address {
  id: string;
  userId: string;
  name: string;         // Address label, e.g. "Kantor"
  fullName: string;     // Recipient name
  company: string | null;
  phone: string;
  address: string;
  city: string;
  province: string;
  postalCode: string;
  kecamatan: string | null;
  kelurahan: string | null;
  notes: string | null;
  npwp: string | null;
  isDefault: boolean;
  createdAt: string;
}

// ============================================================
// PRODUCT
// ============================================================

/**
 * Product in the catalog.
 * Industrial automation parts (Inverter, PLC, HMI, Servo).
 * Specifications stored as JSONB key-value pairs.
 */
export interface Product {
  id: string;
  sku: string;          // e.g. "MIT-INV-001"
  name: string;
  brand: ProductBrand;
  category: ProductCategory;
  series: string;
  subSeries: string | null;
  variant: string | null;
  price: number;        // IDR, integer
  originalPrice: number | null;
  stock: number | null;
  stockStatus: StockStatus;
  stockLeadTime: string | null;
  primaryImage: string; // Asset path, e.g. "assets/images/products/mitsubishi/inverter/..."
  galleryImages: string[] | null;
  description: string | null;
  specifications: Record<string, string> | null;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}

// ============================================================
// CART
// ============================================================

/**
 * Shopping cart item.
 * One item per product per user (quantity aggregated).
 */
export interface CartItem {
  id: string;
  userId: string;
  productId: string;
  quantity: number;
  createdAt: string;
  updatedAt: string;
}

/**
 * Cart item with product details for display.
 */
export interface CartItemWithProduct extends CartItem {
  product: Product;
}

// ============================================================
// ORDER
// ============================================================

/**
 * Customer order.
 * Contains snapshot of shipping address and payment info.
 */
export interface Order {
  id: string;
  orderNumber: string;  // e.g. "OTM-20240101-0001"
  userId: string | null;
  status: OrderStatus;
  subtotal: number;     // IDR, integer
  shippingCost: number;
  tax: number;
  discount: number;
  total: number;
  paymentMethod: string | null;  // e.g. 'bca_va'
  vaNumber: string | null;       // BCA VA number snapshot
  paymentDeadline: string | null;
  shippingAddressName: string | null;
  shippingAddressFull: string | null;
  createdAt: string;
  updatedAt: string;
}

/**
 * Order line item.
 * Product details snapshotted at time of order.
 */
export interface OrderItem {
  id: string;
  orderId: string;
  productId: string | null;
  productName: string;
  productImage: string;
  price: number;        // IDR, integer
  quantity: number;
}

/**
 * Order with items for detailed view.
 */
export interface OrderWithItems extends Order {
  items: OrderItem[];
}

// ============================================================
// BCA VIRTUAL ACCOUNT
// ============================================================

/**
 * BCA Virtual Account transaction record.
 * Source of truth for VA payment state.
 */
export interface BcaVaRecord {
  id: string;
  orderId: string;
  vaNumber: string;
  amount: number;       // IDR, integer
  status: BcaVaStatus;
  expiryDate: string;
  rawResponse: Record<string, unknown> | null;
  createdAt: string;
  updatedAt: string;
}

// ============================================================
// PROJECT (B2B Bulk Purchases)
// ============================================================

/**
 * B2B project for bulk purchasing.
 * Allows customers to organize purchases for specific projects.
 */
export interface Project {
  id: string;
  userId: string;
  name: string;
  description: string | null;
  status: ProjectStatus;
  deadline: string | null;
  createdAt: string;
  updatedAt: string;
}

/**
 * Item within a B2B project.
 */
export interface ProjectItem {
  id: string;
  projectId: string;
  productId: string | null;
  productName: string;
  productImage: string | null;
  price: number;        // IDR, integer
  quantity: number;
}

// ============================================================
// API REQUEST/RESPONSE TYPES
// ============================================================

/**
 * Pagination parameters for list endpoints.
 */
export interface PaginationParams {
  page: number;
  limit: number;
}

/**
 * Paginated response metadata.
 */
export interface PaginationMeta {
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

/**
 * Generic API response wrapper.
 */
export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: {
    code: string;
    message: string;
    details?: unknown;
  };
}

/**
 * Authenticated user context from JWT.
 */
export interface AuthUser {
  id: string;
  email: string;
  role?: string;
}