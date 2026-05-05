export interface ChangeSession {
  changeNumber: string;
  startTime: Date;
  endTime: Date;
  openedAt: Date;
  closedAt?: Date;
  openedBy: string;
}

export interface CallLog {
  seq: number;
  timestamp: Date;
  method: string;
  url: string;
  statusCode: number;
  statusText: string;
  responseTimeMs: number;
  error?: string;
}

export type HttpMethod = 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE';

export interface RequestHeader {
  key: string;
  value: string;
  enabled: boolean;
}

export interface RequestFile {
  id: string;
  name: string;
  size: number;
  type: string;
  content: string;
  fieldName?: string;
}

export interface ApiRequest {
  url: string;
  method: HttpMethod;
  headers: RequestHeader[];
  body: string;
  bypassSsl: boolean;
  certificate?: string;
  credentialsSecretName?: string;
  contentType?: 'json' | 'raw' | 'form-data' | 'x-www-form-urlencoded';
  files?: RequestFile[];
  formData?: Record<string, string>;
}

export interface ApiResponse {
  statusCode: number;
  statusText: string;
  headers: Record<string, string>;
  body: unknown;
  responseTimeMs: number;
  error?: string;
}

export interface ProxyResponseBody {
  data: ApiResponse;
}
