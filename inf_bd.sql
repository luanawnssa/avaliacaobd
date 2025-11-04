SHOW tableS;
USE restaurante_bd;

INSERT INTO clientes (nome, telefone) VALUES
('Maria Silva', '99999-0001'),
('João Souza', '99999-0002'),
('Ana Lima', '99999-0003');

INSERT INTO mesas (numero, capacidade, status) VALUES
(1, 4, 'Livre'),
(2, 4, 'Livre'),
(3, 6, 'Livre');

INSERT INTO categorias_produto (nome) VALUES
('Pizza'),
('Bebida'),
('Sobremesa');

INSERT INTO fornecedores (nome, contato) VALUES
('Distribuidora ABC', '(81) 9999-0000'),
('Distribuidora XYZ', '(81) 9888-1111');

INSERT INTO produtos (nome, preco, estoque, id_categoria) VALUES
('Pizza Calabresa', 35.00, 10, 1),
('Pizza Marguerita', 30.00, 8, 1),
('Refrigerante 350ml', 5.00, 50, 2),
('Sorvete Casquinha', 7.00, 20, 3);

INSERT INTO produtos_fornecedores (id_produto, id_fornecedor) VALUES
(1, 1),
(2, 2),
(3, 1),
(4, 2);

INSERT INTO funcionarios (nome, cargo) VALUES
('Carlos Mendes', 'Garçom'),
('Fernanda Rocha', 'Cozinha');

INSERT INTO pedidos (id_cliente, id_mesa, status) VALUES
(1, 1, 'Aberto'),
(2, 2, 'Aberto');

INSERT INTO itens_pedido (id_pedido, id_produto, quantidade, preco_unit) VALUES
(1, 1, 2, 35.00),
(1, 3, 2, 5.00),
(2, 2, 1, 30.00),
(2, 4, 2, 7.00);

INSERT INTO pagamentos (id_pedido, metodo, valor) VALUES
(1, 'Dinheiro', 80.00),
(2, 'Cartão', 44.00);

INSERT INTO historico_pedidos (id_pedido, acao) VALUES
(1, 'Pedido criado'),
(2, 'Pedido criado');

INSERT INTO historico_estoque (id_produto, descricao) VALUES
(1, 'Estoque inicial 10 unidades'),
(2, 'Estoque inicial 8 unidades'),
(3, 'Estoque inicial 50 unidades'),
(4, 'Estoque inicial 20 unidades');
