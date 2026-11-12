from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import psycopg2
import os
from typing import List, Optional

app = FastAPI(title="ПОТОК OMS API")

DB_CONFIG = {
    "host": os.getenv("DB_HOST", "db"),
    "port": os.getenv("DB_PORT", "5432"),
    "dbname": os.getenv("DB_NAME", "potok"),
    "user": os.getenv("DB_USER", "potok_admin"),
    "password": os.getenv("DB_PASSWORD", "potok_secret_2026")
}

def get_db():
    return psycopg2.connect(**DB_CONFIG)

@app.get("/health")
def health():
    try:
        conn = get_db()
        cur = conn.cursor()
        cur.execute("SELECT 1")
        cur.close()
        conn.close()
        return {"status": "ok", "db": "connected"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/orders")
def get_orders():
    conn = get_db()
    cur = conn.cursor()
    cur.execute("""
        SELECT o.id, o.customer, o.phone, o.zone, o.city, o.street, o.house, o.apt,
               o.status, o.priority, o.courier_id, o.slot, o.comment,
               o.created_at, o.eta,
               c.name as courier_name
        FROM orders o
        LEFT JOIN couriers c ON c.id = o.courier_id
        ORDER BY o.seq
    """)
    rows = cur.fetchall()
    orders = []
    for r in rows:
        cur.execute("SELECT name, sku, qty, price FROM order_items WHERE order_id = %s", (r[0],))
        items = cur.fetchall()
        orders.append({
            "id": r[0],
            "customer": r[1],
            "phone": r[2],
            "zone": r[3],
            "city": r[4],
            "street": r[5],
            "house": r[6],
            "apt": r[7],
            "status": r[8],
            "priority": r[9],
            "courierId": r[10],
            "slot": r[11],
            "comment": r[12],
            "createdAt": r[13].isoformat() if r[13] else None,
            "eta": r[14].isoformat() if r[14] else None,
            "courierName": r[15],
            "items": [{"name": i[0], "sku": i[1], "qty": i[2], "price": float(i[3])} for i in items]
        })
    cur.close()
    conn.close()
    return orders

@app.get("/api/couriers")
def get_couriers():
    conn = get_db()
    cur = conn.cursor()
    cur.execute("SELECT id, name, vehicle, zones, capacity, phone, status FROM couriers")
    rows = cur.fetchall()
    couriers = []
    for r in rows:
        couriers.append({
            "id": r[0],
            "name": r[1],
            "vehicle": r[2],
            "zones": r[3],
            "capacity": r[4],
            "phone": r[5],
            "status": r[6]
        })
    cur.close()
    conn.close()
    return couriers

class StatusUpdate(BaseModel):
    status: str

@app.patch("/api/orders/{order_id}/status")
def update_order_status(order_id: str, data: StatusUpdate):
    conn = get_db()
    cur = conn.cursor()
    cur.execute("UPDATE orders SET status = %s WHERE id = %s", (data.status, order_id))
    conn.commit()
    if cur.rowcount == 0:
        cur.close()
        conn.close()
        raise HTTPException(status_code=404, detail="Order not found")
    cur.execute("""
        INSERT INTO status_history (order_id, from_status, to_status, actor)
        SELECT %s, status, %s, 'API' FROM orders WHERE id = %s
    """, (order_id, data.status, order_id))
    conn.commit()
    cur.close()
    conn.close()
    return {"status": "updated", "order_id": order_id, "new_status": data.status}