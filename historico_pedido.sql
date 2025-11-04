USE restaurante_bd;

DROP TABLE IF EXISTS historico_pedidos;

CREATE TABLE historico_pedidos (
    id_historico INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    acao VARCHAR(100),
    observacao VARCHAR(255) NULL
);
