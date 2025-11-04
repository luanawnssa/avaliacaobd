USE restaurante_bd;

DELIMITER $$
CREATE TRIGGER before_insert_pagamento
BEFORE INSERT ON pagamentos
FOR EACH ROW
BEGIN
    IF NEW.data_pagamento IS NULL THEN
        SET NEW.data_pagamento = NOW();
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER after_insert_pedido
AFTER INSERT ON pedidos
FOR EACH ROW
BEGIN
    UPDATE mesas
    SET status = 'Ocupada'
    WHERE id = NEW.id_mesa;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER after_insert_itens_pedido
AFTER INSERT ON itens_pedido
FOR EACH ROW
BEGIN
    DECLARE v_id_ingrediente INT;
    DECLARE v_qtd INT;
    DECLARE cur CURSOR FOR 
        SELECT id_ingrediente, quantidade 
        FROM produto_ingrediente
        WHERE id_produto = NEW.id_produto;
        
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_id_ingrediente, v_qtd;
        IF done THEN
            LEAVE read_loop;
        END IF;
        UPDATE ingredientes
        SET estoque = estoque - (v_qtd * NEW.quantidade)
        WHERE id = v_id_ingrediente;
    END LOOP;
    CLOSE cur;
END$$
DELIMITER ;
