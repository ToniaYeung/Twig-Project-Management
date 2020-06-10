import 'package:firebase_storage/firebase_storage.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:twig/firebase/storage.dart';

main() {
  test('uploadTaskPhoto should upload a photo', () async {
    //setup
    MockFirebaseStorage mockFirebaseStorage = MockFirebaseStorage();
    Storage storage = Storage(mockFirebaseStorage);
    String taskId = "someTaskId";
    StorageReference storageReference = MockStorageReference();
    StorageReference childRef = MockStorageReference();
    StorageUploadTask storageUploadTask = MockStorageUploadTask();
    when(mockFirebaseStorage.ref()).thenReturn(storageReference);
    when(storageReference.child("$taskId/")).thenReturn(childRef);
    when(childRef.putFile(any)).thenReturn((storageUploadTask));

    //action
    await storage.uploadTaskPhoto("randomFilePath", taskId);

    //assert
    verify(storageUploadTask.onComplete).called(1);
  });
}

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

class MockStorageReference extends Mock implements StorageReference {}

class MockStorageUploadTask extends Mock implements StorageUploadTask {}
