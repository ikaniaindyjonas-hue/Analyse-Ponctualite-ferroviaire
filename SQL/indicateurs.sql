

-- VUE D'ENSEMBLE

select * from TrainRides_clean limit 5;

SELECT COUNT(*) AS nb_billets
FROM TrainRides_clean;

SELECT SUM(price) AS revenu_total_gbp
FROM TrainRides_clean;



-- Q1 — PONCTUALITÉ

-- 3. Taux de ponctualité (%)
SELECT ROUND(100.0 * SUM(journey_status = 'On Time') / COUNT(*), 2) AS taux_ponctualite_pct
FROM TrainRides_clean;


-- 4. Taux de retard (%)
SELECT ROUND(100.0 * SUM(journey_status = 'Delayed') / COUNT(*), 2) AS taux_retard_pct
FROM TrainRides_clean;


-- 5. Taux d'annulation (%)
SELECT ROUND(100.0 * SUM(journey_status = 'Cancelled') / COUNT(*), 2) AS taux_annulation_pct
FROM TrainRides_clean;


-- 6. Retard moyen (minutes)

SELECT ROUND(AVG(delay_minutes), 1) AS retard_moyen_min
FROM TrainRides_clean
WHERE journey_status = 'Delayed';


-- 6 . Ponctualité par mois
SELECT journey_month,
       COUNT(*) AS nb_billets,
       ROUND(100.0 * SUM(journey_status = 'On Time')   / COUNT(*), 2) AS ponctualite_pct,
       ROUND(100.0 * SUM(journey_status = 'Delayed')   / COUNT(*), 2) AS retard_pct,
       ROUND(100.0 * SUM(journey_status = 'Cancelled') / COUNT(*), 2) AS annulation_pct
FROM TrainRides_clean
GROUP BY journey_month
ORDER BY journey_month;





-- Q2 — CAUSES

-- 7. Répartition des causes (%) — retards ET annulations
SELECT delay_reason,
       COUNT(*) AS nb_billets,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS part_pct
FROM TrainRides_clean
WHERE journey_status IN ('Delayed', 'Cancelled')
GROUP BY delay_reason
ORDER BY nb_billets DESC;


-- Q3 — TRAJETS


-- 8. Revenu par trajet (£)
SELECT route,
       COUNT(*)   AS nb_billets,
       SUM(price) AS revenu_gbp,
       ROUND(100.0 * SUM(price) / (SELECT SUM(price) FROM TrainRides_clean), 2) AS part_revenu_pct
FROM TrainRides_clean
GROUP BY route
ORDER BY revenu_gbp DESC;


-- 9. Taux de retard par trajet (%)

SELECT route,
       COUNT(*) AS nb_billets,
       SUM(journey_status = 'Delayed') AS nb_retards,
       ROUND(100.0 * SUM(journey_status = 'Delayed') / COUNT(*), 2) AS taux_retard_pct,
       ROUND(100.0 * SUM(journey_status = 'Cancelled') / COUNT(*), 2) AS taux_annulation_pct
FROM TrainRides_clean
GROUP BY route
HAVING COUNT(*) >= 30
ORDER BY taux_retard_pct DESC;


-- Q4 — REMBOURSEMENTS


-- 10. Taux de demande de remboursement (%) = demandes / billets retardés ou annulés
SELECT SUM(refund_request = 'Yes') AS nb_demandes,
       COUNT(*)                    AS nb_retards_annulations,
       ROUND(100.0 * SUM(refund_request = 'Yes') / COUNT(*), 2) AS taux_demande_pct
FROM TrainRides_clean
WHERE journey_status IN ('Delayed', 'Cancelled');


-- 11. Montant exposé aux remboursements (£)
--     ESTIMATION HAUTE : le fichier indique la demande, pas le montant réellement remboursé.
SELECT SUM(price) AS montant_expose_gbp,
       ROUND(100.0 * SUM(price) / (SELECT SUM(price) FROM TrainRides_clean), 2) AS part_du_revenu_pct
FROM TrainRides_clean
WHERE refund_request = 'Yes';


-- 11 bis. Montant exposé selon le statut (retard vs annulation)
SELECT journey_status,
       COUNT(*)   AS nb_demandes,
       SUM(price) AS montant_expose_gbp
FROM TrainRides_clean
WHERE refund_request = 'Yes'
GROUP BY journey_status;
