from sqlalchemy import create_engine, text

engine = create_engine("mysql+pymysql://root:12457836@localhost:3306/restaurante_bd")

with engine.connect() as conn:
    conn.execute(text("INSERT INTO clientes (nome, telefone) VALUES ('Alice', '11999999999')"))
    
    conn.execute(text("INSERT INTO mesas (numero, status) VALUES (1, 'Disponível')"))
    
    conn.execute(text("INSERT INTO produtos (nome, preco) VALUES ('Pizza', 35.00)"))

    print("✅ Dados básicos inseridos com sucesso!")
