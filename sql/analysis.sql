-- ============================================================
-- Analytical Queries -- Olist E-Commerce DWH
-- ============================================================

-- 1. Top 10 product categories by revenue
SELECT  p.categorie,
        ROUND(SUM(f.montant_total)::numeric, 2) AS total_revenue,
        COUNT(f.sk_commande)                     AS nb_orders
FROM    fait_ventes f
JOIN    dim_produit p ON f.fk_produit = p.sk_produit
GROUP   BY p.categorie
ORDER   BY total_revenue DESC
LIMIT   10;

-- 2. Monthly revenue trend
SELECT  d.annee,
        d.mois,
        ROUND(SUM(f.montant_total)::numeric, 2) AS revenue,
        COUNT(f.sk_commande)                     AS nb_orders
FROM    fait_ventes f
JOIN    dim_date d ON f.fk_date = d.sk_date
GROUP   BY d.annee, d.mois
ORDER   BY d.annee, d.mois;

-- 3. Top 10 states by number of orders
SELECT  c.ville_etat,
        COUNT(f.sk_commande)                     AS nb_orders,
        ROUND(SUM(f.montant_total)::numeric, 2)  AS total_revenue
FROM    fait_ventes f
JOIN    dim_client c ON f.fk_client = c.sk_client
GROUP   BY c.ville_etat
ORDER   BY nb_orders DESC
LIMIT   10;

-- 4. Average order value by quarter
SELECT  d.annee,
        d.trimestre,
        ROUND(AVG(f.montant_total)::numeric, 2) AS avg_order_value,
        COUNT(f.sk_commande)                     AS nb_orders
FROM    fait_ventes f
JOIN    dim_date d ON f.fk_date = d.sk_date
GROUP   BY d.annee, d.trimestre
ORDER   BY d.annee, d.trimestre;

-- 5. Top 10 sellers by revenue
SELECT  v.seller_id,
        v.ville_etat,
        ROUND(SUM(f.montant_total)::numeric, 2) AS total_revenue,
        COUNT(f.sk_commande)                     AS nb_orders
FROM    fait_ventes f
JOIN    dim_vendeur v ON f.fk_vendeur = v.sk_vendeur
GROUP   BY v.seller_id, v.ville_etat
ORDER   BY total_revenue DESC
LIMIT   10;