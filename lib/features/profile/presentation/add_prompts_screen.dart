import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/models/user_profile.dart';
import '../providers/user_profile_provider.dart';

// Sample prompts for the dating app
const List<String> availablePrompts = [
  "My ideal Sunday involves...",
  "I'm overly competitive about...",
  "A perfect first date would be...",
  "I'm secretly really good at...",
  "My most controversial opinion is...",
  "I spend too much money on...",
  "The way to win me over is...",
  "I'm looking for someone who...",
  "My biggest turn-off is...",
  "I never leave home without...",
  "The last show I binged was...",
  "My childhood crush was...",
  "I won't shut up about...",
  "My dream vacation is...",
  "The key to my heart is...",
  "I'm the type of person who...",
  "My guilty pleasure is...",
  "I'm proudest of...",
  "My worst habit is...",
  "I believe everyone should...",
];

class PromptAnswer {
  final String prompt;
  final String answer;
  
  PromptAnswer({required this.prompt, required this.answer});
}

class AddPromptsScreen extends HookConsumerWidget {
  const AddPromptsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final existingPrompts = ref.watch(userPromptsProvider);
    final userProfileNotifier = ref.watch(userProfileNotifierProvider.notifier);
    
    final selectedPrompts = useState<List<PromptAnswer>>([]);
    final isEditingPrompt = useState<int?>(null);
    final answerController = useTextEditingController();

    // Initialize with existing prompts
    useEffect(() {
      if (existingPrompts.isNotEmpty && selectedPrompts.value.isEmpty) {
        selectedPrompts.value = existingPrompts.map((prompt) => 
          PromptAnswer(prompt: prompt.question, answer: prompt.answer)
        ).toList();
      }
      return null;
    }, [existingPrompts]);

