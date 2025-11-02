USE restaurante_bd;
DELIMITER //

CREATE PROCEDURE InserirPedido(IN cliente INT, IN funcionario INT, IN mesa INT)
BEGIN
    INSERT INTO pedidos (id_cliente, id_funcionario, id_mesa)
    VALUES (cliente, funcionario, mesa);
END //

CREATE PROCEDURE TotalPedido(IN pedido INT)
BEGIN
    SELECT SUM(p.preco * i.quantidade) AS total
    FROM itens_pedido i
    JOIN produtos p ON p.id_produto = i.id_produto
    WHERE i.id_pedido = pedido;
END //

CREATE PROCEDURE AtualizarStatusMesa(IN mesa_id INT, IN novo_status VARCHAR(20))
BEGIN
    UPDATE mesas SET status_mesa = novo_status WHERE id_mesa = mesa_id;
END //

CREATE PROCEDURE PedidosPorCliente(IN cliente_id INT)
BEGIN
    SELECT p.id_pedido, p.data_pedido, p.status_pedido
    FROM pedidos p
    WHERE p.id_cliente = cliente_id;
END //
DELIMITER ;
