package com.ds6.dto;

import java.time.LocalDate;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Past;
import jakarta.validation.constraints.Size;

public record CreateStudentDTO (
    @NotBlank(message = "Name cannot be blank")
    @Size(min = 2, max = 100, message = "Name must be between 2 and 100 characters")
    String name,

    @NotNull(message = "Birth date cannot be null")
    @Past(message = "Birth date must be a past date")
    LocalDate birthDate,

    @NotBlank(message = "Grade cannot be blank")
    @Size(max = 50, message = "Grade can have a maximum of 50 characters")
    String grade,

    @NotBlank(message = "Class number cannot be blank")
    @Size(max = 20, message = "Class number can have a maximum of 20 characters")
    String classNumber,

    @Size(max = 255, message = "Address can have a maximum of 255 characters")
    String address,

    @Size(max = 20, message = "Phone can have a maximum of 20 characters")
    String phone
) {}
