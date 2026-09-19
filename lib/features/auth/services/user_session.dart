  class UserSession {
    static String currentUsername = 'UserA1B2c3';
    static String currentEmail = 'user@gmail.com';

    static void setRegisteredUser({
      required String username,
      String email = '',
    }) {
      currentUsername = username.isNotEmpty ? username : 'UserA1B2c3';
      if (email.isNotEmpty) currentEmail = email;
    }

    static void setLoggedInUser({
      required String username,
    }) {
      currentUsername = username.isNotEmpty ? username : 'UserA1B2c3';
    }

    static void logout() {
      currentUsername = 'UserA1B2c3';
    }
  }
