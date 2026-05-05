'use client';

import { PublicClientApplication } from '@azure/msal-browser';
import { MsalProvider } from '@azure/msal-react';
import { msalConfig } from '@/auth/msalConfig';
import { ChangeSessionProvider } from '@/context/ChangeSessionContext';
import { useMemo } from 'react';

export function Providers({ children }: { children: React.ReactNode }) {
  const msalInstance = useMemo(() => new PublicClientApplication(msalConfig), []);

  return (
    <MsalProvider instance={msalInstance}>
      <ChangeSessionProvider>{children}</ChangeSessionProvider>
    </MsalProvider>
  );
}
