DROP TABLE IF EXISTS mesas;

CREATE TABLE mesas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    numero INT,
    capacidade INT,
    status VARCHAR(20)
);

