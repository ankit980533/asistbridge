import { create } from 'zustand'

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
  setToken: (token: string) => void
  setUser: (user: User) => void
  logout: () => void
  checkAuth: () => void
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  token: typeof window !== 'undefined' ? localStorage.getItem('token') : null,
  isLoading: false,
  
  setToken: (token) => {
    localStorage.setItem('token', token)
    set({ token })
  },
  
  setUser: (user) => {
    set({ user })
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
