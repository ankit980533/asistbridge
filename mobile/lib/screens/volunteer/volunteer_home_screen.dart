import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../widgets/request_card.dart';
import 'volunteer_request_detail_screen.dart';
import '../auth/login_screen.dart';

class VolunteerHomeScreen extends StatefulWidget {
  const VolunteerHomeScreen({super.key});

  @override
  State<VolunteerHomeScreen> createState() => _VolunteerHomeScreenState();
}

class _VolunteerHomeScreenState extends State<VolunteerHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RequestProvider>(context, listen: false).fetchVolunteerRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          header: true,
          child: Text('Hello, ${auth.user?.name ?? 'Volunteer'}'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(auth),
          ),
        ],
      ),
      body: Consumer<RequestProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (provider.requests.isEmpty) {
            return Center(
              child: Semantics(
                liveRegion: true,
                child: const Text('No assigned requests.\nWait for admin to assign requests.',
                    textAlign: TextAlign.center),
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: provider.fetchVolunteerRequests,
            child: ListView.builder(
              itemCount: provider.requests.length,
              itemBuilder: (context, index) {
                final request = provider.requests[index];
                return RequestCard(
                  request: request,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => 
                          VolunteerRequestDetailScreen(request: request))),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _logout(AuthProvider auth) async {
    await auth.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}
