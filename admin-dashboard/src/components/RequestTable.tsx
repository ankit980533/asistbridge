'use client'
import { HelpRequest } from '@/types'
import { format } from 'date-fns'

interface RequestTableProps {
  requests: HelpRequest[]
  onAssign?: (request: HelpRequest) => void
}

const statusColors: Record<string, string> = {
  PENDING: 'bg-yellow-100 text-yellow-800',
  ADMIN_REVIEW: 'bg-orange-100 text-orange-800',
  ASSIGNED: 'bg-blue-100 text-blue-800',
  IN_PROGRESS: 'bg-purple-100 text-purple-800',
  COMPLETED: 'bg-green-100 text-green-800',
  CANCELLED: 'bg-red-100 text-red-800',
}

const typeLabels: Record<string, string> = {
  ONLINE_HELP: 'Online Help',
  WRITER_HELP: 'Writer Help',
  NAVIGATION_ASSISTANCE: 'Navigation',
  DOCUMENT_READING: 'Document Reading',
}

export default function RequestTable({ requests, onAssign }: RequestTableProps) {
  return (
    <div className="overflow-x-auto">
      <table className="w-full bg-white rounded-lg shadow">
        <thead className="bg-gray-50">
          <tr>
            <th className="px-4 py-3 text-left text-sm font-medium text-gray-500">User</th>
            <th className="px-4 py-3 text-left text-sm font-medium text-gray-500">Type</th>
            <th className="px-4 py-3 text-left text-sm font-medium text-gray-500">Status</th>
            <th className="px-4 py-3 text-left text-sm font-medium text-gray-500">Volunteer</th>
            <th className="px-4 py-3 text-left text-sm font-medium text-gray-500">Date</th>
            <th className="px-4 py-3 text-left text-sm font-medium text-gray-500">Actions</th>
          </tr>
        </thead>
        <tbody className="divide-y">
          {requests.map((req) => (
            <tr key={req.id} className="hover:bg-gray-50">
              <td className="px-4 py-3">
                <div className="font-medium">{req.userName}</div>
                <div className="text-sm text-gray-500">{req.userPhone}</div>
              </td>
              <td className="px-4 py-3">{typeLabels[req.type]}</td>
              <td className="px-4 py-3">
                <span className={`px-2 py-1 rounded-full text-xs ${statusColors[req.status]}`}>
                  {req.status}
                </span>
              </td>
              <td className="px-4 py-3">{req.assignedVolunteerName || '-'}</td>
              <td className="px-4 py-3 text-sm">{format(new Date(req.createdAt), 'MMM dd, yyyy')}</td>
              <td className="px-4 py-3">
                {(req.status === 'PENDING' || req.status === 'ADMIN_REVIEW') && onAssign && (
                  <button
                    onClick={() => onAssign(req)}
                    className="text-blue-600 hover:text-blue-800 text-sm font-medium"
                  >
                    Assign
                  </button>
                )}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
