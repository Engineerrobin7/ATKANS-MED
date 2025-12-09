
import 'package:flutter/material.dart';
import '../../../core/widgets/tilt_3d_card.dart';

class ExecutiveOnboardingScreen extends StatefulWidget {
  const ExecutiveOnboardingScreen({super.key});

  @override
  State<ExecutiveOnboardingScreen> createState() => _ExecutiveOnboardingScreenState();
}

class _ExecutiveOnboardingScreenState extends State<ExecutiveOnboardingScreen> {
  int _currentStep = 0;
  bool _idUploaded = false;
  bool _addressUploaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New User Onboarding'),
        backgroundColor: Colors.transparent,
        elevation: 0,
       ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: Theme.of(context).primaryColor,
            onSurface: Colors.white,
          ),
          canvasColor: const Color(0xFF1E1E1E),
        ),
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          physics: const ClampingScrollPhysics(),
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    child: const Text('Continue'),
                  ),
                  const SizedBox(width: 12),
                  if (_currentStep != 0)
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Back'),
                    ),
                ],
              ),
            );
          },
          steps: [
             Step(
              title: const Text('User Details', style: TextStyle(color: Colors.white)),
              isActive: _currentStep >= 0,
              content: Column(
                children: [
                   TextField(
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: const Color(0xFF2C2C2C),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                   TextField(
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: const Color(0xFF2C2C2C),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Step(
              title: const Text('Verification Documents', style: TextStyle(color: Colors.white)),
              isActive: _currentStep >= 1,
              content: Column(
                children: [
                  _buildUploadTile('Government ID', _idUploaded, () {
                    setState(() => _idUploaded = true);
                  }),
                  const SizedBox(height: 16),
                   _buildUploadTile('Address Proof', _addressUploaded, () {
                    setState(() => _addressUploaded = true);
                  }),
                ],
              ),
            ),
            Step(
              title: const Text('Review & Submit', style: TextStyle(color: Colors.white)),
              isActive: _currentStep >= 2,
              content: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).primaryColor),
                ),
                child: const Text('Please review the details above before submitting the application for approval.', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
          onStepContinue: () {
            if (_currentStep < 2) {
               setState(() => _currentStep += 1);
            } else {
               Navigator.pop(context);
               ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                 content: const Text('Onboarding Request Submitted'),
                 backgroundColor: Theme.of(context).primaryColor,
                 behavior: SnackBarBehavior.floating,
               ));
            }
          },
          onStepCancel: () {
             if (_currentStep > 0) {
               setState(() => _currentStep -= 1);
             }
          },
        ),
      ),
    );
  }

  Widget _buildUploadTile(String label, bool isUploaded, VoidCallback onUpload) {
    return Tilt3DCard(
      color: const Color(0xFF2C2C2C),
      child: ListTile(
        leading: Icon(
          isUploaded ? Icons.check_circle : Icons.upload_file, 
          color: isUploaded ? Theme.of(context).primaryColor : Colors.grey
        ),
        title: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(
          isUploaded ? 'Uploaded Successfully' : 'Tap to upload', 
          style: TextStyle(color: Colors.grey[400])
        ),
        trailing: isUploaded ? null : ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.black,
          ),
          onPressed: onUpload, 
          child: const Text('Upload')
        ),
      ),
    );
  }
}
