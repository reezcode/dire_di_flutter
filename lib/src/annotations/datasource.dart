import 'component.dart';

/// DataSource layer annotation - indicates data source components
///
/// This annotation is a specialization of [@Component] for classes that
/// provide direct data access functionality, such as API clients,
/// database connections, or external service integrations.
///
/// DataSources are typically the lowest level in the data layer,
/// handling the actual data retrieval and storage mechanisms.
///
/// Example:
/// ```dart
/// @DataSource()
/// class UserApiDataSource {
///   Future<Map<String, dynamic>> fetchUser(String id) async {
///     // API call logic here
///     return await httpClient.get('/users/$id');
///   }
/// }
///
/// @DataSource()
/// class UserLocalDataSource {
///   Future<Map<String, dynamic>?> getUserFromCache(String id) async {
///     // Local storage logic here
///     return await localStorage.get('user_$id');
///   }
/// }
/// ```
class DataSource extends Component {
  /// Creates a DataSource annotation
  ///
  /// [value] - Optional name for the data source component
  const DataSource([super.value]);
}
