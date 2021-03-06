package com.learn.aws.demo.teacher;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import java.util.List;

@RestController(value = "TeacherController")
@RequestMapping("/teacher")
public class TeacherController {
  @GetMapping("/getStudents")
  ResponseEntity<Teacher> getStudents() {
    String studentsUrl = "http://student.studentteacher.local/student/getStudents";
    RestTemplate restTemplate = new RestTemplate();
    ResponseEntity<Object> responseEntity = restTemplate.getForEntity(studentsUrl, Object.class);

    Object students = new String[] {"Raja", "Kirti"};
    Teacher teacher = new Teacher();
    teacher.setName("Science Teacher");
    teacher.setRemoteStudents((List) responseEntity.getBody());
    teacher.setStudents((String[])students);
    return new ResponseEntity<>(teacher, HttpStatus.OK);
  }


  @GetMapping("/getPartialStudents")
  ResponseEntity<Teacher> getPartialStudents() {
    Object students = new String[] {"Raja", "Kirti"};
    Teacher teacher = new Teacher();
    teacher.setName("English Teacher");
    teacher.setStudents((String[])students);
    return new ResponseEntity<>(teacher, HttpStatus.OK);
  }
}
