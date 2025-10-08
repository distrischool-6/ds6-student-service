package com.ds6.service;

import java.util.List;
import java.util.UUID;

import com.ds6.model.Student;

public interface StudentInterface {
    public Student createStudent(Student student);
    public List<Student> getAllStudents();
    public Student getStudentById(UUID id);
    public Student updateStudent(UUID id, Student student);
}
