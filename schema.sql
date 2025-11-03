-- ==============================
-- arquivo: schema.sql
-- Criação do banco de dados, tabelas, procedures e triggers (MySQL)
-- ==============================

CREATE DATABASE IF NOT EXISTS restaurante;
USE restaurante;

-- Tabelas principais
CREATE TABLE IF NOT EXISTS clientes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  telefone VARCHAR(20),
  email VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS mesas (
  id INT AUTO_INCREMENT PRIMARY KEY,
  numero INT NOT NULL UNIQUE,
  capacidade INT DEFAULT 4,
  status VARCHAR(20) DEFAULT 'Livre'
);

CREATE TABLE IF NOT EXISTS categorias_produto (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS fornecedores (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  contato VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS produtos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  preco DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  estoque INT NOT NULL DEFAULT 0,
  id_categoria INT,
  FOREIGN KEY (id_categoria) REFERENCES categorias_produto(id)
);

-- Tabela N:N entre produtos e fornecedores
CREATE TABLE IF NOT EXISTS produtos_fornecedores (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_produto INT NOT NULL,
  id_fornecedor INT NOT NULL,
  FOREIGN KEY (id_produto) REFERENCES produtos(id) ON DELETE CASCADE,
  FOREIGN KEY (id_fornecedor) REFERENCES fornecedores(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS funcionarios (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  cargo VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS pedidos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_cliente INT,
  id_mesa INT,
  data_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
  status VARCHAR(30) DEFAULT 'Aberto',
  FOREIGN KEY (id_cliente) REFERENCES clientes(id),
  FOREIGN KEY (id_mesa) REFERENCES mesas(id)
);

CREATE TABLE IF NOT EXISTS itens_pedido (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_pedido INT NOT NULL,
  id_produto INT NOT NULL,
  quantidade INT NOT NULL DEFAULT 1,
  preco_unit DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  FOREIGN KEY (id_pedido) REFERENCES pedidos(id) ON DELETE CASCADE,
  FOREIGN KEY (id_produto) REFERENCES produtos(id)
);

CREATE TABLE IF NOT EXISTS historico_pedidos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_pedido INT,
  acao VARCHAR(255),
  data_hora DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS historico_estoque (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_produto INT,
  descricao VARCHAR(255),
  data_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_produto) REFERENCES produtos(id)
);

CREATE TABLE IF NOT EXISTS pagamentos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_pedido INT,
  metodo VARCHAR(50),
  valor DECIMAL(10,2),
  data_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_pedido) REFERENCES pedidos(id)
);

-- ==============================
-- Stored Procedures
-- ==============================

-- 1) inserir_pedido: insere pedido e retorna novo_id
DROP PROCEDURE IF EXISTS inserir_pedido;
DELIMITER $$
CREATE PROCEDURE inserir_pedido(IN cliente_id INT, IN mesa_id INT)
BEGIN
  INSERT INTO pedidos (id_cliente, id_mesa) VALUES (cliente_id, mesa_id);
  SELECT LAST_INSERT_ID() AS novo_id;
END$$
DELIMITER ;

-- 2) atualizar_estoque: decrementa estoque (não baixa abaixo de 0)
DROP PROCEDURE IF EXISTS atualizar_estoque;
DELIMITER $$
CREATE PROCEDURE atualizar_estoque(IN produto_id INT, IN qtd_vendida INT)
BEGIN
  DECLARE novo_estoque INT;
  SELECT estoque - qtd_vendida INTO novo_estoque FROM produtos WHERE id = produto_id;
  IF novo_estoque < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estoque insuficiente';
  ELSE
    UPDATE produtos SET estoque = novo_estoque WHERE id = produto_id;
    INSERT INTO historico_estoque (id_produto, descricao) 
      VALUES (produto_id, CONCAT('Estoque reduzido em ', qtd_vendida, ' unidade(s). Novo: ', novo_estoque));
  END IF;
END$$
DELIMITER ;

