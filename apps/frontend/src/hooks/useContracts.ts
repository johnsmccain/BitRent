import { useQuery, useMutation } from '@tanstack/react-query'
import { api } from '@/lib/api'

export function usePropertyInfo(id: string | undefined, sender?: string) {
  return useQuery({
    queryKey: ['property-info', id, sender],
    queryFn: () => api.getPropertyInfo(id as string, sender),
    enabled: !!id,
  })
}

export function useUserFractions(principal: string | undefined) {
  return useQuery({
    queryKey: ['user-fractions', principal],
    queryFn: () => api.getUserFractions(principal as string),
    enabled: !!principal,
  })
}

export function usePropertyRevenue(id: string | undefined, sender?: string) {
  return useQuery({
    queryKey: ['property-revenue', id, sender],
    queryFn: () => api.getPropertyRevenue(id as string, sender),
    enabled: !!id,
  })
}

export function useBroadcastTx() {
  return useMutation({
    mutationFn: (rawTxHex: string) => api.broadcastTx(rawTxHex),
  })
}


