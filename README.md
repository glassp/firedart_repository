# Firebase Repository for Dart
[![Pub Version](https://img.shields.io/pub/v/firedart_repository)](https://pub.dev/packages/firedart_repository)

Use this database adapter for firebase to integrate with database_repository

## Using Flutter?
Use [firebase_database_repository](https://pub.dev/packages/firebase_database_repository) as it is optimized for usage with Flutter

## How to install
```bash
dart pub add firedart_repository
```

## How to use
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