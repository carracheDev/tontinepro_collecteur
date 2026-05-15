abstract class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://tontinepro-backend.onrender.com',
  );
}
