CREATE TRIGGER trg_pedido_inserido
AFTER INSERT ON pedidos
FOR EACH ROW
INSERT INTO historico_pedidos (id_pedido, acao, data_hora)
VALUES (NEW.id, 'Pedido Inserido', NOW());

CREATE TRIGGER trg_pedido_atualizado
AFTER UPDATE ON pedidos
FOR EACH ROW
INSERT INTO historico_pedidos (id_pedido, acao, data_hora)
VALUES (NEW.id, 'Pedido Atualizado', NOW());

CREATE TRIGGER trg_pedido_deletado
AFTER DELETE ON pedidos
FOR EACH ROW
INSERT INTO historico_pedidos (id_pedido, acao, data_hora)
VALUES (OLD.id, 'Pedido Deletado', NOW());
