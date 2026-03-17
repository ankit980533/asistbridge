import { create } from 'zustand'
import { authApi } from '@/lib/api'

interface User {
  id: string
  name: string
  phone: string
  role: string
}

interface AuthState {
  user: User | null
  token: string | null
  isLoading: boolean
  login: (phone: string, otp: string) => Promise<boolean>
  logout: () => void
  checkAuth: () => void
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  token: typeof window !== 'undefined' ? localStorage.getItem('token') : null,
  isLoading: false,
  
  login: async (phone, otp) => {
    set({ isLoading: true })
    try {
      const res = await authApi.verifyOtp(phone, otp)
      const { token, userId, name, role } = res.data.data
      localStorage.setItem('token', token)
      set({ token, user: { id: userId, name, phone, role }, isLoading: false })
      return role === 'ADMIN'
    } catch {
      set({ isLoading: false })
      return false
    }
  },
  
  logout: () => {
    localStorage.removeItem('token')
    set({ user: null, token: null })
  },
  
  checkAuth: () => {
    const token = localStorage.getItem('token')
    if (!token) set({ user: null, token: null })
  },
}))
