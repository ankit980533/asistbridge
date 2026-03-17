'use client'
import { useEffect, useState } from 'react'
import { FileText, Users, UserCheck, CheckCircle, Clock, XCircle } from 'lucide-react'
import { adminApi } from '@/lib/api'
import { DashboardStats } from '@/types'
import StatsCard from '@/components/StatsCard'

export default function DashboardPage() {
  const [stats, setStats] = useState<DashboardStats | null>(null)

  useEffect(() => {
    adminApi.getDashboard().then((res) => setStats(res.data.data))
  }, [])

  if (!stats) return <div className="flex justify-center p-8">Loading...</div>

  return (
    <div>
      <h1 className="text-2xl font-bold mb-6">Dashboard</h1>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatsCard title="Total Requests" value={stats.totalRequests} icon={FileText} color="bg-blue-500" />
        <StatsCard title="Pending" value={stats.pendingRequests} icon={Clock} color="bg-yellow-500" />
        <StatsCard title="Completed" value={stats.completedRequests} icon={CheckCircle} color="bg-green-500" />
        <StatsCard title="Cancelled" value={stats.cancelledRequests} icon={XCircle} color="bg-red-500" />
        <StatsCard title="Total Users" value={stats.totalUsers} icon={Users} color="bg-purple-500" />
        <StatsCard title="Total Volunteers" value={stats.totalVolunteers} icon={UserCheck} color="bg-indigo-500" />
        <StatsCard title="Active Volunteers" value={stats.activeVolunteers} icon={UserCheck} color="bg-teal-500" />
        <StatsCard title="Assigned" value={stats.assignedRequests} icon={FileText} color="bg-orange-500" />
      </div>
    </div>
  )
}
