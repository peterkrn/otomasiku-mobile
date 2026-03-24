/**
 * Typed configuration loaded from Deno environment variables.
 * Throws clear errors if any required variable is missing.
 */

/**
 * Application configuration interface.
 * Contains all required environment variables with types.
 */
export interface Config {
  supabaseUrl: string;
  supabaseAnonKey: string;
  supabaseServiceRoleKey: string;
  bca: {
    clientId: string;
    clientSecret: string;
    apiBaseUrl: string;
    vaCompanyCode: string;
    callbackToken: string;
  };
}

/** Cached config instance */
let cachedConfig: Config | null = null;

/**
 * Required environment variable names.
 */
const REQUIRED_ENV_VARS = [
  'SUPABASE_URL',
  'SUPABASE_ANON_KEY',
  'SUPABASE_SERVICE_ROLE_KEY',
  'BCA_CLIENT_ID',
  'BCA_CLIENT_SECRET',
  'BCA_API_BASE_URL',
  'BCA_VA_COMPANY_CODE',
  'BCA_CALLBACK_TOKEN',
] as const;

/**
 * Gets a required environment variable.
 * Throws an error if the variable is missing or empty.
 *
 * @param name - The environment variable name
 * @returns The environment variable value
 * @throws Error if the variable is missing
 */
function getRequiredEnv(name: string): string {
  const value = Deno.env.get(name);

  if (!value || value.trim() === '') {
    throw new Error(
      `Missing required environment variable: ${name}. ` +
      `Please set it in your Supabase Edge Function environment.`
    );
  }

  return value.trim();
}

/**
 * Gets an optional environment variable.
 * Returns undefined if the variable is missing or empty.
 *
 * @param name - The environment variable name
 * @returns The environment variable value or undefined
 */
function getOptionalEnv(name: string): string | undefined {
  const value = Deno.env.get(name);
  return value && value.trim() !== '' ? value.trim() : undefined;
}

/**
 * Validates that all required environment variables are present.
 * Returns a list of missing variables.
 *
 * @returns Array of missing variable names
 */
export function validateEnv(): string[] {
  const missing: string[] = [];

  for (const name of REQUIRED_ENV_VARS) {
    const value = Deno.env.get(name);
    if (!value || value.trim() === '') {
      missing.push(name);
    }
  }

  return missing;
}

/**
 * Loads and returns the application configuration.
 * Caches the config after first load for performance.
 *
 * @returns The application configuration
 * @throws Error if any required environment variable is missing
 */
export function getConfig(): Config {
  if (cachedConfig) {
    return cachedConfig;
  }

  // Validate all required variables
  const missing = validateEnv();
  if (missing.length > 0) {
    throw new Error(
      `Missing required environment variables: ${missing.join(', ')}. ` +
      `Please set them in your Supabase Edge Function environment.`
    );
  }

  // Build config object
  cachedConfig = {
    supabaseUrl: getRequiredEnv('SUPABASE_URL'),
    supabaseAnonKey: getRequiredEnv('SUPABASE_ANON_KEY'),
    supabaseServiceRoleKey: getRequiredEnv('SUPABASE_SERVICE_ROLE_KEY'),
    bca: {
      clientId: getRequiredEnv('BCA_CLIENT_ID'),
      clientSecret: getRequiredEnv('BCA_CLIENT_SECRET'),
      apiBaseUrl: getRequiredEnv('BCA_API_BASE_URL'),
      vaCompanyCode: getRequiredEnv('BCA_VA_COMPANY_CODE'),
      callbackToken: getRequiredEnv('BCA_CALLBACK_TOKEN'),
    },
  };

  return cachedConfig;
}

/**
 * Clears the cached config. Useful for testing.
 */
export function clearConfigCache(): void {
  cachedConfig = null;
}

/**
 * Returns a safe (non-sensitive) representation of the config for logging.
 * Masks secrets like API keys and tokens.
 */
export function getSafeConfigForLogging(config: Config): Record<string, unknown> {
  return {
    supabaseUrl: config.supabaseUrl,
    supabaseAnonKey: `${config.supabaseAnonKey.slice(0, 8)}...`,
    supabaseServiceRoleKey: '[REDACTED]',
    bca: {
      clientId: config.bca.clientId,
      clientSecret: '[REDACTED]',
      apiBaseUrl: config.bca.apiBaseUrl,
      vaCompanyCode: config.bca.vaCompanyCode,
      callbackToken: '[REDACTED]',
    },
  };
}