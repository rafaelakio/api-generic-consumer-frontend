/**
 * Backend Service
 *
 * Handles communication with the backend API.
 * Supports both direct backend connection and API Gateway routing.
 */

export function getBackendUrl(): string {
  const url = process.env.NEXT_PUBLIC_BACKEND_URL ?? 'http://localhost:8080';
  
  // Remove trailing slash if present
  return url.endsWith('/') ? url.slice(0, -1) : url;
}

/**
 * Check if using API Gateway
 * API Gateway URLs typically contain 'restapis' or '4566' (LocalStack port)
 */
export function isUsingApiGateway(): boolean {
  const url = getBackendUrl();
  return url.includes('restapis') || url.includes('4566') || url.includes('apigateway');
}

/**
 * Build endpoint URL
 * Handles both direct backend and API Gateway routing
 */
function buildEndpointUrl(endpoint: string): string {
  const baseUrl = getBackendUrl();
  
  // If using API Gateway, endpoints are already prefixed with /api in the gateway config
  // Otherwise, add /api prefix for direct backend calls
  if (isUsingApiGateway()) {
    // API Gateway already routes /api/* to backend
    return `${baseUrl}${endpoint}`;
  }
  
  // Direct backend call
  return `${baseUrl}${endpoint}`;
}

export async function proxyRequest(body: unknown, token: string): Promise<Response> {
  const url = buildEndpointUrl('/api/proxy');
  
  return fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify(body),
  });
}

export async function auditLog(payload: unknown, token: string): Promise<void> {
  try {
    const url = buildEndpointUrl('/api/audit-log');
    
    await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify(payload),
    });
  } catch (error) {
    // Log error but don't throw - audit logging should not break the main flow
    console.warn('Failed to send audit log:', error);
  }
}

/**
 * Get authentication token from backend
 * Used for development/testing with admin credentials
 */
export async function getAdminToken(username: string, password: string): Promise<string> {
  const url = buildEndpointUrl('/auth/token');
  
  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ username, password }),
  });

  if (!response.ok) {
    throw new Error('Failed to get admin token');
  }

  const data = await response.json();
  return data.token;
}

/**
 * Health check
 * Verifies backend connectivity
 */
export async function healthCheck(): Promise<boolean> {
  try {
    const url = buildEndpointUrl('/actuator/health');
    const response = await fetch(url, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    });
    
    return response.ok;
  } catch {
    return false;
  }
}
