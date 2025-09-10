import type { Request, Response } from 'express'

const STACKS_API_URL = process.env.STACKS_API_URL || 'http://localhost:3999'

async function callReadOnly(
  contractAddress: string,
  contractName: string,
  functionName: string,
  sender: string,
  args: unknown[]
) {
  const url = `${STACKS_API_URL}/v2/contracts/call-read/${contractAddress}/${contractName}/${functionName}`
  const body = {
    sender,
    arguments: args.map((a) => Buffer.from(JSON.stringify(a)).toString('base64')),
  }
  const res = await fetch(url, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify(body),
  })
  if (!res.ok) {
    const text = await res.text()
    throw new Error(`call-read failed: ${res.status} ${text}`)
  }
  return res.json()
}

export function registerContractRoutes(app: import('express').Express) {
  // Read: property info
  app.get('/api/property/:id/info', async (req: Request, res: Response) => {
    try {
      const propertyId = req.params.id
      const sender = req.query.sender as string || 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5'
      const [address, name] = (process.env.NFT_CONTRACT || 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.bitrent-fractional-nft').split('.')
      const result = await callReadOnly(address, name, 'get-property-info', sender, [
        { type: 'string-ascii', value: propertyId },
      ])
      res.json(result)
    } catch (e: any) {
      res.status(500).json({ error: e.message })
    }
  })

  // Read: user fractions
  app.get('/api/user/:principal/fractions', async (req: Request, res: Response) => {
    try {
      const user = req.params.principal
      const sender = user
      const [address, name] = (process.env.NFT_CONTRACT || 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.bitrent-fractional-nft').split('.')
      const result = await callReadOnly(address, name, 'get-user-fractions', sender, [
        { type: 'principal', value: user },
      ])
      res.json(result)
    } catch (e: any) {
      res.status(500).json({ error: e.message })
    }
  })

  // Read: property revenue
  app.get('/api/property/:id/revenue', async (req: Request, res: Response) => {
    try {
      const propertyId = req.params.id
      const sender = req.query.sender as string || 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5'
      const [address, name] = (process.env.REVENUE_CONTRACT || 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.bitrent-revenue-split').split('.')
      const result = await callReadOnly(address, name, 'get-property-revenue', sender, [
        { type: 'string-ascii', value: propertyId },
      ])
      res.json(result)
    } catch (e: any) {
      res.status(500).json({ error: e.message })
    }
  })

  // Write: broadcast signed contract-call transaction (hex string)
  app.post('/api/tx/broadcast', async (req: Request, res: Response) => {
    try {
      const rawTx: string | undefined = req.body?.rawTx
      if (!rawTx || typeof rawTx !== 'string') {
        return res.status(400).json({ error: 'rawTx (hex string) is required' })
      }
      const url = `${STACKS_API_URL}/v2/transactions`
      const r = await fetch(url, {
        method: 'POST',
        headers: { 'content-type': 'application/octet-stream' },
        body: Buffer.from(rawTx, 'hex')
      })
      const text = await r.text()
      if (!r.ok) {
        return res.status(r.status).send(text)
      }
      // On success, API returns txid as plain text
      return res.json({ txid: text.replace(/\n/g, '') })
    } catch (e: any) {
      res.status(500).json({ error: e.message })
    }
  })
}


