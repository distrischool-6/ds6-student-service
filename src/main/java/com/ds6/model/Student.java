package com.ds6.model;

import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

@Entity
@Table(name = "students")
@Data
public class Student {

    @Id
    private UUID id;

    @Column(nullable = false, unique = true)
    private String registration;
    
    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String birthDate;

    @Column(nullable = false)
    private Integer grade;

    @Column(nullable = false)
    private Integer classNumber;

    private String address;

    private String phone;
}
