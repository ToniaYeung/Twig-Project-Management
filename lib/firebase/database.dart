import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:twig/models/all_projects.dart';
import 'package:twig/models/all_tasks.dart';
import 'package:twig/models/assignees.dart';
import 'package:twig/models/task.dart';
import 'package:twig/models/user.dart';

import '../models/project.dart';

class Database {
  final Firestore _firestore;

  Database(this._firestore);

/*
 User functions
 */
  Future<void> addUser(User user) async {
    _firestore.document("users/${user.id}").setData(user.toJson());
  }

  Future<Assignees> getUsersFromIds(List<String> userIds) async {
    if (userIds.isEmpty) {
      return Assignees([]);
    }

    final snapshot = await _firestore
        .collection("users")
        .where("id", whereIn: userIds)
        .limit(userIds.length)
        .getDocuments();

    List<User> users = snapshot.documents.map((userDocument) {
      final userJson = userDocument.data;
      User user = User.fromJson(userJson);
      return user;
    }).toList();

    Assignees allUsers = Assignees(users);
    return allUsers;
  }

  Stream<Color> getUserColour(String userId) {
    return _firestore
        .collection("users")
        .where("id", isEqualTo: userId)
        .limit(1)
        .snapshots()
        .map((QuerySnapshot snapshot) {
      //data is json
      User user = User.fromJson(snapshot.documents[0].data);

      //call colour constructor and pass in the integer to make it a color object
      Color colour = Color(user.colour);

      return colour;
    });
  }

  Future<void> updateUserColour(String userId, Color colour) async {
    DocumentReference userDocument = _firestore.document("users/$userId");

    userDocument.setData({
      "colour": colour.value,
    }, merge: true);
  }

/*
 Project functions
 */

//adds project to firestore
  Future<void> addProject(Project project) async {
    //Example path in firestore "/projects/1234/tasks/6789"
    //Add a document in firestore with the id of our project, so that we can reference it easily later
    _firestore.document("projects/${project.id}").setData(project.toJson());
  }

  Future<void> deleteProject(String projectId) async {
    _firestore.document("projects/$projectId").delete();
  }

  Stream<Project> getProject(String projectId) {
    return _firestore
        .document("projects/$projectId")
        .snapshots()
        .map((snapshot) {
      final projectJson = snapshot.data;
      // When we delete the project,  as we are streaming all of the changes,
      // the deleted project json will become null. In order to avoid errors, we can return an empty project
      if (projectJson == null) {
        return Project("", null, null, null, "", null);
      }
      Project project = Project.fromJson(projectJson);
      return project;
    });
  }

//continuously output values as things change
  Stream<AllProjects> getAllProjects(String userId) {
    //.collection("projects") gives us the collection for projects
    //.snapshots() returns a stream of events
    //.map() goes over each event as they appear, and runs the function inside

    return _firestore
        .collection("projects")
        .where("assignees", arrayContains: userId)
        .snapshots()
        .map((event) {
      List<Project> allProjects = [];
      for (final document in event.documents) {
        Project project = Project.fromJson(document.data);
        allProjects.add(project);
      }
      return AllProjects(allProjects);
    });
  }

  Future<void> addAssigneeToProject(String inputEmail, String projectId) async {
    String email = inputEmail.toLowerCase();
    //Find the user where their email is equal to the email we have been given
    //limit 1 = ask for only one document
    QuerySnapshot snapshot = await _firestore
        .collection("users")
        .where("email", isEqualTo: email)
        .limit(1)
        .getDocuments();

    if (snapshot.documents.isEmpty) {
      throw EmailDoesNotExistException();
    }

    final userJson = snapshot.documents[0].data;
    //get the user json and turn it into an object
    User user = User.fromJson(userJson);

    //Now we have the user. We need to add it to the list of assignees for the project
    DocumentReference projectDocument =
        _firestore.document("projects/$projectId");

    //Adds the user's id into the assignees list for the project
    projectDocument.setData({
      "assignees": FieldValue.arrayUnion([user.id])
    }, merge: true);
  }

  Future<void> deleteAssigneeFromProject(
      String projectId, String assigneeUserId) async {
    DocumentReference projectDocument =
        _firestore.document("projects/$projectId");

    projectDocument.setData({
      "assignees": FieldValue.arrayRemove([assigneeUserId])
    }, merge: true);
  }

  Future<void> updateTeamLeader(
      String userIdToBeTeamLeader, String projectId) async {
    DocumentReference projectDocument =
        _firestore.document("projects/$projectId");

    projectDocument.setData({
      "teamLeader": userIdToBeTeamLeader,
    }, merge: true);
  }

/*
 Task functions
 */

  Future<void> addTask(Task task, String projectId) async {
    //Example path in firestore "/projects/1234/tasks/6789"
    //Add a document in firestore with the id of our task, so that we can reference it easily later
    _firestore
        .document("projects/$projectId/tasks/${task.id}")
        .setData(task.toJson());
  }

  Future<void> deleteTask(String projectId, String taskId) async {
    _firestore.document("projects/$projectId/tasks/$taskId").delete();
  }

  Stream<AllTasks> getAllTasks(String projectId) {
    //.collection("projects") gives us the collection for projects
    //.snapshots() returns a stream of events`
    //.map() goes over each event as they appear, and runs the function inside

    return _firestore
        .collection("projects/$projectId/tasks")
        .orderBy("dueDate")
        .snapshots() //Stream<QuerySnapshot>
        .map((QuerySnapshot event) {
      List<Task> allTasks = [];
      for (final document in event.documents) {
        Task task = Task.fromJson(document.data);
        allTasks.add(task);
      }
      return AllTasks(allTasks);
    }); //Stream<AllTasks>
  }

  Future<void> setTaskStatus(
      Task task, String taskStatus, String projectId, DateTime now) async {
    Task updatedTask;
    if (taskStatus == "backlog") {
      // If it's in done, then it cannot have to do or done status, so set it to null
      updatedTask = Task(task.name, task.id, task.description, taskStatus,
          task.estimation, task.dueDate, task.assignedTo, null, null);
    }
    if (taskStatus == "todo") {
      // If it's in to do, then it cannot have been moved to done, so set it to null
      updatedTask = Task(task.name, task.id, task.description, taskStatus,
          task.estimation, task.dueDate, task.assignedTo, now, null);
    }

    if (taskStatus == "in progress") {
      // If it's in progress, then it cannot have been moved to done, so set it to null
      updatedTask = Task(
          task.name,
          task.id,
          task.description,
          taskStatus,
          task.estimation,
          task.dueDate,
          task.assignedTo,
          task.movedToToDo,
          null);
    }

    if (taskStatus == "done") {
      updatedTask = Task(
          task.name,
          task.id,
          task.description,
          taskStatus,
          task.estimation,
          task.dueDate,
          task.assignedTo,
          task.movedToToDo,
          now);
    }

    // Set the document data to the task with the updated status
    await _firestore
        .document("projects/$projectId/tasks/${task.id}")
        .setData(updatedTask.toJson());
  }

  Future<void> updateTaskAssignee(
      String projectId, String taskId, String assigneeId) async {
    DocumentReference taskDocument =
        _firestore.document("projects/$projectId/tasks/$taskId");

    taskDocument.setData({
      "assignedTo": assigneeId,
    }, merge: true);
  }
}

class EmailDoesNotExistException implements Exception {}
