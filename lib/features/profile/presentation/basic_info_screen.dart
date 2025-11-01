import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/user_profile_provider.dart';
import '../../auth/providers/auth_provider.dart';

class BasicInfoScreen extends HookConsumerWidget {
  const BasicInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final ageController = useTextEditingController();
    final bioController = useTextEditingController();
    final occupationController = useTextEditingController();
    final locationController = useTextEditingController();
    final selectedGender = useState<String?>(null);
    final isLoading = useState(false);

    // Get current profile to pre-fill existing data
    final userProfileAsync = ref.watch(currentUserProfileProvider);

    // Pre-fill existing data
    useEffect(() {
      userProfileAsync.whenData((profile) {
        if (profile != null) {
          nameController.text = profile.name ?? '';
          ageController.text = profile.age?.toString() ?? '';
          bioController.text = profile.bio ?? '';
          occupationController.text = profile.occupation ?? '';
          locationController.text = profile.location ?? '';
          selectedGender.value = profile.gender;
        }
      });
      return null;
    }, [userProfileAsync]);

    Future<void> saveBasicInfo() async {
      if (nameController.text.trim().isEmpty) {
        _showSnackBar(context, 'Please enter your name', Colors.red);
        return;
      }

      if (ageController.text.trim().isEmpty) {
        _showSnackBar(context, 'Please enter your age', Colors.red);
        return;
      }

      if (selectedGender.value == null) {
        _showSnackBar(context, 'Please select your gender', Colors.red);
        return;
      }

      final age = int.tryParse(ageController.text.trim());
      if (age == null || age < 18 || age > 100) {
        _showSnackBar(context, 'Please enter a valid age (18-100)', Colors.red);
        return;
      }

      isLoading.value = true;

      try {
        final userProfileService = ref.read(userProfileServiceProvider);
        final user = ref.read(authNotifierProvider).value;
        if (user == null) throw Exception('User not authenticated');

        await userProfileService.updateBasicInfo(
          userId: user.uid,
          name: nameController.text.trim(),
          age: age,
          gender: selectedGender.value!,
          bio: bioController.text.trim().isEmpty ? null : bioController.text.trim(),
          occupation: occupationController.text.trim().isEmpty ? null : occupationController.text.trim(),
          location: locationController.text.trim().isEmpty ? null : locationController.text.trim(),
        );

        if (!context.mounted) return;
        _showSnackBar(context, 'Basic info saved successfully!', Colors.green);
        if (!context.mounted) return;
        context.pop(); // Go back to profile setup
      } catch (e) {
        if (!context.mounted) return;
        _showSnackBar(context, 'Failed to save info: $e', Colors.red);
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Basic Info',
          style: GoogleFonts.lobster(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tell us about yourself',
              style: GoogleFonts.lobster(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Complete all required fields to continue',
              style: GoogleFonts.lobster(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 32),

            // Name Field
            _buildTextField(
              controller: nameController,
              label: 'Name *',
              hint: 'Enter your first name',
              icon: Icons.person_outline,
              maxLength: 30,
            ),

            const SizedBox(height: 20),

            // Age Field
            _buildTextField(
              controller: ageController,
              label: 'Age *',
              hint: 'Enter your age',
              icon: Icons.cake_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
            ),

            const SizedBox(height: 20),

            // Gender Field
            _buildGenderSelector(selectedGender),

            const SizedBox(height: 20),

            // Bio Field
            _buildTextField(
              controller: bioController,
              label: 'Bio',
              hint: 'Tell us about yourself...',
              icon: Icons.description_outlined,
              maxLines: 4,
              maxLength: 500,
            ),

            const SizedBox(height: 20),

            // Occupation Field
            _buildTextField(
              controller: occupationController,
              label: 'Occupation',
              hint: 'What do you do?',
              icon: Icons.work_outline,
              maxLength: 50,
            ),

            const SizedBox(height: 20),

            // Location Field
            _buildTextField(
              controller: locationController,
              label: 'Location',
              hint: 'City, State',
              icon: Icons.location_on_outlined,
              maxLength: 50,
            ),

            const SizedBox(height: 40),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading.value ? null : saveBasicInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: isLoading.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Save & Continue',
                      style: GoogleFonts.lobster(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
              ),
            ),

            const SizedBox(height: 16),

            Center(
              child: Text(
                '* All fields are required to complete your profile',
                style: GoogleFonts.lobster(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lobster(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.lobster(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            prefixIcon: Icon(icon, color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            fillColor: Colors.grey[50],
            filled: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            counterStyle: GoogleFonts.lobster(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
          style: GoogleFonts.lobster(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector(ValueNotifier<String?> selectedGender) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender *',
          style: GoogleFonts.lobster(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildGenderOption('Male', selectedGender),
              ),
              Expanded(
                child: _buildGenderOption('Female', selectedGender),
              ),
              Expanded(
                child: _buildGenderOption('Other', selectedGender),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenderOption(String gender, ValueNotifier<String?> selectedGender) {
    final isSelected = selectedGender.value == gender;
    return GestureDetector(
      onTap: () => selectedGender.value = gender,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            gender,
            style: GoogleFonts.lobster(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.lobster(fontSize: 12),
        ),
        backgroundColor: color,
      ),
    );
  }
}