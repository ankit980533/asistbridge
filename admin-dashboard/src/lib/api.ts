import axios from 'axios'

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'https://asistbridge.onrender.com/api'

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: { 'Content-Type': 'application/json' },
})

api.interceptors.request.use((config) => {
  const token = typeof window !== 'undefined' ? localStorage.getItem('token') : null
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (typeof window !== 'undefined' && (error.response?.status === 401 || error.response?.status === 403)) {
      localStorage.removeItem('token')
      window.location.href = '/'
    }
    return Promise.reject(error)
  }
)

export const authApi = {
  sendOtp: (phone: string) => api.post('/auth/send-otp', { phone }),
  verifyOtp: (phone: string, otp: string) => api.post('/auth/verify-otp', { phone, otp }),
}

export const adminApi = {
  getDashboard: () => api.get('/admin/dashboard'),
  getRequests: () => api.get('/admin/requests'),
  getPendingRequests: () => api.get('/admin/requests/pending'),
  assignVolunteer: (requestId: string, volunteerId: string) => 
    api.post('/admin/assign', { requestId, volunteerId }),
  getUsers: () => api.get('/admin/users'),
  getVolunteers: () => api.get('/admin/volunteers'),
  getActiveVolunteers: () => api.get('/admin/volunteers/active'),
}

export default api
