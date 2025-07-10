-- TABELA EDUCADORES
CREATE TABLE educadores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome TEXT NOT NULL,
    email TEXT UNIQUE,
    telefone TEXT,
    perfil TEXT CHECK (perfil IN ('Professor', 'Coordenador')) NOT NULL DEFAULT 'Professor',
    ano_letivo INT,
    periodo TEXT CHECK (periodo IN ('Manhã', 'Tarde', 'Noite')),

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Trigger para atualizar o updated_at automaticamente
CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = now();
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_timestamp
BEFORE UPDATE ON educadores
FOR EACH ROW
EXECUTE FUNCTION trigger_set_timestamp();

-- TABELA TURMA
CREATE TABLE turma (
    id SERIAL PRIMARY KEY,
    educador_id UUID NOT NULL,
    turma TEXT NOT NULL,
    ano_letivo INT,
    periodo TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    FOREIGN KEY (educador_id) REFERENCES educadores(id) ON DELETE CASCADE
);

CREATE TRIGGER set_timestamp_turma
BEFORE UPDATE ON turma
FOR EACH ROW
EXECUTE FUNCTION trigger_set_timestamp();

-- Dados de teste
INSERT INTO educadores (nome, email, telefone, perfil, ano_letivo, periodo)
VALUES
    ('João Silva', 'joao@escola.com', '123456789', 'Professor', 2025, 'Manhã'),
    ('Maria Souza', 'maria@escola.com', '987654321', 'Coordenador', 2025, 'Tarde');

INSERT INTO turma (educador_id, turma, ano_letivo, periodo)
VALUES
    ((SELECT id FROM educadores WHERE email = 'joao@escola.com'), 'Turma A', 2025, 'Manhã'),
    ((SELECT id FROM educadores WHERE email = 'joao@escola.com'), 'Turma B', 2025, 'Manhã'),
    ((SELECT id FROM educadores WHERE email = 'maria@escola.com'), 'Turma C', 2025, 'Tarde');
