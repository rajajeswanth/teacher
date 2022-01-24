package com.learn.aws.demo.teacher;

import java.util.List;

public class Teacher {
  String name;
  String[] students;
  List remoteStudents;

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

  public List getRemoteStudents() {
    return remoteStudents;
  }

  public void setRemoteStudents(List remoteStudents) {
    this.remoteStudents = remoteStudents;
  }
}
