import 'package:flutter_riverpod/flutter_riverpod.dart';

// Ghost Mode State Provider
// Controls whether ghost mode is currently active in the discovery screen
// When active:
// - Profile photos are blurred
// - Names and occupations are hidden
// - Ghost prompts are shown instead of regular prompts
// - Profiles are reshuffled
final isGhostModeActiveProvider = StateProvider<bool>((ref) => false);

// Shuffled Profile Index Mapping Provider
// When ghost mode is active, this maps current profile indices to shuffled indices
// Key: original index, Value: shuffled index
// This ensures a different profile is shown in ghost mode
final ghostModeShuffledIndicesProvider = StateProvider<Map<int, int>>((ref) => {});
