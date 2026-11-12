CREATE TABLE IF NOT EXISTS couriers (
    id        TEXT PRIMARY KEY,
    name      TEXT NOT NULL,
    vehicle   TEXT NOT NULL,
    zones     TEXT[] NOT NULL DEFAULT '{}',
    capacity  INTEGER NOT NULL DEFAULT 8,
    phone     TEXT,
    status    TEXT NOT NULL DEFAULT 'free'
);

CREATE TABLE IF NOT EXISTS orders (
    id          TEXT PRIMARY KEY,
    seq         INTEGER,
    customer    TEXT NOT NULL,
    phone       TEXT,
    city        TEXT NOT NULL DEFAULT 'Москва',
    street      TEXT,
    house       TEXT,
    apt         TEXT,
    zone        TEXT NOT NULL,
    status      TEXT NOT NULL,
    priority    TEXT NOT NULL DEFAULT 'normal',
    courier_id  TEXT REFERENCES couriers(id) ON DELETE SET NULL,
    slot        TEXT,
    comment     TEXT DEFAULT '',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    eta         TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS order_items (
    id        SERIAL PRIMARY KEY,
    order_id  TEXT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    name      TEXT NOT NULL,
    sku       TEXT NOT NULL,
    qty       INTEGER NOT NULL DEFAULT 1,
    price     NUMERIC(12,2) NOT NULL DEFAULT 0,
    UNIQUE (order_id, sku)
);

CREATE TABLE IF NOT EXISTS status_history (
    id           SERIAL PRIMARY KEY,
    order_id     TEXT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    changed_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    from_status  TEXT,
    to_status    TEXT NOT NULL,
    actor        TEXT
);

CREATE TABLE IF NOT EXISTS app_state (
    key    TEXT PRIMARY KEY,
    value  JSONB NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_orders_status  ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_courier ON orders(courier_id);
CREATE INDEX IF NOT EXISTS idx_items_order    ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_history_order  ON status_history(order_id);