import React from 'react'
import { Connect, useConnect } from '@stacks/connect-react'
import type { AppConfig } from '@stacks/connect-react'

const appDetails: AppConfig['appDetails'] = {
  name: 'BitRent',
  icon: '/favicon.ico',
}

const network = undefined // default to mainnet/testnet via wallet UI

export function StacksProvider({ children }: { children: React.ReactNode }) {
  return (
    <Connect authOptions={{ appDetails, redirectTo: '/', onFinish: () => {}, userSession: undefined as any, network }}>
      {children}
    </Connect>
  )
}

export function ConnectButton() {
  const { doOpenAuth, isAuthenticated, doSignOut } = useConnect()
  return (
    <button
      onClick={() => (isAuthenticated ? doSignOut() : doOpenAuth())}
      className="px-3 py-1 rounded bg-black text-white text-sm"
    >
      {isAuthenticated ? 'Sign out' : 'Connect Wallet'}
    </button>
  )
}


