

from sqlalchemy import (
    create_engine, Column, Integer, String, Float, ForeignKey, DateTime, DECIMAL
)
from sqlalchemy.orm import declarative_base, relationship, sessionmaker
from sqlalchemy.sql import text
import os

# Configuração - altere conforme seu ambiente
DB_USER = os.getenv('DB_USER', 'root')
DB_PASS = os.getenv('DB_PASS', 'senha')
DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_NAME = os.getenv('DB_NAME', 'restaurante')

DATABASE_URL = f'mysql+pymysql://{DB_USER}:{DB_PASS}@{DB_HOST}/{DB_NAME}?charset=utf8mb4'

engine = create_engine(DATABASE_URL, echo=False)
Session = sessionmaker(bind=engine)
Base = declarative_base()

# ===== ORM (apenas classes essenciais para uso no app) =====
class Cliente(Base):
    __tablename__ = 'clientes'
    id = Column(Integer, primary_key=True)
    nome = Column(String(100))

class Mesa(Base):
    __tablename__ = 'mesas'
    id = Column(Integer, primary_key=True)
    numero = Column(Integer)
    status = Column(String(20))

class Produto(Base):
    __tablename__ = 'produtos'
    id = Column(Integer, primary_key=True)
    nome = Column(String(100))
    preco = Column(DECIMAL(10,2))
    estoque = Column(Integer)

class Pedido(Base):
    __tablename__ = 'pedidos'
    id = Column(Integer, primary_key=True)
    id_cliente = Column(Integer, ForeignKey('clientes.id'))
    id_mesa = Column(Integer, ForeignKey('mesas.id'))

class ItemPedido(Base):
    __tablename__ = 'itens_pedido'
    id = Column(Integer, primary_key=True)
    id_pedido = Column(Integer, ForeignKey('pedidos.id'))
    id_produto = Column(Integer, ForeignKey('produtos.id'))
    quantidade = Column(Integer)
    preco_unit = Column(DECIMAL(10,2))

# Funções utilitárias

def criar_tabelas():
    Base.metadata.create_all(engine)


def call_proc_insert_pedido(cliente_id, mesa_id):
    with engine.connect() as conn:
        # chama procedure inserir_pedido e pega novo_id
        res = conn.execute(text("CALL inserir_pedido(:c, :m)"), {'c': cliente_id, 'm': mesa_id})
        row = res.fetchone()
        if row is None:
            raise Exception('Não retornou id do pedido')
        novo_id = row[0]
        return int(novo_id)


def adicionar_item_pedido(pedido_id, produto_id, quantidade, preco_unit=0.0):
    SessionLocal = Session()
    try:
        item = ItemPedido(id_pedido=pedido_id, id_produto=produto_id, quantidade=quantidade, preco_unit=preco_unit)
        SessionLocal.add(item)
        SessionLocal.commit()
    finally:
        SessionLocal.close()


def finalizar_pedido(pedido_id, metodo_pagamento='Dinheiro'):
    # calcula total via procedure
    with engine.connect() as conn:
        res = conn.execute(text("CALL calcular_total_pedido(:p)") , {'p': pedido_id})
        total = res.fetchone()[0]
        # registra pagamento
        conn.execute(text("INSERT INTO pagamentos (id_pedido, metodo, valor) VALUES (:p, :m, :v)"),
                     {'p': pedido_id, 'm': metodo_pagamento, 'v': total})
        # atualiza status do pedido
        conn.execute(text("UPDATE pedidos SET status = 'Fechado' WHERE id = :p"), {'p': pedido_id})
    return float(total)


def criar_pedido_com_itens(cliente_id, mesa_id, itens):
    """itens: lista de dicts: [{'produto_id':1,'quantidade':2,'preco_unit':35.0}, ...]
    Essa função: chama inserir_pedido, adiciona itens, e (a trigger/proc atualizar_estoque) cuidará do estoque.
    """
    novo_id = call_proc_insert_pedido(cliente_id, mesa_id)
    # Inserir itens (preco_unit opcional)
    for it in itens:
        p_id = it['produto_id']
        qtd = it['quantidade']
        preco_unit = it.get('preco_unit', 0.0)
        adicionar_item_pedido(novo_id, p_id, qtd, preco_unit)
    return novo_id


def listar_pedidos_do_cliente(cliente_id):
    with engine.connect() as conn:
        res = conn.execute(text("CALL listar_pedidos_cliente(:c)"), {'c': cliente_id})
        return [dict(row) for row in res]


if __name__ == '__main__':
    print('Rodando etapas de setup e teste...')
    # criar_tabelas()  # caso precise criar via SQLAlchemy

    # Exemplo de uso (ajuste IDs conforme seu banco)
    cliente_teste = 1
    mesa_teste = 1

    print('Criando pedido de exemplo...')
    pedido_id = criar_pedido_com_itens(cliente_teste, mesa_teste, [
        {'produto_id': 1, 'quantidade': 2, 'preco_unit': 35.0},
    ])
    print('Pedido criado com id:', pedido_id)

    print('Finalizando pedido e calculando total...')
    total = finalizar_pedido(pedido_id, metodo_pagamento='Cartão')
    print('Total cobrado:', total)

    print('Listando pedidos do cliente...')
    pedidos = listar_pedidos_do_cliente(cliente_teste)
    for p in pedidos:
        print(p)

    print('Pronto! Verifique logs no banco e tabelas historico_pedidos/historico_estoque.')

