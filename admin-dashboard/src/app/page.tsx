'use client'
import { useState, useEffect, useRef } from 'react'
import { useRouter } from 'next/navigation'
import { useAuthStore } from '@/store/authStore'
import { auth, setupRecaptcha, sendOtp, verifyOtp } from '@/lib/firebase'
import { RecaptchaVerifier } from 'firebase/auth'
import api from '@/lib/api'
import toast from 'react-hot-toast'

export default function LoginPage() {
  const [phone, setPhone] = useState('')
  const [otp, setOtp] = useState('')
  const [otpSent, setOtpSent] = useState(false)
  const [isLoading, setIsLoading] = useState(false)
  const recaptchaRef = useRef<RecaptchaVerifier | null>(null)
  const { setToken, setUser } = useAuthStore()
  const router = useRouter()

  useEffect(() => {
    recaptchaRef.current = setupRecaptcha('recaptcha-container')
  }, [])

  const handleSendOtp = async () => {
    if (!phone) return toast.error('Enter phone number')
    if (!recaptchaRef.current) return toast.error('Recaptcha not loaded')
    
    setIsLoading(true)
    const result = await sendOtp(phone, recaptchaRef.current)
    setIsLoading(false)
    
    if (result.success) {
      setOtpSent(true)
      toast.success('OTP sent!')
    } else {
      toast.error(result.error || 'Failed to send OTP')
    }
  }

  const handleLogin = async () => {
    if (!otp) return toast.error('Enter OTP')
    
    setIsLoading(true)
    const result = await verifyOtp(otp)
    
    if (!result.success) {
      setIsLoading(false)
      return toast.error(result.error || 'Invalid OTP')
    }

    try {
      // Send Firebase token to backend
      const response = await api.post('/auth/verify-otp', {
        phone: result.phone,
        firebaseToken: result.idToken,
      })
      
      const data = response.data.data
      
      if (data.role !== 'ADMIN') {
        setIsLoading(false)
        return toast.error('Admin access only')
      }
      
      setToken(data.token)
      setUser({ id: data.userId, name: data.name, phone: data.phone, role: data.role })
      toast.success('Login successful!')
      router.push('/dashboard')
    } catch (error) {
      toast.error('Login failed')
    }
    setIsLoading(false)
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-100">
      <div className="bg-white p-8 rounded-lg shadow-md w-full max-w-md">
        <h1 className="text-2xl font-bold text-center mb-6">AssistBridge Admin</h1>
        <input
          type="tel"
          placeholder="Phone Number (+91...)"
          value={phone}
          onChange={(e) => setPhone(e.target.value)}
          className="w-full p-3 border rounded mb-4"
          disabled={otpSent}
        />
        {otpSent && (
          <input
            type="text"
            placeholder="Enter OTP"
            value={otp}
            onChange={(e) => setOtp(e.target.value)}
            className="w-full p-3 border rounded mb-4"
            maxLength={6}
          />
        )}
        <button
          onClick={otpSent ? handleLogin : handleSendOtp}
          disabled={isLoading}
          className="w-full bg-blue-600 text-white p-3 rounded hover:bg-blue-700 disabled:opacity-50"
        >
          {isLoading ? 'Loading...' : otpSent ? 'Login' : 'Send OTP'}
        </button>
        <div id="recaptcha-container"></div>
      </div>
    </div>
  )
}
