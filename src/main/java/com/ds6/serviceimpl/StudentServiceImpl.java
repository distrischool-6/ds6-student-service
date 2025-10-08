package com.ds6.serviceimpl;

import java.util.List;
import java.util.UUID;

import com.ds6.model.Student;
import com.ds6.repository.StudentRepository;
import com.ds6.service.StudentInterface;

public class StudentServiceImpl implements StudentInterface {

    private StudentRepository studentRepository;

    @Override
    public Student createStudent(Student student) {
        return studentRepository.save(student);
    }

    @Override
    public List<Student> getAllStudents() {
        return studentRepository.findAll();
    }

    @Override
    public Student getStudentById(UUID id) {
        return studentRepository.findById(id).orElse(null);
    }

    @Override
    public Student updateStudent(UUID id, Student student) {
        if (studentRepository.existsById(id)) {
            student.setId(id);
            return studentRepository.save(student);
        }
        return null;
    }
    
}
