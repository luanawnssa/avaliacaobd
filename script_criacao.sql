CREATE DATABASE restaurante_bd;
USE restaurante_db;

-- 1. Funcionários
CREATE TABLE funcionarios (
    id_funcionario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100),
    cargo VARCHAR(50),
    salario DECIMAL(10,2)
);

-- 2. Clientes
CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100),
    telefone VARCHAR(20)
);

-- 3. Mesas
CREATE TABLE mesas (
    id_mesa INT AUTO_INCREMENT PRIMARY KEY,
    numero INT UNIQUE,
    capacidade INT,
    status_mesa VARCHAR(20) DEFAULT 'Livre'
);

-- 4. Produtos (cardápio)
CREATE TABLE produtos (
    id_produto INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100),
    preco DECIMAL(10,2),
    categoria VARCHAR(50)
);

-- 5. Pedidos
CREATE TABLE pedidos (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT,
    id_funcionario INT,
    id_mesa INT,
    data_pedido DATETIME DEFAULT NOW(),
    status_pedido VARCHAR(30) DEFAULT 'Em andamento',
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
    FOREIGN KEY (id_funcionario) REFERENCES funcionarios(id_funcionario),
    FOREIGN KEY (id_mesa) REFERENCES mesas(id_mesa)
);

-- 6. Itens do Pedido (N:N entre pedidos e produtos)
CREATE TABLE itens_pedido (
    id_pedido INT,
    id_produto INT,
    quantidade INT,
    PRIMARY KEY (id_pedido, id_produto),
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido),
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produto)
);

-- 7. Pagamentos
CREATE TABLE pagamentos (
    id_pagamento INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT,
    valor_pago DECIMAL(10,2),
    metodo_pagamento VARCHAR(50),
    data_pagamento DATETIME,
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido)
);

-- 8. Fornecedores
CREATE TABLE fornecedores (
    id_fornecedor INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100),
    contato VARCHAR(50)
);

-- 9. Ingredientes
CREATE TABLE ingredientes (
    id_ingrediente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100),
    estoque INT,
    id_fornecedor INT,
    FOREIGN KEY (id_fornecedor) REFERENCES fornecedores(id_fornecedor)
);

-- 10. Produto_Ingrediente (N:N)
CREATE TABLE produto_ingrediente (
    id_produto INT,
    id_ingrediente INT,
    quantidade_usada INT,
    PRIMARY KEY (id_produto, id_ingrediente),
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produto),
    FOREIGN KEY (id_ingrediente) REFERENCES ingredientes(id_ingrediente)
);
