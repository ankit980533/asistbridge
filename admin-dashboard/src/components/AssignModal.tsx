'use client'
import { useState, useEffect } from 'react'
import { X } from 'lucide-react'
import { HelpRequest, User } from '@/types'
import { adminApi } from '@/lib/api'
import toast from 'react-hot-toast'

interface AssignModalProps {
  request: HelpRequest
  onClose: () => void
  onAssigned: () => void
}

export default function AssignModal({ request, onClose, onAssigned }: AssignModalProps) {
  const [volunteers, setVolunteers] = useState<User[]>([])
  const [selectedVolunteer, setSelectedVolunteer] = useState('')
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    adminApi.getActiveVolunteers().then((res) => setVolunteers(res.data.data))
  }, [])

  const handleAssign = async () => {
    if (!selectedVolunteer) return toast.error('Select a volunteer')
    setLoading(true)
    try {
      await adminApi.assignVolunteer(request.id, selectedVolunteer)
      toast.success('Volunteer assigned!')
      onAssigned()
    } catch {
      toast.error('Failed to assign')
    }
    setLoading(false)
  }

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 w-full max-w-md">
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-xl font-bold">Assign Volunteer</h2>
          <button onClick={onClose}><X /></button>
        </div>
        <p className="text-gray-600 mb-4">Request from: {request.userName}</p>
        <select
          value={selectedVolunteer}
          onChange={(e) => setSelectedVolunteer(e.target.value)}
          className="w-full p-3 border rounded mb-4"
        >
          <option value="">Select Volunteer</option>
          {volunteers.map((v) => (
            <option key={v.id} value={v.id}>{v.name} - {v.phone}</option>
          ))}
        </select>
        <button
          onClick={handleAssign}
          disabled={loading}
          className="w-full bg-blue-600 text-white p-3 rounded hover:bg-blue-700 disabled:opacity-50"
        >
          {loading ? 'Assigning...' : 'Assign'}
        </button>
      </div>
    </div>
  )
}
