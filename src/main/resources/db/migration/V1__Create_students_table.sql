CREATE TABLE students (
    -- Colunas Mapeadas pelas Anotações JPA

    -- @Id
    -- Tipos UUID são comuns para IDs globais em PostgreSQL.
    id UUID NOT NULL,

    -- @Column(nullable = false, unique = true)
    registration VARCHAR(255) NOT NULL UNIQUE,

    -- @Column(nullable = false)
    name VARCHAR(255) NOT NULL,

    -- @Column(nullable = false)
    -- Mapeia java.time.LocalDate para o tipo DATE no SQL.
    birth_date DATE NOT NULL,

    -- @Column(nullable = false)
    grade VARCHAR(255) NOT NULL,

    -- @Column(nullable = false)
    -- Observe a convenção de nomeação snake_case para o banco de dados.
    class_number VARCHAR(255) NOT NULL,

    -- Sem anotações de restrição, assume-se que são nullable
    address VARCHAR(255),

    phone VARCHAR(255),

    -- Restrições Primárias
    CONSTRAINT pk_students PRIMARY KEY (id)
);