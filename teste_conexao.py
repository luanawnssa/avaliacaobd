from sqlalchemy import create_engine

engine = create_engine("mysql+pymysql://root:12457836@localhost:3306/restaurante_bd")

try:
    with engine.connect() as connection:
        print("✅ Conexão bem-sucedida com o banco de dados!")
except Exception as e:
    print("❌ Erro ao conectar:", e)