    int answeredCount = selectedPrompts.value.length;
    bool canContinue = answeredCount >= 3;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Add Prompts',
          style: GoogleFonts.lobster(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (canContinue)
            TextButton(
              onPressed: () async {
                // Convert PromptAnswer to ProfilePrompt and save to Firestore
                final prompts = selectedPrompts.value.map((promptAnswer) => 
                  ProfilePrompt(
                    question: promptAnswer.prompt,
                    answer: promptAnswer.answer,
                    type: PromptType.text,
                  )
                ).toList();
                
                final success = await userProfileNotifier.updatePrompts(prompts);
                
                if (success) {
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Prompts saved! ($answeredCount/6)',
                        style: GoogleFonts.lobster(fontSize: 12),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Failed to save prompts. Please try again.',
                        style: GoogleFonts.lobster(fontSize: 12),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text(
                'Done',
                style: GoogleFonts.lobster(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share Your Personality',
                style: GoogleFonts.lobster(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ).animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.3, end: 0),
              
              const SizedBox(height: 8),
              
              Text(
                'Answer at least 3 prompts to show your personality. These help start meaningful conversations.',
                style: GoogleFonts.lobster(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ).animate()
                .fadeIn(delay: 200.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0),
              
              const SizedBox(height: 16),
              
              // Prompt count indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: canContinue ? Colors.green.withValues(alpha: 0.1) : theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: canContinue ? Colors.green : theme.colorScheme.primary,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      canContinue ? Icons.check_circle : Icons.quiz,
                      color: canContinue ? Colors.green : theme.colorScheme.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$answeredCount/6 prompts ${canContinue ? '(Ready!)' : '(${3 - answeredCount} more needed)'}',
                      style: GoogleFonts.lobster(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: canContinue ? Colors.green : theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ).animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0),
              
              const SizedBox(height: 24),
              
              // Answered prompts list
              if (selectedPrompts.value.isNotEmpty) ...[
                Text(
                  'Your Prompts',
                  style: GoogleFonts.lobster(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                
                ...selectedPrompts.value.asMap().entries.map((entry) {
                  final index = entry.key;
                  final promptAnswer = entry.value;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                promptAnswer.prompt,
                                style: GoogleFonts.lobster(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                // Edit prompt
                                answerController.text = promptAnswer.answer;
                                isEditingPrompt.value = index;
                                _showEditPromptDialog(
                                  context, 
                                  promptAnswer.prompt, 
                                  answerController, 
                                  selectedPrompts, 
                                  index,
                                  isEditingPrompt,
                                );
                              },
                              icon: const Icon(Icons.edit, size: 20),
                            ),
                            IconButton(
                              onPressed: () {
                                // Remove prompt
                                final newPrompts = List<PromptAnswer>.from(selectedPrompts.value);
                                newPrompts.removeAt(index);
                                selectedPrompts.value = newPrompts;
                              },
                              icon: const Icon(Icons.delete, size: 20),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          promptAnswer.answer,
                          style: GoogleFonts.lobster(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: (index * 100).ms)
                    .fadeIn(duration: 600.ms)
                    .slideX(begin: -0.3, end: 0);
                }),
                
                const SizedBox(height: 24),
              ],
              
              // Add prompt button
              if (selectedPrompts.value.length < 6)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      _showPromptSelectionDialog(context, selectedPrompts, answerController, isEditingPrompt);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: theme.colorScheme.primary),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Add New Prompt',
                          style: GoogleFonts.lobster(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate()
                  .fadeIn(delay: 600.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),
              
              const Spacer(),
              
              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canContinue ? () async {
                    // Convert and save prompts to complete profile setup
                    final prompts = selectedPrompts.value.map((promptAnswer) => 
                      ProfilePrompt(
                        question: promptAnswer.prompt,
                        answer: promptAnswer.answer,
                        type: PromptType.text,
                      )
                    ).toList();
                    
                    final success = await userProfileNotifier.updatePrompts(prompts);
                    
                    if (success) {
                      context.pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Profile setup complete! Welcome to No Ghost!',
                            style: GoogleFonts.lobster(fontSize: 12),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to complete profile setup.',
                            style: GoogleFonts.lobster(fontSize: 12),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: canContinue ? theme.colorScheme.primary : theme.colorScheme.outline,
                  ),
                  child: Text(
                    canContinue ? 'Complete Profile' : 'Answer ${3 - answeredCount} More Prompts',
                    style: GoogleFonts.lobster(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: canContinue ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ).animate()
                .fadeIn(delay: 800.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  void _showPromptSelectionDialog(
    BuildContext context,
    ValueNotifier<List<PromptAnswer>> selectedPrompts,
    TextEditingController answerController,
    ValueNotifier<int?> isEditingPrompt,
  ) {
    final usedPrompts = selectedPrompts.value.map((p) => p.prompt).toSet();
    final availablePromptsFiltered = availablePrompts.where((p) => !usedPrompts.contains(p)).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Choose a Prompt',
          style: GoogleFonts.lobster(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: availablePromptsFiltered.length,
            itemBuilder: (context, index) {
              final prompt = availablePromptsFiltered[index];
              return ListTile(
                title: Text(
                  prompt,
                  style: GoogleFonts.lobster(fontSize: 14),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  answerController.clear();
                  isEditingPrompt.value = null;
                  _showAnswerPromptDialog(context, prompt, answerController, selectedPrompts, isEditingPrompt);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showAnswerPromptDialog(
    BuildContext context,
    String prompt,
    TextEditingController answerController,
    ValueNotifier<List<PromptAnswer>> selectedPrompts,
    ValueNotifier<int?> isEditingPrompt,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Answer Prompt',
          style: GoogleFonts.lobster(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              prompt,
              style: GoogleFonts.lobster(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: answerController,
              decoration: InputDecoration(
                hintText: 'Share your thoughts...',
                hintStyle: GoogleFonts.lobster(fontSize: 12),
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 150,
              style: GoogleFonts.lobster(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.lobster(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (answerController.text.trim().isNotEmpty) {
                final newPrompts = List<PromptAnswer>.from(selectedPrompts.value);
                newPrompts.add(PromptAnswer(
                  prompt: prompt,
                  answer: answerController.text.trim(),
                ));
                selectedPrompts.value = newPrompts;
                Navigator.of(context).pop();
              }
            },
            child: Text(
              'Save',
              style: GoogleFonts.lobster(),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditPromptDialog(
    BuildContext context,
    String prompt,
    TextEditingController answerController,
    ValueNotifier<List<PromptAnswer>> selectedPrompts,
    int index,
    ValueNotifier<int?> isEditingPrompt,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Answer',
          style: GoogleFonts.lobster(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              prompt,
              style: GoogleFonts.lobster(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: answerController,
              decoration: InputDecoration(
                hintText: 'Share your thoughts...',
                hintStyle: GoogleFonts.lobster(fontSize: 12),
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 150,
              style: GoogleFonts.lobster(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.lobster(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (answerController.text.trim().isNotEmpty) {
                final newPrompts = List<PromptAnswer>.from(selectedPrompts.value);
                newPrompts[index] = PromptAnswer(
                  prompt: prompt,
                  answer: answerController.text.trim(),
                );
                selectedPrompts.value = newPrompts;
                Navigator.of(context).pop();
              }
            },
            child: Text(
              'Save',
              style: GoogleFonts.lobster(),
            ),
          ),
        ],
      ),
    );
  }
}