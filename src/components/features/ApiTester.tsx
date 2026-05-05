'use client';

import { useState } from 'react';
import RequestForm from './RequestForm';
import ResponseViewer from './ResponseViewer';
import SessionGate from './SessionGate';
import SessionSummary from './SessionSummary';
import { useChangeSession } from '@/context/ChangeSessionContext';
import { useAuth } from '@/auth/useAuth';
import { proxyRequest } from '@/services/backend.service';
import type { ApiRequest, ApiResponse } from '@/types';

export default function ApiTester() {
  const { session, summaryVisible, logCall } = useChangeSession();
  const { getToken } = useAuth();
  const [response, setResponse] = useState<ApiResponse | null>(null);
  const [loading, setLoading] = useState(false);

  async function handleRequest(req: ApiRequest) {
    setLoading(true);
    setResponse(null);

    try {
      const token = await getToken();
      if (!token) {
        const errResponse: ApiResponse = {
          statusCode: 401, statusText: 'Unauthorized',
          headers: {}, body: null, responseTimeMs: 0,
          error: 'Sessão expirada. Faça login novamente.',
        };
        setResponse(errResponse);
        return;
      }

      const res = await proxyRequest({ request: req }, token);
      const json = await res.json();

      if (!res.ok) {
        const errResponse: ApiResponse = {
          statusCode: res.status, statusText: res.statusText,
          headers: {}, body: json, responseTimeMs: 0,
          error: json?.error ?? 'Proxy error',
        };
        logCall(req.method, req.url, errResponse);
        setResponse(errResponse);
        return;
      }

      const apiResponse = json.data as ApiResponse;
      logCall(req.method, req.url, apiResponse);
      setResponse(apiResponse);
    } catch (err) {
      const errResponse: ApiResponse = {
        statusCode: 0, statusText: 'Network Error',
        headers: {}, body: null, responseTimeMs: 0,
        error: err instanceof Error ? err.message : 'Unknown network error',
      };
      logCall(req.method, req.url, errResponse);
      setResponse(errResponse);
    } finally {
      setLoading(false);
    }
  }

  return (
    <>
      {!session && !summaryVisible && <SessionGate />}
      <SessionSummary />
      <div className="grid grid-cols-1 xl:grid-cols-2 gap-6">
        <section className="bg-white rounded-2xl border border-gray-200 shadow-sm p-6 flex flex-col gap-4">
          <h2 className="text-base font-semibold text-gray-900">Request</h2>
          <RequestForm onSubmit={handleRequest} loading={loading} />
        </section>
        <section className="bg-white rounded-2xl border border-gray-200 shadow-sm p-6 flex flex-col gap-4">
          <h2 className="text-base font-semibold text-gray-900">Response</h2>
          <ResponseViewer response={response} />
        </section>
      </div>
    </>
  );
}
