CREATE TYPE table_location AS ENUM ('indoor', 'outdoor', 'bar', 'private');

CREATE TYPE table_status AS ENUM ('available', 'occupied', 'reserved', 'closed');

CREATE TYPE reservation_status AS ENUM ('pending', 'confirmed', 'seated', 'completed', 'cancelled', 'no-show');

CREATE TYPE order_status AS ENUM ('open', 'in-progress', 'ready', 'served', 'paid', 'cancelled');

CREATE TYPE order_item_status AS ENUM ('pending', 'cooking', 'ready', 'served');

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = ''
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

CREATE TABLE IF NOT EXISTS "menu_categories" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "name" TEXT NOT NULL,
  "description" TEXT,
  "display_order" INTEGER NOT NULL DEFAULT 0,
  "active" BOOLEAN NOT NULL DEFAULT true,
  "created_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
  "updated_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
  "created_by" UUID
);

CREATE TRIGGER trg_menu_categories_updated_at BEFORE UPDATE ON "menu_categories" FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TABLE IF NOT EXISTS "menu_items" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "category_id" UUID NOT NULL,
  "name" TEXT NOT NULL,
  "description" TEXT,
  "price" NUMERIC NOT NULL,
  "dietary_tags" TEXT,
  "available" BOOLEAN NOT NULL DEFAULT true,
  "preparation_time_minutes" INTEGER,
  "image_url" TEXT,
  "calories" INTEGER,
  "created_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
  "updated_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
  "created_by" UUID
);

CREATE TRIGGER trg_menu_items_updated_at BEFORE UPDATE ON "menu_items" FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TABLE IF NOT EXISTS "restaurant_tables" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "table_number" INTEGER NOT NULL,
  "capacity" INTEGER NOT NULL,
  "location" TEXT NOT NULL,
  "status" TEXT NOT NULL DEFAULT 'available',
  "created_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
  "updated_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
  "created_by" UUID
);

CREATE TRIGGER trg_restaurant_tables_updated_at BEFORE UPDATE ON "restaurant_tables" FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TABLE IF NOT EXISTS "reservations" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "guest_name" TEXT NOT NULL,
  "guest_email" TEXT,
  "guest_phone" TEXT,
  "table_id" UUID,
  "party_size" INTEGER NOT NULL,
  "reservation_date" TIMESTAMPTZ NOT NULL,
  "reservation_time" TEXT NOT NULL,
  "status" TEXT NOT NULL DEFAULT 'pending',
  "special_requests" TEXT,
  "created_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
  "updated_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
  "created_by" UUID
);

CREATE TRIGGER trg_reservations_updated_at BEFORE UPDATE ON "reservations" FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TABLE IF NOT EXISTS "orders" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "table_id" UUID NOT NULL,
  "reservation_id" UUID,
  "status" TEXT NOT NULL DEFAULT 'open',
  "total_amount" NUMERIC NOT NULL DEFAULT 0,
  "notes" TEXT,
  "ordered_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
  "created_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
  "updated_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
  "created_by" UUID
);

CREATE TRIGGER trg_orders_updated_at BEFORE UPDATE ON "orders" FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TABLE IF NOT EXISTS "order_items" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "order_id" UUID NOT NULL,
  "menu_item_id" UUID NOT NULL,
  "quantity" INTEGER NOT NULL DEFAULT 1,
  "unit_price" NUMERIC NOT NULL,
  "special_instructions" TEXT,
  "status" TEXT NOT NULL DEFAULT 'pending',
  "created_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
  "updated_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
  "created_by" UUID
);

CREATE TRIGGER trg_order_items_updated_at BEFORE UPDATE ON "order_items" FOR EACH ROW EXECUTE FUNCTION update_updated_at();



-- Stats function for menu_items

CREATE OR REPLACE FUNCTION get_menu_items_stats()
RETURNS TABLE(total_count bigint, avg_price numeric, sum_price numeric)
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT
    count(*)::bigint,
    avg(price)::numeric,
    sum(price)::numeric
  FROM public.menu_items;
$$;



-- Stats function for orders

CREATE OR REPLACE FUNCTION get_orders_stats()
RETURNS TABLE(total_count bigint, avg_total_amount numeric, sum_total_amount numeric)
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT
    count(*)::bigint,
    avg(total_amount)::numeric,
    sum(total_amount)::numeric
  FROM public.orders;
$$;



-- Stats function for order_items

CREATE OR REPLACE FUNCTION get_order_items_stats()
RETURNS TABLE(total_count bigint, avg_quantity numeric, sum_quantity numeric, avg_unit_price numeric, sum_unit_price numeric)
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT
    count(*)::bigint,
    avg(quantity)::numeric,
    sum(quantity)::numeric,
    avg(unit_price)::numeric,
    sum(unit_price)::numeric
  FROM public.order_items;
$$;