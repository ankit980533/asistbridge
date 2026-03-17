'use client'
import { useEffect, useState } from 'react'
import { adminApi } from '@/lib/api'
import { HelpRequest } from '@/types'
import RequestTable from '@/components/RequestTable'
import AssignModal from '@/components/AssignModal'

export default function RequestsPage() {
  const [requests, setRequests] = useState<HelpRequest[]>([])
  const [selectedRequest, setSelectedRequest] = useState<HelpRequest | null>(null)
  const [filter, setFilter] = useState('all')

  const fetchRequests = () => {
    adminApi.getRequests().then((res) => setRequests(res.data.data))
  }

  useEffect(() => { fetchRequests() }, [])

  const filteredRequests = filter === 'all' 
    ? requests 
    : requests.filter((r) => r.status === filter)

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Help Requests</h1>
        <select
          value={filter}
          onChange={(e) => setFilter(e.target.value)}
          className="p-2 border rounded"
        >
          <option value="all">All</option>
          <option value="PENDING">Pending</option>
          <option value="ASSIGNED">Assigned</option>
          <option value="IN_PROGRESS">In Progress</option>
          <option value="COMPLETED">Completed</option>
          <option value="CANCELLED">Cancelled</option>
        </select>
      </div>
      <RequestTable requests={filteredRequests} onAssign={setSelectedRequest} />
      {selectedRequest && (
        <AssignModal
          request={selectedRequest}
          onClose={() => setSelectedRequest(null)}
          onAssigned={() => { setSelectedRequest(null); fetchRequests() }}
        />
      )}
    </div>
  )
}
