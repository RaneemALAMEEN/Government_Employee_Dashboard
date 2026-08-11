/// Abstract generic interface for local data sources across all features.
///
/// Ensures consistent CRUD operations, batch inserts/updates, and cache clearance.
abstract class BaseLocalDataSource<T> {
  /// Reads a single entity by unique key/id.
  Future<T?> getById(String id);

  /// Reads all entities stored in the collection.
  Future<List<T>> getAll();

  /// Saves a single entity (inserts or updates).
  Future<void> save(T item);

  /// Saves a list of entities.
  Future<void> saveAll(List<T> items);

  /// Updates an existing entity.
  Future<void> update(T item);

  /// Deletes a single entity by unique key/id.
  Future<void> delete(String id);

  /// Deletes all entities in this data source's collection.
  Future<void> deleteAll();

  /// Performs an efficient batch insert or update operation.
  Future<void> batchInsertOrUpdate(List<T> items);

  /// Returns total record count.
  Future<int> count();

  /// Checks if an entity exists by unique key/id.
  Future<bool> exists(String id);
}
