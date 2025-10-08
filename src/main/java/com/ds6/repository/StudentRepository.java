package com.ds6.repository;

import java.util.UUID;

import org.springframework.stereotype.Repository;
import org.springframework.data.jpa.repository.JpaRepository;

import com.ds6.model.Student;

@Repository
public interface StudentRepository extends JpaRepository<Student, UUID> {
}
