package com.ds6.service;

import java.io.IOException;
import java.io.Writer;
import java.util.List;
import java.util.UUID;

import com.ds6.dto.CreateStudentDTO;
import com.ds6.dto.StudentDTO;
import com.ds6.dto.UpdateStudentDTO;

public interface StudentInterface {
    public StudentDTO createStudent(CreateStudentDTO student);
    public List<StudentDTO> getAllStudents();
    public StudentDTO getStudentById(UUID id);
    public StudentDTO updateStudent(UUID id, UpdateStudentDTO student);
    public void deleteStudent(UUID id);
    public StudentDTO getStudentByRegistration(String registration);
    public List<StudentDTO> getStudentsByName(String name);
    public void exportStudentsToCsv(Writer writer) throws IOException;
}
