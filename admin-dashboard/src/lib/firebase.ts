import { initializeApp } from 'firebase/app'
import { getAuth, RecaptchaVerifier, signInWithPhoneNumber, ConfirmationResult } from 'firebase/auth'

const firebaseConfig = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY,
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN,
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID,
  storageBucket: process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.NEXT_PUBLIC_FIREBASE_APP_ID,
  measurementId: process.env.NEXT_PUBLIC_FIREBASE_MEASUREMENT_ID
}

const app = initializeApp(firebaseConfig)
export const auth = getAuth(app)

let confirmationResult: ConfirmationResult | null = null

export const setupRecaptcha = (containerId: string) => {
  if (typeof window !== 'undefined') {
    const recaptchaVerifier = new RecaptchaVerifier(auth, containerId, {
      size: 'invisible',
    })
    return recaptchaVerifier
  }
  return null
}

export const sendOtp = async (phone: string, recaptchaVerifier: RecaptchaVerifier) => {
  try {
    confirmationResult = await signInWithPhoneNumber(auth, phone, recaptchaVerifier)
    return { success: true }
  } catch (error: any) {
    return { success: false, error: error.message }
  }
}

export const verifyOtp = async (otp: string) => {
  if (!confirmationResult) {
    return { success: false, error: 'Please request OTP first' }
  }
  try {
    const result = await confirmationResult.confirm(otp)
    const idToken = await result.user.getIdToken()
    return { success: true, idToken, phone: result.user.phoneNumber }
  } catch (error: any) {
    return { success: false, error: 'Invalid OTP' }
  }
}
