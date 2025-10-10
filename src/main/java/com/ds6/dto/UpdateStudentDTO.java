package com.ds6.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record UpdateStudentDTO(
    @NotBlank(message = "Name cannot be blank")
    @Size(min = 2, max = 100, message = "Name must be between 2 and 100 characters")
    String name, 

    @Size(max = 50, message = "Grade can have a maximum of 50 characters")
    String grade,
    
    @Size(max = 255, message = "Address can have a maximum of 255 characters")
    String address,
    
    @Size(max = 50, message = "Contact can have a maximum of 50 characters")
    String phone
    ) {}
