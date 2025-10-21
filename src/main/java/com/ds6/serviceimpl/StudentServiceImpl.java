package com.ds6.serviceimpl;

import java.io.IOException;
import java.io.Writer;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVPrinter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.ds6.dto.CreateStudentDTO;
import com.ds6.dto.StudentDTO;
import com.ds6.dto.UpdateStudentDTO;
import com.ds6.exception.ResourceNotFoundException;
import com.ds6.model.Student;
import com.ds6.repository.StudentRepository;
import com.ds6.service.StudentService;

@Slf4j
@Service
@RequiredArgsConstructor
public class StudentServiceImpl implements StudentService {

    private StudentRepository studentRepository;

    private final KafkaTemplate<String, String> kafkaTemplate;

    @Override
    @Transactional
    public StudentDTO createStudent(CreateStudentDTO studentDTO) {
        Student student = new Student();
        student.setId(UUID.randomUUID());
        student.setRegistration("MAT-" + student.getId().toString().substring(0, 8).toUpperCase());
        student.setName(studentDTO.name());
        student.setBirthDate(studentDTO.birthDate());
        student.setGrade(studentDTO.grade());
        student.setClassNumber(studentDTO.classNumber());
        student.setAddress(studentDTO.address());
        student.setPhone(studentDTO.phone());

        Student savedStudent = studentRepository.save(student);

        try {
            // Define o nome do tópico para onde a mensagem será enviada
            String topic = "student.created";
            // O valor da mensagem será o ID do aluno. Outros serviços podem usar este ID
            // para obter mais detalhes sobre o aluno se precisarem.
            String payload = savedStudent.getId().toString();

            kafkaTemplate.send(topic, payload);
            log.info("Event 'student.created' published for student ID: {}", payload);
        } catch (Exception e) {
            // É uma boa prática adicionar um log de erro caso a publicação falhe,
            // para que a criação do aluno não falhe, mas o erro seja registado.
            log.error("Failed to publish 'student.created' event for student ID: {}. Error: {}", savedStudent.getId(), e.getMessage());
        }

        return toDTO(savedStudent);
    }

    @Override
    @Transactional(readOnly = true)
    public List<StudentDTO> getAllStudents() {
        return studentRepository.findAll().stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public StudentDTO getStudentById(UUID id) {
        Student student = studentRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Student not found with id: " + id));
        return toDTO(student);
    }

    @Override
    @Transactional
    public StudentDTO updateStudent(UUID id, UpdateStudentDTO studentDTO) {
        Student student = studentRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Student not found"));

        student.setName(studentDTO.name());
        student.setGrade(studentDTO.grade());
        student.setAddress(studentDTO.address());
        student.setPhone(studentDTO.phone());

        Student updatedStudent = studentRepository.save(student);
        return toDTO(updatedStudent);
    }
    
    @Override
    @Transactional
    public void deleteStudent(UUID id) {
        if (!studentRepository.existsById(id)) {
            throw new ResourceNotFoundException("Student not found with id: " + id);
        }
        studentRepository.deleteById(id);
    }

    @Override
    @Transactional(readOnly = true)
    public StudentDTO getStudentByRegistration(String registration) {
        Student student = studentRepository.findByRegistration(registration)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found with registration: " + registration));
        return toDTO(student);
    }

    @Override
    @Transactional(readOnly = true)
    public List<StudentDTO> getStudentsByName(String name) {
        return studentRepository.findByNameContainingIgnoreCase(name).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public void exportStudentsToCsv(Writer writer) throws IOException {
        List<Student> students = studentRepository.findAll();

        String[] headers = {"ID", "Registration", "Name", "BirthDate", "Address", "Contact"};

        try (CSVPrinter csvPrinter = new CSVPrinter(writer, CSVFormat.DEFAULT.withHeader(headers))) {
            for (Student student : students) {
                csvPrinter.printRecord(
                    student.getId(),
                    student.getRegistration(),
                    student.getName(),
                    student.getBirthDate(),
                    student.getAddress(),
                    student.getPhone()
                );
            }
        }
    }

    private StudentDTO toDTO(Student student) {
        return new StudentDTO(
            student.getId(),
            student.getRegistration(),
            student.getName(),
            student.getBirthDate(),
            student.getAddress(),
            student.getPhone()
        );
    }
}
