-- ============================================================
-- Brazilian E-Commerce Data Warehouse
-- DDL Scripts -- Star Schema (Kimball methodology)
-- Dataset: Olist Brazilian E-Commerce (Kaggle)
-- ============================================================

-- ------------------------------------------------------------
-- STAGING AREA
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS sa_customers (
    customer_id        VARCHAR(50),
    customer_unique_id VARCHAR(50),
    zip_code_prefix    VARCHAR(10),
    city               VARCHAR(100),
    state              VARCHAR(2)
);

CREATE TABLE IF NOT EXISTS sa_products (
    product_id         VARCHAR(50),
    category_name      VARCHAR(100),
    weight_g           DECIMAL(10,2),
    length_cm          DECIMAL(10,2),
    height_cm          DECIMAL(10,2),
    width_cm           DECIMAL(10,2)
);

CREATE TABLE IF NOT EXISTS sa_sellers (
    seller_id          VARCHAR(50),
    zip_code_prefix    VARCHAR(10),
    city               VARCHAR(100),
    state              VARCHAR(2)
);

CREATE TABLE IF NOT EXISTS sa_orders (
    order_id           VARCHAR(50),
    customer_id        VARCHAR(50),
    status             VARCHAR(30),
    purchase_timestamp TIMESTAMP,
    approved_at        TIMESTAMP,
    delivered_at       TIMESTAMP,
    estimated_delivery DATE
);

CREATE TABLE IF NOT EXISTS sa_items (
    order_id           VARCHAR(50),
    order_item_id      INT,
    product_id         VARCHAR(50),
    seller_id          VARCHAR(50),
    price              DECIMAL(10,2),
    freight_value      DECIMAL(10,2)
);

-- ------------------------------------------------------------
-- DATA WAREHOUSE -- DIMENSIONS
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS dim_client (
    sk_client    SERIAL PRIMARY KEY,
    customer_id  VARCHAR(50) NOT NULL UNIQUE,
    ville_etat   VARCHAR(100),
    code_postal  VARCHAR(10),
    region_geo   VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS dim_produit (
    sk_produit   SERIAL PRIMARY KEY,
    product_id   VARCHAR(50) NOT NULL UNIQUE,
    categorie    VARCHAR(100),
    poids        DECIMAL(10,2),
    longueur     DECIMAL(10,2),
    largeur      DECIMAL(10,2),
    hauteur      DECIMAL(10,2)
);

CREATE TABLE IF NOT EXISTS dim_vendeur (
    sk_vendeur   SERIAL PRIMARY KEY,
    seller_id    VARCHAR(50) NOT NULL UNIQUE,
    ville_etat   VARCHAR(100),
    code_postal  VARCHAR(10)
);

CREATE TABLE IF NOT EXISTS dim_date (
    sk_date          SERIAL PRIMARY KEY,
    date_commande    DATE NOT NULL,
    jour             INT,
    mois             INT,
    trimestre        INT,
    annee            INT,
    jour_semaine     INT
);

-- ------------------------------------------------------------
-- DATA WAREHOUSE -- FACT TABLE
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS fait_ventes (
    sk_commande      SERIAL PRIMARY KEY,
    fk_client        INT REFERENCES dim_client(sk_client),
    fk_produit       INT REFERENCES dim_produit(sk_produit),
    fk_vendeur       INT REFERENCES dim_vendeur(sk_vendeur),
    fk_date          INT REFERENCES dim_date(sk_date),
    montant_total    DECIMAL(10,2),
    nb_articles      INT,
    frais_livraison  DECIMAL(10,2)
);

-- ------------------------------------------------------------
-- INDEXES (query performance)
-- ------------------------------------------------------------

CREATE INDEX IF NOT EXISTS idx_fait_client  ON fait_ventes(fk_client);
CREATE INDEX IF NOT EXISTS idx_fait_produit ON fait_ventes(fk_produit);
CREATE INDEX IF NOT EXISTS idx_fait_vendeur ON fait_ventes(fk_vendeur);
CREATE INDEX IF NOT EXISTS idx_fait_date    ON fait_ventes(fk_date);