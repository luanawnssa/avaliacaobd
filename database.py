from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

engine = create_engine("mysql+pymysql://root:12457836@localhost:3306/restaurante_bd")


Session = sessionmaker(bind=engine)
session = Session()

Base = declarative_base()
