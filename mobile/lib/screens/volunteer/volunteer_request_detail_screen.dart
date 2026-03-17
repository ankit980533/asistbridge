import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/help_request.dart';
import '../../providers/request_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/accessible_button.dart';
import 'map_screen.dart';

class VolunteerRequestDetailScreen extends StatelessWidget {
  final HelpRequest request;
  
  const VolunteerRequestDetailScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(context, 'User', request.userName, Icons.person),
            _buildInfoCard(context, 'Phone', request.userPhone, Icons.phone),
            _buildInfoCard(context, 'Type', HelpTypes.getLabel(request.type), Icons.category),
            _buildInfoCard(context, 'Status', request.status, Icons.info),
            _buildInfoCard(context, 'Description', request.description, Icons.description),
            _buildInfoCard(context, 'Created', 
                DateFormat('MMM dd, yyyy - hh:mm a').format(request.createdAt), Icons.access_time),
            if (request.address != null)
              _buildInfoCard(context, 'Location', request.address!, Icons.location_on),
            const SizedBox(height: 24),
            if (request.latitude != null && request.longitude != null)
              AccessibleButton(
                label: 'View on Map',
                semanticLabel: 'Tap to view user location on map',
                icon: Icons.map,
                backgroundColor: Colors.green,
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => MapScreen(
                        latitude: request.latitude!, longitude: request.longitude!))),
              ),
            const SizedBox(height: 12),
            if (request.isAssigned)
              AccessibleButton(
                label: 'Accept & Start',
                semanticLabel: 'Tap to accept this request and start helping',
                icon: Icons.play_arrow,
                onPressed: () => _acceptRequest(context),
              ),
            if (request.isInProgress)
              AccessibleButton(
                label: 'Mark as Completed',
                semanticLabel: 'Tap to mark this request as completed',
                icon: Icons.check_circle,
                backgroundColor: Colors.green,
                onPressed: () => _completeRequest(context),
              ),
            const SizedBox(height: 12),
            if (request.userPhone.isNotEmpty)
              AccessibleButton(
                label: 'Call User',
                semanticLabel: 'Tap to call the user',
                icon: Icons.call,
                backgroundColor: Colors.blue,
                onPressed: () => _callUser(),
              ),
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

  Future<void> _acceptRequest(BuildContext context) async {
    final provider = Provider.of<RequestProvider>(context, listen: false);
    final success = await provider.acceptRequest(request.id);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request accepted! User has been notified.')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _completeRequest(BuildContext context) async {
    final provider = Provider.of<RequestProvider>(context, listen: false);
    final success = await provider.completeRequest(request.id);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request completed! Thank you for helping.')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _callUser() async {
    final uri = Uri.parse('tel:${request.userPhone}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
