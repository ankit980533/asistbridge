import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/help_request.dart';
import '../../providers/request_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/accessible_button.dart';

class RequestDetailScreen extends StatelessWidget {
  final HelpRequest request;
  
  const RequestDetailScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(context, 'Type', HelpTypes.getLabel(request.type), Icons.category),
            _buildInfoCard(context, 'Status', request.status, Icons.info),
            _buildInfoCard(context, 'Description', request.description, Icons.description),
            _buildInfoCard(context, 'Created', 
                DateFormat('MMM dd, yyyy - hh:mm a').format(request.createdAt), Icons.access_time),
            if (request.address != null)
              _buildInfoCard(context, 'Location', request.address!, Icons.location_on),
            if (request.assignedVolunteerName != null)
              _buildInfoCard(context, 'Volunteer', request.assignedVolunteerName!, Icons.person),
            const SizedBox(height: 24),
            if (request.isPending)
              AccessibleButton(
                label: 'Cancel Request',
                semanticLabel: 'Tap to cancel this request',
                icon: Icons.cancel,
                backgroundColor: Colors.red,
                onPressed: () => _cancelRequest(context),
              ),
            if (request.isCompleted && request.rating == null)
              _buildRatingSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String label, String value, IconData icon) {
    return Semantics(
      label: '$label: $value',
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: Icon(icon, size: 28),
          title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(value, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildRatingSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rate this service', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => IconButton(
                icon: Icon(Icons.star, size: 40, color: Colors.amber),
                tooltip: '${index + 1} stars',
                onPressed: () => _submitRating(context, index + 1),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cancelRequest(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Request?'),
        content: const Text('Are you sure you want to cancel this request?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final provider = Provider.of<RequestProvider>(context, listen: false);
      final success = await provider.cancelRequest(request.id);
      if (success && context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _submitRating(BuildContext context, int rating) async {
    final provider = Provider.of<RequestProvider>(context, listen: false);
    final success = await provider.rateRequest(request.id, rating);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for your feedback!')),
      );
      Navigator.pop(context);
    }
  }
}
