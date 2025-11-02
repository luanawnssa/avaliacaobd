USE restaurante_bd;
DELIMITER //

CREATE TRIGGER trg_data_pagamento
BEFORE INSERT ON pagamentos
FOR EACH ROW
BEGIN
    SET NEW.data_pagamento = NOW();
END //

CREATE TRIGGER trg_mesa_ocupada
AFTER INSERT ON pedidos
FOR EACH ROW
BEGIN
    UPDATE mesas SET status_mesa = 'Ocupada' WHERE id_mesa = NEW.id_mesa;
END //

CREATE TRIGGER trg_atualiza_estoque
AFTER INSERT ON itens_pedido
FOR EACH ROW
BEGIN
    UPDATE ingredientes i
    JOIN produto_ingrediente pi ON pi.id_ingrediente = i.id_ingrediente
    SET i.estoque = i.estoque - (pi.quantidade_usada * NEW.quantidade)
    WHERE pi.id_produto = NEW.id_produto;
END //
DELIMITER ;
