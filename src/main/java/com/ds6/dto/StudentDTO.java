package com.ds6.dto;

import java.time.LocalDate;
import java.util.UUID;

public record StudentDTO (
    UUID id,
    String registration,
    String name,
    LocalDate birthDate,
    String address,
    String phone
) {}
