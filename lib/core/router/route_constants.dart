class RouteConstants {
  // Main routes
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String passwordReset = '/password-reset';
  static const String passwordResetForm = '/password-reset/:token';
  static const String profile = '/profile';
  static const String profileWithId = '/profile/:id';
  static const String myProfile = '/my-profile';
  static const String editProfile = '/profile/:id/edit';
  static const String athletes = '/athletes';
  static const String forums = '/forums';

  // Secondary routes
  static const String settings = '/settings';
  static const String mentors = '/mentors';
  static const String messages = '/messages';
  
  // Static content routes
  static const String about = '/about';
  static const String terms = '/terms';
  static const String privacy = '/privacy';
  static const String help = '/help';
}