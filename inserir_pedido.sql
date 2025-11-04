DELIMITER //
CREATE PROCEDURE inserir_pedido(IN cliente_id INT, IN mesa_id INT, OUT novo_id INT)
BEGIN
    INSERT INTO pedidos (id_cliente, id_mesa) VALUES (cliente_id, mesa_id);
    SET novo_id = LAST_INSERT_ID();
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE atualizar_estoque(IN produto_id INT, IN qtd_vendida INT)
BEGIN
    UPDATE produtos SET estoque = estoque - qtd_vendida WHERE id = produto_id;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE calcular_total_pedido(IN pedido_id INT, OUT total DECIMAL(10,2))
BEGIN
    SELECT SUM(p.quantidade * pr.preco)
    INTO total
    FROM itens_pedido p
    JOIN produtos pr ON p.id_produto = pr.id
    WHERE p.id_pedido = pedido_id;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE listar_pedidos_cliente(IN cliente INT)
BEGIN
    SELECT p.id, m.numero AS mesa, p.id_cliente
    FROM pedidos p
    JOIN mesas m ON p.id_mesa = m.id
    WHERE p.id_cliente = cliente;
END //
DELIMITER ;
