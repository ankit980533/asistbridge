import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/request_provider.dart';
import '../../services/speech_service.dart';
import '../../services/location_service.dart';
import '../../utils/constants.dart';
import '../../widgets/accessible_button.dart';

class RaiseRequestScreen extends StatefulWidget {
  const RaiseRequestScreen({super.key});

  @override
  State<RaiseRequestScreen> createState() => _RaiseRequestScreenState();
}

class _RaiseRequestScreenState extends State<RaiseRequestScreen> {
  final _descriptionController = TextEditingController();
  final _speechService = SpeechService();
  String _selectedType = HelpTypes.onlineHelp;
  bool _isListening = false;
  Position? _position;
  String? _address;

  @override
  void initState() {
    super.initState();
    _getLocation();
    _speechService.initialize();
  }

  Future<void> _getLocation() async {
    _position = await LocationService.getCurrentPosition();
    if (_position != null) {
      _address = await LocationService.getAddressFromCoordinates(
          _position!.latitude, _position!.longitude);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Raise Request')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              label: 'Select type of help needed',
              child: DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type of Help',
                  prefixIcon: Icon(Icons.help_outline, size: 28),
                ),
                items: [
                  HelpTypes.onlineHelp,
                  HelpTypes.writerHelp,
                  HelpTypes.navigationAssistance,
                  HelpTypes.documentReading,
                ].map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(HelpTypes.getLabel(type)),
                )).toList(),
                onChanged: (value) => setState(() => _selectedType = value!),
              ),
            ),
            const SizedBox(height: 16),
            Text(HelpTypes.getDescription(_selectedType),
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 24),
            Semantics(
              label: 'Describe your request. You can also use voice input.',
              child: TextField(
                controller: _descriptionController,
                maxLines: 4,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  labelText: 'Describe your request',
                  hintText: 'Tap microphone to speak...',
                  suffixIcon: IconButton(
                    icon: Icon(_isListening ? Icons.mic : Icons.mic_none,
                        size: 32, color: _isListening ? Colors.red : null),
                    tooltip: _isListening ? 'Stop listening' : 'Start voice input',
                    onPressed: _toggleListening,
                  ),
                ),
              ),
            ),
            if (_isListening)
              Semantics(
                liveRegion: true,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Listening... Speak now',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red)),
                ),
              ),
            const SizedBox(height: 16),
            if (_address != null)
              Semantics(
                label: 'Your location: $_address',
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.location_on),
                    title: const Text('Your Location'),
                    subtitle: Text(_address!),
                  ),
                ),
              ),
            const SizedBox(height: 32),
            Consumer<RequestProvider>(
              builder: (context, provider, _) => AccessibleButton(
                label: 'Submit Request',
                semanticLabel: 'Tap to submit your help request',
                icon: Icons.send,
                isLoading: provider.isLoading,
                onPressed: () => _submitRequest(provider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speechService.stopListening();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      await _speechService.startListening(
        onResult: (text) {
          setState(() => _descriptionController.text = text);
        },
      );
      await Future.delayed(const Duration(seconds: 10));
      if (_isListening) {
        await _speechService.stopListening();
        setState(() => _isListening = false);
      }
    }
  }

  Future<void> _submitRequest(RequestProvider provider) async {
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your request')),
      );
      return;
    }

    final success = await provider.createRequest(
      type: _selectedType,
      description: description,
      latitude: _position?.latitude,
      longitude: _position?.longitude,
      address: _address,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request submitted successfully')),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Failed to submit request')),
      );
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}
