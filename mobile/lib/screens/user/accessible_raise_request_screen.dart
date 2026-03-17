import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/request_provider.dart';
import '../../services/accessibility_service.dart';
import '../../services/location_service.dart';
import '../../utils/constants.dart';
import '../../widgets/voice_button.dart';
import '../../widgets/voice_text_field.dart';

/// Simplified request creation screen for visually impaired users
/// Step-by-step flow with voice guidance
class AccessibleRaiseRequestScreen extends StatefulWidget {
  const AccessibleRaiseRequestScreen({super.key});

  @override
  State<AccessibleRaiseRequestScreen> createState() => _AccessibleRaiseRequestScreenState();
}

class _AccessibleRaiseRequestScreenState extends State<AccessibleRaiseRequestScreen> {
  final _descriptionController = TextEditingController();
  final _accessibility = AccessibilityService();
  
  int _currentStep = 0;
  String? _selectedType;
  Position? _position;
  String? _address;
  bool _isSubmitting = false;

  final List<Map<String, String>> _helpTypes = [
    {
      'type': HelpTypes.onlineHelp,
      'label': '📱 ONLINE HELP',
      'description': 'Help reading messages, emails, or websites',
    },
    {
      'type': HelpTypes.writerHelp,
      'label': '✍️ WRITER HELP',
      'description': 'Help writing exams or filling forms',
    },
    {
      'type': HelpTypes.navigationAssistance,
      'label': '🚶 NAVIGATION',
      'description': 'Help reaching a location',
    },
    {
      'type': HelpTypes.documentReading,
      'label': '📄 DOCUMENT READING',
      'description': 'Help reading printed documents',
    },
  ];

  @override
  void initState() {
    super.initState();
    _getLocation();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _accessibility.announceScreen(
        'Create Help Request',
        'Step 1 of 3. Select the type of help you need. '
        'There are 4 options. Swipe to navigate.',
      );
    });
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
      appBar: AppBar(
        title: Text('Step ${_currentStep + 1} of 3'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 32),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
              _announceStep();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _buildCurrentStep(),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1SelectType();
      case 1:
        return _buildStep2Describe();
      case 2:
        return _buildStep3Confirm();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep1SelectType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: const Text(
            'What help do you need?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.separated(
            itemCount: _helpTypes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final type = _helpTypes[index];
              final isSelected = _selectedType == type['type'];
              
              return VoiceButton(
                label: type['label']!,
                voiceLabel: type['label']!,
                voiceHint: type['description'],
                height: 90,
                backgroundColor: isSelected ? Colors.green : Colors.blue.shade700,
                onPressed: () {
                  setState(() => _selectedType = type['type']);
                  _accessibility.speak('Selected ${type['label']}. Double tap Next to continue.');
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        if (_selectedType != null)
          VoiceButton(
            label: 'NEXT →',
            voiceLabel: 'Next button',
            voiceHint: 'Go to step 2 to describe your request',
            icon: Icons.arrow_forward,
            height: 70,
            backgroundColor: Colors.green,
            onPressed: () {
              setState(() => _currentStep = 1);
              _announceStep();
            },
          ),
      ],
    );
  }

  Widget _buildStep2Describe() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: const Text(
            'Describe what you need',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Use the microphone button to speak your request',
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Expanded(
          child: VoiceTextField(
            controller: _descriptionController,
            label: 'Your Request',
            voiceLabel: 'Describe your request',
            hint: 'Example: I need help reading my electricity bill',
            maxLines: 5,
          ),
        ),
        const SizedBox(height: 16),
        VoiceButton(
          label: 'NEXT →',
          voiceLabel: 'Next button',
          voiceHint: 'Go to step 3 to confirm and submit',
          icon: Icons.arrow_forward,
          height: 70,
          backgroundColor: Colors.green,
          onPressed: () {
            if (_descriptionController.text.trim().isEmpty) {
              _accessibility.speak('Please describe what you need help with');
              return;
            }
            setState(() => _currentStep = 2);
            _announceStep();
          },
        ),
      ],
    );
  }

  Widget _buildStep3Confirm() {
    final typeLabel = _helpTypes.firstWhere(
      (t) => t['type'] == _selectedType,
      orElse: () => {'label': 'Unknown'},
    )['label'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: const Text(
            'Confirm Your Request',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        
        // Summary card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryRow('Type:', typeLabel!),
              const SizedBox(height: 12),
              _buildSummaryRow('Request:', _descriptionController.text),
              if (_address != null) ...[
                const SizedBox(height: 12),
                _buildSummaryRow('Location:', _address!),
              ],
            ],
          ),
        ),
        
        const Spacer(),
        
        // Location status
        Semantics(
          liveRegion: true,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _position != null ? Colors.green.shade100 : Colors.orange.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _position != null ? Icons.location_on : Icons.location_off,
                  color: _position != null ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  _position != null ? 'Location captured ✓' : 'Getting location...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _position != null ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        VoiceButton(
          label: '✅ SUBMIT REQUEST',
          voiceLabel: 'Submit request button',
          voiceHint: 'Double tap to send your help request. A volunteer will be assigned soon.',
          icon: Icons.send,
          height: 90,
          backgroundColor: Colors.green.shade700,
          isLoading: _isSubmitting,
          onPressed: _submitRequest,
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Semantics(
      label: '$label $value',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _announceStep() {
    switch (_currentStep) {
      case 0:
        _accessibility.speak('Step 1. Select the type of help you need.');
        break;
      case 1:
        _accessibility.speak('Step 2. Describe what you need. Tap the microphone button to speak.');
        break;
      case 2:
        _accessibility.speak('Step 3. Review and confirm your request. Tap Submit to send.');
        break;
    }
  }

  Future<void> _submitRequest() async {
    setState(() => _isSubmitting = true);
    _accessibility.speak('Submitting your request. Please wait.');
    
    final provider = Provider.of<RequestProvider>(context, listen: false);
    final success = await provider.createRequest(
      type: _selectedType!,
      description: _descriptionController.text.trim(),
      latitude: _position?.latitude,
      longitude: _position?.longitude,
      address: _address,
    );

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      _accessibility.speak('Success! Your request has been submitted. A volunteer will be assigned soon.');
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context);
    } else if (mounted) {
      _accessibility.speak('Error. Failed to submit request. Please try again.');
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}
