'use client'
import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { useAuthStore } from '@/store/authStore'
import { authApi } from '@/lib/api'
import toast from 'react-hot-toast'

export default function LoginPage() {
  const [phone, setPhone] = useState('')
  const [otp, setOtp] = useState('')
  const [otpSent, setOtpSent] = useState(false)
  const { login, isLoading } = useAuthStore()
  const router = useRouter()

  const handleSendOtp = async () => {
    if (!phone) return toast.error('Enter phone number')
    try {
      await authApi.sendOtp(phone)
      setOtpSent(true)
      toast.success('OTP sent!')
    } catch {
      toast.error('Failed to send OTP')
    }
  }

  const handleLogin = async () => {
    if (!otp) return toast.error('Enter OTP')
    const isAdmin = await login(phone, otp)
    if (isAdmin) {
      router.push('/dashboard')
    } else {
      toast.error('Admin access only')
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-100">
      <div className="bg-white p-8 rounded-lg shadow-md w-full max-w-md">
        <h1 className="text-2xl font-bold text-center mb-6">AssistBridge Admin</h1>
        <input
          type="tel"
          placeholder="Phone Number"
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
      </div>
    </div>
  )
}
