from sqlalchemy import create_engine, text

engine = create_engine("mysql+pymysql://root:12457836@localhost:3306/restaurante_bd")

with engine.connect() as conn:
    result = conn.execute(text("CALL inserir_pedido(1, 1, @id_pedido)"))
    conn.execute(text("SELECT @id_pedido"))
    print("✅ Procedure chamada com sucesso!")
