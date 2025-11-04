DROP TABLE IF EXISTS historico_pedidos;

CREATE TABLE historico_pedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT,
    acao VARCHAR(50),
    data_hora DATETIME
);
