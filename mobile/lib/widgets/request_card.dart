import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/help_request.dart';
import '../utils/constants.dart';

class RequestCard extends StatelessWidget {
  final HelpRequest request;
  final VoidCallback? onTap;

  const RequestCard({super.key, required this.request, this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(request.status);

    return Semantics(
      label:
          '${HelpTypes.getLabel(request.type)} request, status: ${request.status}',
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: statusInfo.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(statusInfo.icon,
                            color: statusInfo.color, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              HelpTypes.getLabel(request.type),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('MMM dd, hh:mm a')
                                  .format(request.createdAt),
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusBadge(statusInfo),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    request.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey.shade700, height: 1.4),
                  ),
                  if (request.assignedVolunteerName != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person,
                              size: 16, color: Colors.blue.shade700),
                          const SizedBox(width: 6),
                          Text(
                            request.assignedVolunteerName!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(_StatusInfo info) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: info.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        info.label,
        style: TextStyle(
          color: info.color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  _StatusInfo _getStatusInfo(String status) {
    switch (status) {
      case 'PENDING':
      case 'ADMIN_REVIEW':
        return _StatusInfo(
            Colors.orange, Icons.hourglass_empty_rounded, 'Pending');
      case 'ASSIGNED':
        return _StatusInfo(Colors.blue, Icons.person_add_rounded, 'Assigned');
      case 'IN_PROGRESS':
        return _StatusInfo(
            Colors.purple, Icons.directions_walk_rounded, 'In Progress');
      case 'COMPLETED':
        return _StatusInfo(
            Colors.green, Icons.check_circle_rounded, 'Completed');
      case 'CANCELLED':
        return _StatusInfo(Colors.red, Icons.cancel_rounded, 'Cancelled');
      default:
        return _StatusInfo(Colors.grey, Icons.help_outline, status);
    }
  }
}

class _StatusInfo {
  final Color color;
  final IconData icon;
  final String label;
  _StatusInfo(this.color, this.icon, this.label);
}
