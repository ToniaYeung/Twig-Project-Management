import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:twig/firebase/database.dart';
import 'package:twig/models/all_projects.dart';
import 'package:twig/models/assignees.dart';
import 'package:twig/models/project.dart';
import 'package:twig/models/task.dart';
import 'package:twig/models/user.dart';

main() {
  test('addUser should add the user to firebase', () async {
    //setup
    User user = User("tonia", "abc", "tonia@email.com", 123);
    MockFirestore mockFirestore = MockFirestore();
    Database database = Database(mockFirestore);
    MockDocumentReference docRef = MockDocumentReference();
    when(mockFirestore.document("users/${user.id}")).thenReturn(docRef);

    //action
    await database.addUser(user);

    //assert
    verify(docRef.setData(user.toJson())).called(1);
  });

  test(
      'getUsersFromIds should return all the corresponding users from their ids',
      () async {
    //setup
    User user = User("tonia", "abc", "tonia@email.com", 123);
    User user2 = User("user2", "xyz", "user@email.com", 123);
    List<String> userIds = [user.id];
    MockFirestore mockFirestore = MockFirestore();
    Database database = Database(mockFirestore);
    MockQuery mockQuery = MockQuery();
    MockQuery mockQuery2 = MockQuery();
    MockQuerySnapshot mockQuerySnapshot = MockQuerySnapshot();
    MockCollectionReference collectionRef = MockCollectionReference();
    MockDocumentSnapshot docSnap = MockDocumentSnapshot();
    MockDocumentSnapshot docSnap2 = MockDocumentSnapshot();
    when(mockFirestore.collection("users")).thenReturn(collectionRef);
    when(collectionRef.where("id", whereIn: userIds)).thenReturn(mockQuery);
    when(mockQuery.limit(userIds.length)).thenReturn(mockQuery2);
    when(mockQuery2.getDocuments())
        .thenAnswer((_) => Future.value(mockQuerySnapshot));
    when(mockQuerySnapshot.documents).thenReturn([docSnap, docSnap2]);
    when(docSnap.data).thenReturn(user.toJson());
    when(docSnap2.data).thenReturn(user2.toJson());

    //action
    Assignees usersFromIds = await database.getUsersFromIds(userIds);

    //assert
    expect(usersFromIds.users.first.id, equals(user.id));
    expect(usersFromIds.users[1].id, equals(user2.id));
  });

  test(
      'getUsersFromIds if userIds is empty, then should return empty assignees',
      () async {
    //setup
    List<String> userIds = [];
    Database database = Database(null);

    //action
    Assignees assignees = await database.getUsersFromIds(userIds);

    //assert
    expect(assignees.users, equals([]));
  });

  test('addProject should add project to database', () async {
    //setup
    Project project =
        Project("Test", "abc", ["User1"], DateTime.now(), 'id', DateTime.now());
    MockFirestore mockFirestore = MockFirestore();
    Database database = Database(mockFirestore);
    MockDocumentReference docRef = MockDocumentReference();
    when(mockFirestore.document("projects/${project.id}")).thenReturn(docRef);

    //action
    await database.addProject(project);

    //assert
    verify(docRef.setData(project.toJson())).called(1);
  });

  test('deleteProject should remove project from database', () async {
    //setup
    String projectId = 'id';
    MockFirestore mockFirestore = MockFirestore();
    Database database = Database(mockFirestore);
    MockDocumentReference docRef = MockDocumentReference();
    when(mockFirestore.document("projects/$projectId")).thenReturn(docRef);

    //action
    await database.deleteProject(projectId);

    //assert
    verify(docRef.delete()).called(1);
  });

  test('getProject should return project from database', () async {
    //setup
    Project project =
        Project("Test", "abc", ["User1"], DateTime.now(), 'id', DateTime.now());
    MockFirestore mockFirestore = MockFirestore();
    Database database = Database(mockFirestore);
    MockDocumentReference docRef = MockDocumentReference();
    MockDocumentSnapshot docSnap = MockDocumentSnapshot();
    when(mockFirestore.document("projects/${project.id}")).thenReturn(docRef);
    when(docRef.snapshots()).thenAnswer((_) => Stream.value(docSnap));
    when(docSnap.data).thenReturn(project.toJson());

    //action
    Stream<Project> projectStream = database.getProject(project.id);
    Project resultProject = await projectStream.first;

    //assert
    expect(resultProject.id, equals(project.id));
  });

  test(
      'getProject should return an empty project from database if the project does not exist',
      () async {
    //setup
    String projectId = "id";
    MockFirestore mockFirestore = MockFirestore();
    Database database = Database(mockFirestore);
    MockDocumentReference docRef = MockDocumentReference();
    MockDocumentSnapshot docSnap = MockDocumentSnapshot();
    when(mockFirestore.document("projects/$projectId")).thenReturn(docRef);
    when(docRef.snapshots()).thenAnswer((_) => Stream.value(docSnap));
    when(docSnap.data).thenReturn(null);

    //action
    Stream<Project> projectStream = database.getProject(projectId);
    Project resultProject = await projectStream.first;

    //assert
    expect(resultProject.id, equals(""));
  });

  test('getAllProjects should return a stream of all projects', () async {
    //setup
    String userId = "userId";
    Project project =
        Project("Test", "abc", ["User1"], DateTime.now(), 'id', DateTime.now());
    MockFirestore mockFirestore = MockFirestore();
    Database database = Database(mockFirestore);
    MockDocumentSnapshot docSnap = MockDocumentSnapshot();
    MockCollectionReference collectionRef = MockCollectionReference();
    MockQuery mockQuery = MockQuery();
    MockQuerySnapshot mockQuerySnapshot = MockQuerySnapshot();
    when(mockFirestore.collection("projects")).thenReturn(collectionRef);
    when(collectionRef.where("assignees", arrayContains: userId))
        .thenReturn(mockQuery);
    when(mockQuery.snapshots())
        .thenAnswer((_) => Stream.value(mockQuerySnapshot));
    when(mockQuerySnapshot.documents).thenReturn([docSnap]);
    when(docSnap.data).thenReturn(project.toJson());

    //action
    Stream<AllProjects> getAllProjects = database.getAllProjects(userId);
    AllProjects allProjects = await getAllProjects.first;

    //assert
    expect(allProjects.allProjects.length, equals(1));
    expect(allProjects.allProjects.first.id, equals("id"));
  });

  test('addAssigneeToProject should add an assignee to project', () async {
    //setup
    User user = User("tonia", "abc", "tonia@email.com", 123);
    String email = "tonia@email.com";
    String projectId = "projectId123";
    MockFirestore mockFirestore = MockFirestore();
    Database database = Database(mockFirestore);
    MockQuery mockQuery = MockQuery();
    MockQuery mockQuery2 = MockQuery();
    MockCollectionReference collectionRef = MockCollectionReference();
    MockQuerySnapshot mockQuerySnapshot = MockQuerySnapshot();
    MockDocumentSnapshot docSnap = MockDocumentSnapshot();
    MockDocumentReference docRef = MockDocumentReference();
    when(mockFirestore.collection("users")).thenReturn(collectionRef);
    when(collectionRef.where("email", isEqualTo: email)).thenReturn(mockQuery);
    when(mockQuery.limit(1)).thenReturn(mockQuery2);
    when(mockQuery2.getDocuments())
        .thenAnswer((_) => Future.value(mockQuerySnapshot));
    when(mockQuerySnapshot.documents).thenReturn([docSnap]);
    when(docSnap.data).thenReturn(user.toJson());
    when(mockFirestore.document("projects/$projectId")).thenReturn(docRef);

    //action
    await database.addAssigneeToProject(email, projectId);

    //assert
    verify(docRef.setData({
      "assignees": FieldValue.arrayUnion([user.id])
    }, merge: true))
        .called(1);
  });

  test(
      'addAssigneeToProject should throw an email does not exist exception if snapshot is empty',
      () async {
    //setup
    String email = "tonia@email.com";
    String projectId = "projectId123";
    MockFirestore mockFirestore = MockFirestore();
    Database database = Database(mockFirestore);
    MockQuery mockQuery = MockQuery();
    MockQuery mockQuery2 = MockQuery();
    MockCollectionReference collectionRef = MockCollectionReference();
    MockQuerySnapshot mockQuerySnapshot = MockQuerySnapshot();
    when(mockFirestore.collection("users")).thenReturn(collectionRef);
    when(collectionRef.where("email", isEqualTo: email)).thenReturn(mockQuery);
    when(mockQuery.limit(1)).thenReturn(mockQuery2);
    when(mockQuery2.getDocuments())
        .thenAnswer((_) => Future.value(mockQuerySnapshot));
    when(mockQuerySnapshot.documents).thenReturn([]);

    //action & assert
    expect(() async => await database.addAssigneeToProject(email, projectId),
        throwsA(isA<EmailDoesNotExistException>()));
  });

  test('deleteAssigneeFromProject should delete assignee from project',
      () async {
    //setup
    String projectId = "projectId123";
    String assigneeUserId = "assigneeId";
    MockFirestore mockFirestore = MockFirestore();
    Database database = Database(mockFirestore);
    MockDocumentReference docRef = MockDocumentReference();
    when(mockFirestore.document("projects/$projectId")).thenReturn(docRef);

    //action
    await database.deleteAssigneeFromProject(projectId, assigneeUserId);

    //assert
    verify(docRef.setData({
      "assignees": FieldValue.arrayRemove([assigneeUserId])
    }, merge: true))
        .called(1);
  });

  test('addTask should add task to database', () async {
    //setup
    String projectId = "projectId";
    Task task = Task("Task", "123", "", "in progress", 1, DateTime.now(), "456",
        DateTime.now(), DateTime.now());
    MockFirestore mockFirestore = MockFirestore();
    Database database = Database(mockFirestore);
    MockDocumentReference docRef = MockDocumentReference();
    when(mockFirestore.document("projects/$projectId/tasks/${task.id}"))
        .thenReturn(docRef);

    //action
    await database.addTask(task, projectId);

    //assert
    verify(docRef.setData(task.toJson())).called(1);
  });

  test('deleteTask should remove task from database', () async {
    //setup
    String projectId = 'projectId';
    Task task = Task("Task", "123", "", "in progress", 1, DateTime.now(), "456",
        DateTime.now(), DateTime.now());
    MockFirestore mockFirestore = MockFirestore();
    Database database = Database(mockFirestore);
    MockDocumentReference docRef = MockDocumentReference();
    when(mockFirestore.document("projects/$projectId/tasks/${task.id}"))
        .thenReturn(docRef);

    //action
    await database.deleteTask(projectId, task.id);

    //assert
    verify(docRef.delete()).called(1);
  });

  group('setTaskStatus', () {
    test(
        'should set task status to backlog (and movedToToDo and movedToDone to null) in firestore',
        () async {
      //setup
      DateTime now = DateTime.now();
      String projectId = "projectId";
      String taskStatus = "backlog";
      Task task =
          Task("Task", "123", "", "in progress", 1, now, "456", now, now);
      MockFirestore mockFirestore = MockFirestore();
      Database database = Database(mockFirestore);
      MockDocumentReference docRef = MockDocumentReference();
      when(mockFirestore.document("projects/$projectId/tasks/${task.id}"))
          .thenReturn(docRef);

      //action
      await database.setTaskStatus(task, taskStatus, projectId, now);

      //assert
      Task expectedTask = Task(task.name, task.id, task.description, taskStatus,
          task.estimation, task.dueDate, task.assignedTo, null, null);
      verify(docRef.setData(expectedTask.toJson()));
    });

    test(
        'should set task status to todo (and movedToToDo to now and movedToDone to null) in firestore',
        () async {
      //setup
      DateTime now = DateTime.now();
      String projectId = "projectId";
      String taskStatus = "todo";
      Task task =
          Task("Task", "123", "", "in progress", 1, now, "456", null, now);
      MockFirestore mockFirestore = MockFirestore();
      Database database = Database(mockFirestore);
      MockDocumentReference docRef = MockDocumentReference();
      when(mockFirestore.document("projects/$projectId/tasks/${task.id}"))
          .thenReturn(docRef);

      //action
      await database.setTaskStatus(task, taskStatus, projectId, now);

      //assert
      Task expectedTask = Task(task.name, task.id, task.description, taskStatus,
          task.estimation, task.dueDate, task.assignedTo, now, null);
      verify(docRef.setData(expectedTask.toJson()));
    });
    test(
        'should set task status to in progress (movedToDone to null) in firestore',
        () async {
      //setup
      DateTime now = DateTime.now();
      String projectId = "projectId";
      String taskStatus = "in progress";
      Task task = Task("Task", "123", "", "backlog", 1, now, "456", now, now);
      MockFirestore mockFirestore = MockFirestore();
      Database database = Database(mockFirestore);
      MockDocumentReference docRef = MockDocumentReference();
      when(mockFirestore.document("projects/$projectId/tasks/${task.id}"))
          .thenReturn(docRef);

      //action
      await database.setTaskStatus(task, taskStatus, projectId, now);

      //assert
      Task expectedTask = Task(
          task.name,
          task.id,
          task.description,
          taskStatus,
          task.estimation,
          task.dueDate,
          task.assignedTo,
          task.movedToToDo,
          null);
      verify(docRef.setData(expectedTask.toJson()));
    });

    test('should set task status to done (movedToDone to now) in firestore',
        () async {
      //setup
      DateTime now = DateTime.now();
      String projectId = "projectId";
      String taskStatus = "done";
      Task task =
          Task("Task", "123", "", "in progress", 1, now, "456", now, null);
      MockFirestore mockFirestore = MockFirestore();
      Database database = Database(mockFirestore);
      MockDocumentReference docRef = MockDocumentReference();
      when(mockFirestore.document("projects/$projectId/tasks/${task.id}"))
          .thenReturn(docRef);

      //action
      await database.setTaskStatus(task, taskStatus, projectId, now);

      //assert
      Task expectedTask = Task(
          task.name,
          task.id,
          task.description,
          taskStatus,
          task.estimation,
          task.dueDate,
          task.assignedTo,
          task.movedToToDo,
          now);
      verify(docRef.setData(expectedTask.toJson()));
    });
  });

  test('updateTaskAssignee should update the new assignee for the task',
      () async {
    //setup
    String projectId = "projectId";
    DateTime now = DateTime.now();
    Task task =
        Task("Task", "123", "", "in progress", 1, now, "Assignee", now, now);
    MockFirestore mockFirestore = MockFirestore();
    Database database = Database(mockFirestore);
    MockDocumentReference docRef = MockDocumentReference();
    when(mockFirestore.document("projects/$projectId/tasks/${task.id}"))
        .thenReturn(docRef);

    //action
    String assigneeId = "newAssignee";
    await database.updateTaskAssignee(projectId, task.id, assigneeId);

    //assert

    verify(docRef.setData({
      "assignedTo": assigneeId,
    }, merge: true))
        .called(1);
  });

  test('getUserColour should get colour of the user', () async {
    //setup

    User user = User("tonia", "abc", "tonia@email.com", 123);
    MockFirestore mockFirestore = MockFirestore();
    Database database = Database(mockFirestore);
    MockCollectionReference collectionRef = MockCollectionReference();
    MockQuery mockQuery = MockQuery();
    MockQuery mockQuery2 = MockQuery();
    MockQuerySnapshot mockQuerySnapshot = MockQuerySnapshot();
    MockDocumentSnapshot docSnap = MockDocumentSnapshot();
    when(mockFirestore.collection("users")).thenReturn(collectionRef);
    when(collectionRef.where("id", isEqualTo: user.id)).thenReturn(mockQuery);
    when(mockQuery.limit(1)).thenReturn(mockQuery2);
    when(mockQuery2.snapshots())
        .thenAnswer((_) => Stream.value(mockQuerySnapshot));
    when(mockQuerySnapshot.documents).thenReturn([docSnap]);
    when(docSnap.data).thenReturn(user.toJson());

    //action
    Stream<Color> colourStream = database.getUserColour(user.id);
    Color color = await colourStream.first;
    //assert

    expect(color.value, equals(123));
  });

  test('updateUserColour should update the users colour', () async {
    //setup

    String userId = 'userId';
    Color colour = Colors.red;

    MockFirestore mockFirestore = MockFirestore();
    Database database = Database(mockFirestore);
    MockDocumentReference docRef = MockDocumentReference();
    when(mockFirestore.document("users/$userId")).thenReturn(docRef);

    //action
    await database.updateUserColour(userId, colour);

    //assert

    verify(docRef.setData({
      "colour": colour.value,
    }, merge: true))
        .called(1);
  });

  test('updateTeamLeader should update the project team leader', () async {
    //setup

    String projectId = 'projectId';
    String userIdToBeTeamLeader = "teamLeader";
    MockFirestore mockFirestore = MockFirestore();
    Database database = Database(mockFirestore);
    MockDocumentReference docRef = MockDocumentReference();
    when(mockFirestore.document("projects/$projectId")).thenReturn(docRef);

    //action
    await database.updateTeamLeader(userIdToBeTeamLeader, projectId);

    //assert

    verify(docRef.setData({
      "teamLeader": userIdToBeTeamLeader,
    }, merge: true))
        .called(1);
  });
}

class MockFirestore extends Mock implements Firestore {}

class MockDocumentReference extends Mock implements DocumentReference {}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

class MockCollectionReference extends Mock implements CollectionReference {}

class MockQuery extends Mock implements Query {}

class MockQuerySnapshot extends Mock implements QuerySnapshot {}
/*





 */
