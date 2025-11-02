from bd import get_connection
from sqlalchemy import text

try:
    with get_connection() as conn:
        conn.execute(text("INSERT INTO pedidos (id_cliente, id_mesa) VALUES (1, 1)"))
        conn.commit()
        print("✅ Trigger de INSERT testada (pedido inserido).")


        conn.execute(text("UPDATE pedidos SET id_mesa = 2 WHERE id = 1"))
        conn.commit()
        print("✅ Trigger de UPDATE testada (pedido atualizado).")


        conn.execute(text("DELETE FROM pedidos WHERE id = 1"))
        conn.commit()
        print("✅ Trigger de DELETE testada (pedido deletado).")

        result = conn.execute(text("SELECT * FROM historico_pedidos"))
        for row in result:
            print(row)

except Exception as e:
    print("❌ Erro ao testar triggers:", e)
