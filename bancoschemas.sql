CREATE DATABASE IF NOT EXISTS atividade1_db;
USE atividade1_db;

DROP TABLE IF EXISTS log_exclusao, produto_fornecedor, pedido_produto, pagamento, pedido, produto, fornecedor, categoria, endereco, cliente;

CREATE TABLE cliente (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    telefone VARCHAR(20)
);

CREATE TABLE endereco (
    id INT AUTO_INCREMENT PRIMARY KEY,
    rua VARCHAR(100),
    cidade VARCHAR(50),
    estado VARCHAR(50),
    cep VARCHAR(10),
    cliente_id INT,
    FOREIGN KEY (cliente_id) REFERENCES cliente(id)
);

CREATE TABLE categoria (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL
);

CREATE TABLE produto (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    preco DECIMAL(10,2) NOT NULL,
    quantidade INT DEFAULT 0,
    categoria_id INT,
    FOREIGN KEY (categoria_id) REFERENCES categoria(id)
);

CREATE TABLE pedido (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT,
    data_pedido DATETIME DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10,2) DEFAULT 0,
    FOREIGN KEY (cliente_id) REFERENCES cliente(id)
);

CREATE TABLE pedido_produto (
    pedido_id INT,
    produto_id INT,
    quantidade INT,
    preco_unitario DECIMAL(10,2),
    PRIMARY KEY (pedido_id, produto_id),
    FOREIGN KEY (pedido_id) REFERENCES pedido(id),
    FOREIGN KEY (produto_id) REFERENCES produto(id)
);

CREATE TABLE pagamento (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT,
    valor DECIMAL(10,2),
    data_pagamento DATETIME DEFAULT CURRENT_TIMESTAMP,
    metodo VARCHAR(50),
    FOREIGN KEY (pedido_id) REFERENCES pedido(id)
);

CREATE TABLE fornecedor (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100),
    cnpj VARCHAR(20),
    telefone VARCHAR(20)
);

CREATE TABLE produto_fornecedor (
    produto_id INT,
    fornecedor_id INT,
    PRIMARY KEY (produto_id, fornecedor_id),
    FOREIGN KEY (produto_id) REFERENCES produto(id),
    FOREIGN KEY (fornecedor_id) REFERENCES fornecedor(id)
);

CREATE TABLE log_exclusao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tabela_nome VARCHAR(100),
    registro_id INT,
    acao VARCHAR(50),
    data_acao DATETIME DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //

CREATE PROCEDURE sp_inserir_pedido(
    IN p_cliente_id INT,
    OUT p_novo_pedido_id INT
)
BEGIN
    INSERT INTO pedido (cliente_id, data_pedido, total)
    VALUES (p_cliente_id, NOW(), 0);
    SET p_novo_pedido_id = LAST_INSERT_ID();
END //

CREATE PROCEDURE sp_atualizar_estoque(
    IN p_produto_id INT,
    IN p_quantidade INT
)
BEGIN
    UPDATE produto
    SET quantidade = quantidade + p_quantidade
    WHERE id = p_produto_id;
END //

CREATE PROCEDURE sp_listar_clientes_por_cidade(
    IN p_cidade VARCHAR(50)
)
BEGIN
    SELECT c.id, c.nome, c.email, e.cidade
    FROM cliente c
    JOIN endereco e ON c.id = e.cliente_id
    WHERE e.cidade = p_cidade;
END //

CREATE PROCEDURE sp_calcular_total_pedido(
    IN p_pedido_id INT,
    OUT p_total DECIMAL(10,2)
)
BEGIN
    SELECT SUM(pp.quantidade * pp.preco_unitario)
    INTO p_total
    FROM pedido_produto pp
    WHERE pp.pedido_id = p_pedido_id;

    UPDATE pedido
    SET total = p_total
    WHERE id = p_pedido_id;
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER trg_after_insert_pedido_produto
AFTER INSERT ON pedido_produto
FOR EACH ROW
BEGIN
    UPDATE produto
    SET quantidade = quantidade - NEW.quantidade
    WHERE id = NEW.produto_id;
END //

CREATE TRIGGER trg_before_delete_produto
BEFORE DELETE ON produto
FOR EACH ROW
BEGIN
    INSERT INTO log_exclusao(tabela_nome, registro_id, acao, data_acao)
    VALUES ('produto', OLD.id, 'DELETE', NOW());
END //

CREATE TRIGGER trg_after_update_produto
AFTER UPDATE ON produto
FOR EACH ROW
BEGIN
    IF OLD.quantidade <> NEW.quantidade THEN
        INSERT INTO log_exclusao(tabela_nome, registro_id, acao, data_acao)
        VALUES ('produto', NEW.id, 'UPDATE_QUANTIDADE', NOW());
    END IF;
END //

DELIMITER ;

INSERT INTO cliente (nome, email, telefone) VALUES
('Maria Silva', 'maria@email.com', '81999999999'),
('João Santos', 'joao@email.com', '81988888888');

INSERT INTO endereco (rua, cidade, estado, cep, cliente_id) VALUES
('Rua A', 'Recife', 'PE', '50000-000', 1),
('Rua B', 'Olinda', 'PE', '53000-000', 2);

INSERT INTO categoria (nome) VALUES ('Bebidas'), ('Comidas');

INSERT INTO produto (nome, preco, quantidade, categoria_id) VALUES
('Suco Laranja', 5.00, 20, 1),
('Refrigerante', 4.00, 15, 1),
('Hamburguer', 12.00, 10, 2);

INSERT INTO fornecedor (nome, cnpj, telefone) VALUES ('Fornecedor A', '12.345.678/0001-99', '81977777777');
INSERT INTO produto_fornecedor (produto_id, fornecedor_id) VALUES (1,1),(2,1),(3,1);


CALL sp_inserir_pedido(1, @novo_pedido);
SELECT @novo_pedido AS id_criado;

INSERT INTO pedido_produto (pedido_id, produto_id, quantidade, preco_unitario)
VALUES (@novo_pedido, 1, 2, 5.00),
       (@novo_pedido, 3, 1, 12.00);

CALL sp_atualizar_estoque(2, -3);

CALL sp_listar_clientes_por_cidade('Recife');

CALL sp_calcular_total_pedido(@novo_pedido, @total_pedido);
SELECT @total_pedido AS total_calculado;

DELETE FROM produto WHERE id = 3;
SELECT * FROM log_exclusao WHERE registro_id = 3;

UPDATE produto SET quantidade = quantidade + 5 WHERE id = 1;
SELECT * FROM log_exclusao WHERE registro_id = 1 ORDER BY data_acao DESC;

SELECT * FROM cliente;
SELECT * FROM endereco;
SELECT * FROM categoria;
SELECT * FROM produto;
SELECT * FROM pedido;
SELECT * FROM pedido_prosp_atualizar_estoquesp_calcular_total_pedidosp_listar_clientes_por_cidadesp_atualizar_estoqueduto;
SELECT * FROM fornecedor;
SELECT * FROM produto_fornecedor;
SELECT * FROM log_exclusao;


SELECT * FROM produto;


