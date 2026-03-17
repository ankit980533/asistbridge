import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/help_request.dart';
import '../../providers/request_provider.dart';
import '../../services/accessibility_service.dart';
import '../../utils/constants.dart';
import '../../widgets/voice_button.dart';

/// Request status screen with voice feedback for visually impaired users
class AccessibleRequestStatusScreen extends StatefulWidget {
  const AccessibleRequestStatusScreen({super.key});

  @override
  State<AccessibleRequestStatusScreen> createState() => _AccessibleRequestStatusScreenState();
}

class _AccessibleRequestStatusScreenState extends State<AccessibleRequestStatusScreen> {
  final _accessibility = AccessibilityService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final requests = Provider.of<RequestProvider>(context, listen: false);
      requests.fetchUserRequests().then((_) {
        _announceRequests(requests);
      });
    });
  }

  void _announceRequests(RequestProvider requests) {
    final active = requests.activeRequests;
    final completed = requests.completedRequests;
    
    if (active.isEmpty && completed.isEmpty) {
      _accessibility.speak('You have no requests. Go back to create a new help request.');
    } else {
      String message = 'You have ${active.length} active request${active.length != 1 ? 's' : ''} '
          'and ${completed.length} completed request${completed.length != 1 ? 's' : ''}. ';
      
      if (active.isNotEmpty) {
        final latest = active.first;
        message += 'Your latest request is ${_getStatusDescription(latest.status)}.';
      }
      
      _accessibility.speak(message);
    }
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'PENDING':
        return 'pending. Waiting for admin to assign a volunteer.';
      case 'ADMIN_REVIEW':
        return 'under review by admin.';
      case 'ASSIGNED':
        return 'assigned to a volunteer. They will contact you soon.';
      case 'IN_PROGRESS':
        return 'in progress. A volunteer is on the way to help you.';
      case 'COMPLETED':
        return 'completed.';
      case 'CANCELLED':
        return 'cancelled.';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Requests'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 32),
            tooltip: 'Refresh',
            onPressed: () {
              _accessibility.speak('Refreshing requests');
              Provider.of<RequestProvider>(context, listen: false)
                  .fetchUserRequests()
                  .then((_) => _announceRequests(
                      Provider.of<RequestProvider>(context, listen: false)));
            },
          ),
        ],
      ),
      body: Consumer<RequestProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading requests...', style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }

          if (provider.requests.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.inbox, size: 80, color: Colors.grey),
                    const SizedBox(height: 16),
                    Semantics(
                      liveRegion: true,
                      child: const Text(
                        'No requests yet',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Go back to create a help request',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.requests.length,
            itemBuilder: (context, index) {
              final request = provider.requests[index];
              return _buildRequestCard(request, provider);
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(HelpRequest request, RequestProvider provider) {
    final statusColor = _getStatusColor(request.status);
    final statusIcon = _getStatusIcon(request.status);
    
    return Semantics(
      label: '${HelpTypes.getLabel(request.type)} request. '
          'Status: ${_getStatusDescription(request.status)} '
          'Created on ${DateFormat('MMMM d').format(request.createdAt)}.',
      child: GestureDetector(
        onLongPress: () {
          _accessibility.speak(
            '${HelpTypes.getLabel(request.type)} request. '
            '${request.description}. '
            'Status: ${_getStatusDescription(request.status)}. '
            '${request.assignedVolunteerName != null ? "Volunteer: ${request.assignedVolunteerName}." : ""}'
          );
        },
        child: Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: statusColor, width: 3),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status header
                Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        request.status.replaceAll('_', ' '),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                
                // Type
                Text(
                  HelpTypes.getLabel(request.type),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                
                // Description
                Text(
                  request.description,
                  style: const TextStyle(fontSize: 18),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                
                // Volunteer info
                if (request.assignedVolunteerName != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Volunteer: ${request.assignedVolunteerName}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Date
                Text(
                  'Created: ${DateFormat('MMM dd, yyyy - hh:mm a').format(request.createdAt)}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                
                // Cancel button for pending requests
                if (request.isPending) ...[
                  const SizedBox(height: 16),
                  VoiceButton(
                    label: 'CANCEL REQUEST',
                    voiceLabel: 'Cancel this request',
                    voiceHint: 'Double tap to cancel this help request',
                    icon: Icons.cancel,
                    height: 60,
                    backgroundColor: Colors.red,
                    onPressed: () => _cancelRequest(request, provider),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
      case 'ADMIN_REVIEW':
        return Colors.orange;
      case 'ASSIGNED':
        return Colors.blue;
      case 'IN_PROGRESS':
        return Colors.purple;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'PENDING':
      case 'ADMIN_REVIEW':
        return Icons.hourglass_empty;
      case 'ASSIGNED':
        return Icons.person_add;
      case 'IN_PROGRESS':
        return Icons.directions_walk;
      case 'COMPLETED':
        return Icons.check_circle;
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Future<void> _cancelRequest(HelpRequest request, RequestProvider provider) async {
    _accessibility.speak('Cancelling request');
    final success = await provider.cancelRequest(request.id);
    if (success) {
      _accessibility.speak('Request cancelled successfully');
    } else {
      _accessibility.speak('Failed to cancel request');
    }
  }
}