-- 3) calcular_total_pedido: soma quantidade * preco_unit (ou preco atual)
DROP PROCEDURE IF EXISTS calcular_total_pedido;
DELIMITER $$
CREATE PROCEDURE calcular_total_pedido(IN pedido_id INT)
BEGIN
  SELECT COALESCE(SUM(ip.quantidade * ip.preco_unit), 0.00) AS total
  FROM itens_pedido ip
  WHERE ip.id_pedido = pedido_id;
END$$
DELIMITER ;

-- 4) listar_pedidos_cliente: lista pedidos do cliente
DROP PROCEDURE IF EXISTS listar_pedidos_cliente;
DELIMITER $$
CREATE PROCEDURE listar_pedidos_cliente(IN cliente_id INT)
BEGIN
  SELECT p.id, p.data_hora, p.status, m.numero AS numero_mesa
  FROM pedidos p
  LEFT JOIN mesas m ON m.id = p.id_mesa
  WHERE p.id_cliente = cliente_id
  ORDER BY p.data_hora DESC;
END$$
DELIMITER ;

-- ==============================
-- Triggers
-- ==============================

-- 1) after_insert_pedido: registra histórico e marca mesa como Ocupada
DROP TRIGGER IF EXISTS after_insert_pedido;
DELIMITER $$
CREATE TRIGGER after_insert_pedido
AFTER INSERT ON pedidos
FOR EACH ROW
BEGIN
  INSERT INTO historico_pedidos (id_pedido, acao) VALUES (NEW.id, 'Pedido criado');
  UPDATE mesas SET status = 'Ocupada' WHERE id = NEW.id_mesa;
END$$
DELIMITER ;

-- 2) after_insert_item: quando item é inserido, registra preço_unit e atualiza estoque
DROP TRIGGER IF EXISTS after_insert_item;
DELIMITER $$
CREATE TRIGGER after_insert_item
AFTER INSERT ON itens_pedido
FOR EACH ROW
BEGIN
  -- se preco_unit for 0, copia do produto atual
  IF NEW.preco_unit = 0 THEN
    UPDATE itens_pedido SET preco_unit = (SELECT preco FROM produtos WHERE id = NEW.id_produto) WHERE id = NEW.id;
  END IF;
  -- tenta atualizar estoque via procedure
  CALL atualizar_estoque(NEW.id_produto, NEW.quantidade);
  INSERT INTO historico_pedidos (id_pedido, acao) VALUES (NEW.id_pedido, CONCAT('Item adicionado: produto ', NEW.id_produto, ' qtde ', NEW.quantidade));
END$$
DELIMITER ;

-- 3) after_update_produto: registra alterações de estoque
DROP TRIGGER IF EXISTS after_update_produto;
DELIMITER $$
CREATE TRIGGER after_update_produto
AFTER UPDATE ON produtos
FOR EACH ROW
BEGIN
  IF NEW.estoque <> OLD.estoque THEN
    INSERT INTO historico_estoque (id_produto, descricao) 
      VALUES (NEW.id, CONCAT('Estoque alterado de ', OLD.estoque, ' para ', NEW.estoque));
  END IF;
END$$
DELIMITER ;

-- ==============================
-- Dados de exemplo (opcional)
-- ==============================

INSERT IGNORE INTO categorias_produto (id, nome) VALUES (1,'Pizza');
INSERT IGNORE INTO fornecedores (id, nome, contato) VALUES (1,'Distribuidora ABC','(81) 9999-0000');
INSERT IGNORE INTO produtos (id, nome, preco, estoque, id_categoria) VALUES (1,'Pizza Calabresa',35.00,10,1);
INSERT IGNORE INTO produtos_fornecedores (id_produto, id_fornecedor) VALUES (1,1);
INSERT IGNORE INTO mesas (id, numero, capacidade, status) VALUES (1,1,4,'Livre');
INSERT IGNORE INTO clientes (id, nome, telefone, email) VALUES (1,'Maria','99999-9999','maria@example.com');

