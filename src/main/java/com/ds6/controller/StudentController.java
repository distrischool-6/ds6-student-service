package com.ds6.controller;

import java.io.IOException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Collections;
import java.util.Date;
import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.ds6.dto.CreateStudentDTO;
import com.ds6.dto.StudentDTO;
import com.ds6.dto.UpdateStudentDTO;
import com.ds6.service.StudentService;

import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/students")
@RequiredArgsConstructor
public class StudentController {
    private final StudentService studentService;

    @PostMapping("/create")
    public ResponseEntity<StudentDTO> createStudent(@RequestBody CreateStudentDTO studentDTO) {
        StudentDTO createdStudent = studentService.createStudent(studentDTO);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdStudent);
    }

    @GetMapping("/all")
    public ResponseEntity<List<StudentDTO>> getAllStudents() {
        List<StudentDTO> students = studentService.getAllStudents();
        return ResponseEntity.ok(students);
    }

    @GetMapping("/{id}")
    public ResponseEntity<StudentDTO> getStudentById(@PathVariable("id") String id) {
        StudentDTO student = studentService.getStudentById(java.util.UUID.fromString(id));
        if (student != null) {
            return ResponseEntity.ok(student);
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
        }
    }

    @PutMapping("/update/{id}")
    public ResponseEntity<StudentDTO> updateStudent(@PathVariable("id") String id, @RequestBody UpdateStudentDTO studentDTO) {
        StudentDTO updatedStudent = studentService.updateStudent(java.util.UUID.fromString(id), studentDTO);
        if (updatedStudent != null) {
            return ResponseEntity.ok(updatedStudent);
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
        }
    }

    @GetMapping("/search")
    public ResponseEntity<List<StudentDTO>> getStudents(
            @RequestParam(required = false) String name,
            @RequestParam(required = false) String registration) {

        if (registration != null && !registration.isEmpty()) {
            List<StudentDTO> result = List.of(studentService.getStudentByRegistration(registration));
            return ResponseEntity.ok(result);
        }

        if (name != null && !name.isEmpty()) {
            List<StudentDTO> results = studentService.getStudentsByName(name);
            return ResponseEntity.ok(results);
        }

        return ResponseEntity.ok(Collections.emptyList());
    }

    @GetMapping("/export/csv")
    public void exportStudentsToCsv(HttpServletResponse response) throws IOException {
        // Define o tipo de conteúdo da resposta como CSV
        response.setContentType("text/csv");

        // Formata a data e hora atuais para incluir no nome do ficheiro
        DateFormat dateFormatter = new SimpleDateFormat("yyyy-MM-dd_HH-mm-ss");
        String currentDateTime = dateFormatter.format(new Date());

        // Define o cabeçalho para forçar o download do ficheiro com um nome específico
        String headerKey = "Content-Disposition";
        String headerValue = "attachment; filename=students_" + currentDateTime + ".csv";
        response.setHeader(headerKey, headerValue);

        // Chama o serviço para escrever os dados CSV diretamente no 'writer' da resposta
        studentService.exportStudentsToCsv(response.getWriter());
    }
}
