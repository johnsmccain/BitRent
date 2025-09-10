export const API_BASE = process.env.NEXT_PUBLIC_API_BASE || 'http://localhost:4000'

async function http<T>(path: string, init?: RequestInit): Promise<T> {
  const res = await fetch(`${API_BASE}${path}`, {
    ...init,
    headers: {
      'content-type': 'application/json',
      ...(init?.headers || {}),
    },
  })
  if (!res.ok) {
    const text = await res.text()
    throw new Error(text || `HTTP ${res.status}`)
  }
  return res.json() as Promise<T>
}

export const api = {
  getPropertyInfo: (id: string, sender?: string) =>
    http(`/api/property/${encodeURIComponent(id)}/info${sender ? `?sender=${encodeURIComponent(sender)}` : ''}`),
  getUserFractions: (principal: string) =>
    http(`/api/user/${encodeURIComponent(principal)}/fractions`),
  getPropertyRevenue: (id: string, sender?: string) =>
    http(`/api/property/${encodeURIComponent(id)}/revenue${sender ? `?sender=${encodeURIComponent(sender)}` : ''}`),
  broadcastTx: (rawTxHex: string) =>
    http<{ txid: string }>(`/api/tx/broadcast`, {
      method: 'POST',
      body: JSON.stringify({ rawTx: rawTxHex }),
    }),
}


