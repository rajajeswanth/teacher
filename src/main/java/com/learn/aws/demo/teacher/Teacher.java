package com.learn.aws.demo.teacher;

public class Teacher {
  String name;
  String[] students;
  String[] remoteStudents;

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public String[] getStudents() {
    return students;
  }

  public void setStudents(String[] students) {
    this.students = students;
  }

  public String[] getRemoteStudents() {
    return remoteStudents;
  }

  public void setRemoteStudents(String[] remoteStudents) {
    this.remoteStudents = remoteStudents;
  }
}
