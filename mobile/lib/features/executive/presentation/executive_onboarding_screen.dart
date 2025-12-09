
import 'package:flutter/material.dart';

class ExecutiveOnboardingScreen extends StatefulWidget {
  const ExecutiveOnboardingScreen({super.key});

  @override
  State<ExecutiveOnboardingScreen> createState() => _ExecutiveOnboardingScreenState();
}

class _ExecutiveOnboardingScreenState extends State<ExecutiveOnboardingScreen> {
  bool _idUploaded = false;
  bool _addressUploaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New User Onboarding')),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: 0,
        steps: [
           Step(
            title: const Text('User Details'),
            content: Column(
              children: [
                TextFormField(decoration: const InputDecoration(labelText: 'Full Name')),
                const SizedBox(height: 10),
                TextFormField(decoration: const InputDecoration(labelText: 'Phone Number')),
              ],
            ),
          ),
          Step(
            title: const Text('Verification Documents'),
            content: Column(
              children: [
                _buildUploadTile('Government ID', _idUploaded, () {
                  setState(() => _idUploaded = true);
                }),
                 _buildUploadTile('Address Proof', _addressUploaded, () {
                  setState(() => _addressUploaded = true);
                }),
              ],
            ),
          ),
          const Step(
            title: const Text('Review & Submit'),
            content: Text('Review the details above before submitting.'),
          ),
        ],
        onStepContinue: () {
          // Handle step logic
        },
        onStepCancel: () {
           // Handle cancel
        },
      ),
    );
  }

  Widget _buildUploadTile(String label, bool isUploaded, VoidCallback onUpload) {
    return ListTile(
      leading: Icon(isUploaded ? Icons.check_circle : Icons.upload_file, color: isUploaded ? Colors.green : Colors.grey),
      title: Text(label),
      subtitle: Text(isUploaded ? 'Uploaded Successfully' : 'Tap to upload'),
      trailing: isUploaded ? null : ElevatedButton(onPressed: onUpload, child: const Text('Upload')),
    );
  }
}
