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
    return Semantics(
      label: '${HelpTypes.getLabel(request.type)} request, status: ${request.status}',
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      HelpTypes.getLabel(request.type),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildStatusChip(context),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  request.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('MMM dd, yyyy - hh:mm a').format(request.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusChip(BuildContext context) {
    Color color;
    switch (request.status) {
      case 'PENDING': case 'ADMIN_REVIEW': color = Colors.orange; break;
      case 'ASSIGNED': color = Colors.blue; break;
      case 'IN_PROGRESS': color = Colors.purple; break;
      case 'COMPLETED': color = Colors.green; break;
      case 'CANCELLED': color = Colors.red; break;
      default: color = Colors.grey;
    }
    
    return Chip(
      label: Text(request.status, style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
      padding: EdgeInsets.zero,
    );
  }
}
