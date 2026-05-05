'use client';

import { useMsal } from '@azure/msal-react';
import { loginRequest } from './msalConfig';
import { getBackendUrl } from '@/services/backend.service';

export interface AuthUser {
  name: string;
  email: string;
  token: string;
  provider: 'azure' | 'admin';
}

let adminToken: string | null = null;

export function setAdminToken(token: string) {
  adminToken = token;
  sessionStorage.setItem('admin_token', token);
}

export function loadAdminToken() {
  if (!adminToken) adminToken = sessionStorage.getItem('admin_token');
  return adminToken;
}

export function clearAdminToken() {
  adminToken = null;
  sessionStorage.removeItem('admin_token');
}

export function useAuth() {
  const { instance, accounts } = useMsal();
  const account = accounts[0];

  async function getToken(): Promise<string | null> {
    const stored = loadAdminToken();
    if (stored) return stored;

    if (!account) return null;
    try {
      const result = await instance.acquireTokenSilent({ ...loginRequest, account });
      return result.idToken;
    } catch {
      return null;
    }
  }

  async function signOut() {
    clearAdminToken();
    if (account) {
      await instance.logoutPopup({ account });
    } else {
      window.location.href = '/login/';
    }
  }

  const user: AuthUser | null = (() => {
    const stored = loadAdminToken();
    if (stored) {
      try {
        const payload = JSON.parse(atob(stored.split('.')[1]));
        return { name: payload.name ?? payload.sub, email: payload.email ?? `${payload.sub}@local`, token: stored, provider: 'admin' };
      } catch { return null; }
    }
    if (!account) return null;
    return {
      name: account.name ?? account.username,
      email: account.username,
      token: '',
      provider: 'azure',
    };
  })();

  return { user, getToken, signOut };
}

export async function adminLogin(username: string, password: string): Promise<string> {
  const res = await fetch(`${getBackendUrl()}/auth/token`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ username, password }),
  });
  if (!res.ok) throw new Error('Credenciais inválidas');
  const data = await res.json();
  setAdminToken(data.token);
  return data.token;
}
