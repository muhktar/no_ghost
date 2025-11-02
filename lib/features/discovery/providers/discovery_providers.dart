import 'package:flutter_riverpod/flutter_riverpod.dart';

// Ghost Mode State Provider
// Controls whether ghost mode is currently active in the discovery screen
// When active:
// - Profile photos are blurred
// - Names and occupations are hidden
// - Ghost prompts are shown instead of regular prompts
// - Profiles are reshuffled
final isGhostModeActiveProvider = StateProvider<bool>((ref) => false);
