```dart
void main() async {
    // You can find this in your firebase project settings
    final myFirebaseProjectId = "";

    final myDatabaseAdapter = FiredartDatabaseAdapter(firebaseProjectId: myFirebaseProjectId)
    
    // Register a Database Adapter that you want to use.
    DatabaseAdapterRegistry.register(myDatabaseAdapter);

    final repository = DatabaseRepository.fromRegistry(serializer: mySerializer, name: 'firebase');
    
    // Now use some methods such as create() etc.
}
```