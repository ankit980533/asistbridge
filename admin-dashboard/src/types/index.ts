export interface User {
  id: string
  name: string
  phone: string
  email?: string
  role: 'ADMIN' | 'VOLUNTEER' | 'VISUALLY_IMPAIRED'
  active: boolean
  createdAt: string
}

export interface HelpRequest {
  id: string
  userId: string
  userName: string
  userPhone: string
  type: 'ONLINE_HELP' | 'WRITER_HELP' | 'NAVIGATION_ASSISTANCE' | 'DOCUMENT_READING'
  description: string
  latitude?: number
  longitude?: number
  address?: string
  status: 'PENDING' | 'ADMIN_REVIEW' | 'ASSIGNED' | 'IN_PROGRESS' | 'COMPLETED' | 'CANCELLED'
  assignedVolunteerId?: string
  assignedVolunteerName?: string
  assignedAt?: string
  completedAt?: string
  rating?: number
  createdAt: string
}

export interface DashboardStats {
  totalRequests: number
  pendingRequests: number
  assignedRequests: number
  completedRequests: number
  cancelledRequests: number
  totalUsers: number
  totalVolunteers: number
  activeVolunteers: number
}
