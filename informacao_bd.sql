INSERT INTO clientes (nome, telefone) VALUES ('ClienteTeste', '11999999999');

INSERT INTO mesas (numero, capacidade, status) VALUES (1, 4, 'Disponível');

INSERT INTO produtos (nome, preco, estoque) VALUES ('ProdutoTeste', 10, 50);

INSERT INTO pedidos (id_cliente, id_mesa) VALUES (1, 1);

INSERT INTO itens_pedido (id_pedido, id_produto, quantidade) VALUES (1, 1, 5);
