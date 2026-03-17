'use client'
import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { LayoutDashboard, FileText, Users, UserCheck, LogOut } from 'lucide-react'
import { useAuthStore } from '@/store/authStore'
import { useRouter } from 'next/navigation'

const navItems = [
  { href: '/dashboard', label: 'Dashboard', icon: LayoutDashboard },
  { href: '/dashboard/requests', label: 'Requests', icon: FileText },
  { href: '/dashboard/users', label: 'Users', icon: Users },
  { href: '/dashboard/volunteers', label: 'Volunteers', icon: UserCheck },
]

export default function Sidebar() {
  const pathname = usePathname()
  const { logout } = useAuthStore()
  const router = useRouter()

  const handleLogout = () => {
    logout()
    router.push('/')
  }

  return (
    <aside className="w-64 bg-gray-900 text-white min-h-screen p-4">
      <h1 className="text-xl font-bold mb-8 px-4">AssistBridge</h1>
      <nav className="space-y-2">
        {navItems.map(({ href, label, icon: Icon }) => (
          <Link
            key={href}
            href={href}
            className={`flex items-center gap-3 px-4 py-3 rounded-lg transition ${
              pathname === href ? 'bg-blue-600' : 'hover:bg-gray-800'
            }`}
          >
            <Icon size={20} />
            {label}
          </Link>
        ))}
      </nav>
      <button
        onClick={handleLogout}
        className="flex items-center gap-3 px-4 py-3 mt-8 w-full hover:bg-gray-800 rounded-lg"
      >
        <LogOut size={20} />
        Logout
      </button>
    </aside>
  )
}
