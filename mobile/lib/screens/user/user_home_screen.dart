import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../widgets/accessible_button.dart';
import '../../widgets/request_card.dart';
import 'raise_request_screen.dart';
import 'request_detail_screen.dart';
import '../auth/login_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RequestProvider>(context, listen: false).fetchUserRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          header: true,
          child: Text('Hello, ${auth.user?.name ?? 'User'}'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(auth),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: AccessibleButton(
              label: 'Raise Help Request',
              semanticLabel: 'Tap to raise a new help request',
              icon: Icons.add_circle,
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const RaiseRequestScreen())),
            ),
          ),
          Expanded(
            child: Consumer<RequestProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (provider.requests.isEmpty) {
                  return Center(
                    child: Semantics(
                      liveRegion: true,
                      child: const Text('No requests yet.\nTap above to raise a request.',
                          textAlign: TextAlign.center),
                    ),
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: provider.fetchUserRequests,
                  child: ListView.builder(
                    itemCount: provider.requests.length,
                    itemBuilder: (context, index) {
                      final request = provider.requests[index];
                      return RequestCard(
                        request: request,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => 
                                RequestDetailScreen(request: request))),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
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
