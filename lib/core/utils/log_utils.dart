import 'dart:developer' as developer;

/// Logs a message that will definitely appear in the console
/// This bypasses any filtering that might be happening with print or debugPrint
void forceLog(String message, {String tag = 'FORCE_LOG'}) {
  // Log using developer.log which is more likely to appear
  developer.log('[$tag] $message', name: 'APP_DEBUG');
  
  // Also log using print for belt-and-suspenders approach
  print('');
  print('🚨🚨🚨 [$tag] $message 🚨🚨🚨');
  print('');
} 