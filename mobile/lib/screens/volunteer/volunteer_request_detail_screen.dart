import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/help_request.dart';
import '../../providers/request_provider.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import 'map_screen.dart';

class VolunteerRequestDetailScreen extends StatelessWidget {
  final HelpRequest request;

  const VolunteerRequestDetailScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusBanner(),
                  const SizedBox(height: 20),
                  _buildInfoSection(context),
                  const SizedBox(height: 20),
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text('Request Details',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00897B), Color(0xFF26A69A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFF00897B),
    );
  }

  Widget _buildStatusBanner() {
    final color = _statusColor(request.status);
    final icon = _statusIcon(request.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              Text(
                request.status.replaceAll('_', ' '),
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoTile(Icons.person_rounded, 'User', request.userName,
              Colors.blue),
          _divider(),
          _buildInfoTile(
              Icons.phone_rounded, 'Phone', request.userPhone, Colors.green),
          _divider(),
          _buildInfoTile(Icons.category_rounded, 'Type',
              HelpTypes.getLabel(request.type), Colors.purple),
          _divider(),
          _buildInfoTile(Icons.description_rounded, 'Description',
              request.description, Colors.orange),
          _divider(),
          _buildInfoTile(
            Icons.access_time_rounded,
            'Created',
            DateFormat('MMM dd, yyyy - hh:mm a').format(request.createdAt),
            Colors.teal,
          ),
          if (request.address != null) ...[
            _divider(),
            _buildInfoTile(Icons.location_on_rounded, 'Location',
                request.address!, Colors.red),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoTile(
      IconData icon, String label, String value, Color color) {
    return Semantics(
      label: '$label: $value',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade500)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() =>
      Divider(height: 1, indent: 60, color: Colors.grey.shade100);

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (request.latitude != null && request.longitude != null)
          _buildActionButton(
            icon: Icons.map_rounded,
            label: 'View on Map',
            color: const Color(0xFF00897B),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MapScreen(
                    latitude: request.latitude!,
                    longitude: request.longitude!),
              ),
            ),
          ),
        if (request.isAssigned) ...[
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.play_arrow_rounded,
            label: 'Accept & Start',
            color: AppTheme.primaryColor,
            onTap: () => _acceptRequest(context),
          ),
        ],
        if (request.isInProgress) ...[
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.check_circle_rounded,
            label: 'Mark as Completed',
            color: AppTheme.successColor,
            onTap: () => _completeRequest(context),
          ),
        ],
        if (request.userPhone.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.call_rounded,
            label: 'Call User',
            color: Colors.blue,
            onTap: _callUser,
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      color: color,
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 10),
              Text(label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
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

  IconData _statusIcon(String status) {
    switch (status) {
      case 'PENDING':
      case 'ADMIN_REVIEW':
        return Icons.hourglass_empty_rounded;
      case 'ASSIGNED':
        return Icons.person_add_rounded;
      case 'IN_PROGRESS':
        return Icons.directions_walk_rounded;
      case 'COMPLETED':
        return Icons.check_circle_rounded;
      case 'CANCELLED':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline;
    }
  }

  Future<void> _acceptRequest(BuildContext context) async {
    final provider = Provider.of<RequestProvider>(context, listen: false);
    final success = await provider.acceptRequest(request.id);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Request accepted! User has been notified.'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _completeRequest(BuildContext context) async {
    final provider = Provider.of<RequestProvider>(context, listen: false);
    final success = await provider.completeRequest(request.id);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Request completed! Thank you for helping.'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
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
