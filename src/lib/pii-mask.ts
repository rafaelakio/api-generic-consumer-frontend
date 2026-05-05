type FieldType = 'name' | 'cpf' | 'cnpj' | 'email' | 'phone' | 'street' | 'number_field' | 'cep' | 'card' | 'generic';

const KEY_TYPE_MAP: Record<string, FieldType> = {
  nome: 'name', name: 'name', fullname: 'name', firstname: 'name', lastname: 'name', sobrenome: 'name',
  nomemae: 'name', nomepai: 'name', mother: 'name', father: 'name', mae: 'name', pai: 'name',
  cpf: 'cpf', cnpj: 'cnpj', rg: 'generic', document: 'generic', documento: 'generic',
  email: 'email', mail: 'email',
  phone: 'phone', telefone: 'phone', celular: 'phone', mobile: 'phone', fone: 'phone',
  rua: 'street', logradouro: 'street', avenida: 'street', endereco: 'street', endereço: 'street',
  address: 'street', bairro: 'street', complemento: 'street',
  numero: 'number_field', number: 'number_field',
  cep: 'cep', zipcode: 'cep', zip: 'cep',
  password: 'generic', senha: 'generic', secret: 'generic', token: 'generic',
  card: 'card', cartao: 'card', cartão: 'card', account: 'generic', conta: 'generic',
  agencia: 'generic', agência: 'generic',
};

function fieldTypeForKey(key: string): FieldType | null {
  const lower = key.toLowerCase();
  if (KEY_TYPE_MAP[lower]) return KEY_TYPE_MAP[lower];
  for (const [k, t] of Object.entries(KEY_TYPE_MAP)) {
    if (lower.includes(k)) return t;
  }
  return null;
}

function maskDigitsByPosition(value: string, keepStart: number, keepEnd: number): string {
  const digits = value.replace(/\D/g, '');
  const total = digits.length;
  let digitIdx = 0;
  return value.replace(/\d/g, () => {
    const pos = digitIdx++;
    if (pos < keepStart || pos >= total - keepEnd) return value[pos] ?? '*';
    return '*';
  });
}

function applyTypedMask(value: string, type: FieldType): string {
  switch (type) {
    case 'name': { const p = value.trim().split(/\s+/); return p.length === 1 ? `${p[0][0]}.` : `${p[0]} ${p[p.length - 1][0].toUpperCase()}.`; }
    case 'cpf':  return maskDigitsByPosition(value, 0, 2);
    case 'cnpj': return maskDigitsByPosition(value, 0, 2);
    case 'email': { const at = value.indexOf('@'); return at === -1 ? `${value[0]}***` : `${value[0]}***${value.slice(at)}`; }
    case 'phone': return maskDigitsByPosition(value, 5, 4);
    case 'street': { const p = value.trim().split(/\s+/); return p.length === 1 ? `${p[0][0]}.` : `${p.slice(0, -1).join(' ')} ${p[p.length - 1][0].toUpperCase()}.`; }
    case 'number_field': return '***';
    case 'cep': return maskDigitsByPosition(value, 3, 3);
    case 'card': return maskDigitsByPosition(value, 4, 4);
    case 'generic': return value.length <= 4 ? '*'.repeat(value.length) : `${value[0]}${'*'.repeat(value.length - 3)}${value.slice(-2)}`;
  }
}

const INLINE_PATTERNS: { type: FieldType; regex: RegExp }[] = [
  { type: 'email', regex: /\b[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}\b/g },
  { type: 'cpf',   regex: /\b\d{3}\.?\d{3}\.?\d{3}-?\d{2}\b/g },
  { type: 'cnpj',  regex: /\b\d{2}\.?\d{3}\.?\d{3}\/?\.?\d{4}-?\d{2}\b/g },
  { type: 'phone', regex: /(\+?55\s?)?(\(?\d{2}\)?\s?)(\d{4,5}[\s\-]?\d{4})\b/g },
  { type: 'card',  regex: /\b(?:\d{4}[\s\-]?){3}\d{4}\b/g },
];

function maskInlinePatterns(value: string): string {
  let result = value;
  for (const { type, regex } of INLINE_PATTERNS) {
    regex.lastIndex = 0;
    result = result.replace(regex, (match) => applyTypedMask(match, type));
  }
  return result;
}

function maskValue(value: unknown, keyHint?: string): unknown {
  const fieldType = keyHint ? fieldTypeForKey(keyHint) : null;
  if (typeof value === 'string') return fieldType ? applyTypedMask(value, fieldType) : maskInlinePatterns(value);
  if (typeof value === 'number') return fieldType === 'number_field' ? '***' : fieldType ? applyTypedMask(String(value), fieldType) : value;
  if (Array.isArray(value)) return value.map((item) => maskValue(item, keyHint));
  if (value !== null && typeof value === 'object') {
    const masked: Record<string, unknown> = {};
    for (const [k, v] of Object.entries(value as Record<string, unknown>)) masked[k] = maskValue(v, k);
    return masked;
  }
  return value;
}

function countPiiFields(value: unknown): number {
  if (value === null || typeof value !== 'object') return 0;
  let count = 0;
  for (const [k, v] of Object.entries(value as Record<string, unknown>)) {
    if (fieldTypeForKey(k)) count++;
    if (v !== null && typeof v === 'object') count += countPiiFields(v);
  }
  return count;
}

export function maskPiiBody(raw: string): string {
  try { return JSON.stringify(maskValue(JSON.parse(raw)), null, 2); }
  catch { return maskInlinePatterns(raw); }
}

export function countPiiMatches(raw: string): number {
  try { return countPiiFields(JSON.parse(raw)); }
  catch {
    let count = 0;
    for (const { regex } of INLINE_PATTERNS) { regex.lastIndex = 0; count += (raw.match(regex) ?? []).length; }
    return count;
  }
}
