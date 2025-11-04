USE restaurante_bd;

DELIMITER $$
CREATE PROCEDURE inserir_pedido(
    IN p_id_cliente INT,
    IN p_id_mesa INT,
    OUT p_id_pedido INT
)
BEGIN
    INSERT INTO pedidos (id_cliente, id_mesa, status)
    VALUES (p_id_cliente, p_id_mesa, 'Aberto');
    
    SET p_id_pedido = LAST_INSERT_ID();
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE calcular_total_pedido(IN p_id_pedido INT, OUT p_total DECIMAL(10,2))
BEGIN
    SELECT SUM(produtos.preco * itens_pedido.quantidade)
    INTO p_total
    FROM itens_pedido
    JOIN produtos ON produtos.id = itens_pedido.id_produto
    WHERE itens_pedido.id_pedido = p_id_pedido;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE atualizar_status_mesa(IN p_id_mesa INT, IN p_status VARCHAR(20))
BEGIN
    UPDATE mesas
    SET status = p_status
    WHERE id = p_id_mesa;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE listar_pedidos_cliente(IN p_id_cliente INT)
BEGIN
    SELECT * FROM pedidos
    WHERE id_cliente = p_id_cliente;
END$$
DELIMITER ;
