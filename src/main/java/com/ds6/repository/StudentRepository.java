package com.ds6.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.ds6.model.Student;

@Repository
public interface StudentRepository extends JpaRepository<Student, UUID> {

    Optional<Student> findByRegistration(String registration);
    List<Student> findByNameContainingIgnoreCase(String name);
}
