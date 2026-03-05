SELECT orders_products.order_id AS 'Номер заказа',
	client_name AS 'Наименование клиента',
	product_name AS 'Наименование продукции',
	date_order AS 'Дата заказа',
	amount AS Количество,
	ROUND(IF(delivery.delivery_type REGEXP 'Самовивоз', price_per_kg, price_per_kg * 1.1), 2) AS 'Цена заказа',
	ROUND(IF(delivery.delivery_type REGEXP 'Самовивоз', price_per_kg, price_per_kg * 1.1) * amount, 2) AS Стоимость
FROM clients JOIN orders USING (client_id)
	JOIN delivery USING (delivery_id)
	JOIN orders_products USING (order_id)
	JOIN products USING (product_id)
WHERE client_name IN ('Ресторан "Дубки"', 'Кафе "Світлана"') AND amount <= 10;



SELECT client_name AS 'Наименование клиента',
	product_name AS 'Наименование продукции',
	delivery_type AS 'Тип доставки',
	date_order AS 'Дата заказа',
	date_payment AS 'Дата оплаты',
	amount AS Количество,
	ROUND(IF(delivery.delivery_type REGEXP 'Самовивоз', price_per_kg, price_per_kg * 1.1) * amount, 2) AS Стоимость
FROM clients JOIN orders USING (client_id)
	JOIN delivery USING (delivery_id)
	JOIN orders_products USING (order_id)
	JOIN products USING (product_id)
WHERE MONTH(date_order) BETWEEN 7 AND 9;



SELECT client_name AS 'Наименование клиента',
	product_name AS 'Наименование продукции',
	ROUND(IF(delivery.delivery_type REGEXP 'Самовивоз', price_per_kg, price_per_kg * 1.1), 2) AS 'Цена заказа',
	amount AS Количество,
	date_order AS 'Дата заказа'
FROM clients JOIN orders USING (client_id)
	JOIN delivery USING (delivery_id)
	JOIN orders_products USING (order_id)
	JOIN products USING (product_id)
ORDER BY Количество DESC
LIMIT 4;



SELECT client_name AS 'Наименование торговой марки',
	product_name AS 'Наименование продукции',
	ROUND(IF(delivery.delivery_type REGEXP 'Самовивоз', price_per_kg, price_per_kg * 1.1) * amount, 2) AS Стоимость,
	date_order AS 'Дата реализации',
	date_payment AS 'Дата оплаты'
FROM clients JOIN orders USING (client_id)
	JOIN delivery USING (delivery_id)
	JOIN orders_products USING (order_id)
	JOIN products USING (product_id)
WHERE (NULLIF(:start_date, '0') IS NULL OR date_order >= :start_date)
	AND (NULLIF(:end_date, '0') IS NULL OR date_order <= :end_date)
	AND date_payment IS NOT NULL
	AND product_name REGEXP '^Ш';



SELECT product_id AS 'Код продукции', product_name AS 'Наименование продукции', amount AS 'Код продукции'
FROM products p JOIN orders_products USING (product_id)
WHERE product_name = :search_product AND amount > (
	SELECT AVG(amount) AS amount FROM orders_products orders_log
	WHERE orders_log.product_id = p.product_id
);



WITH latest_date AS (
	SELECT date_order FROM orders
	ORDER BY 1 DESC
	LIMIT 1
)

SELECT client_name AS 'Наименование клиента',
	products.product_name AS 'Наименование продукции',
	amount AS Количество,
	date_order AS 'Дата заказа',
	date_payment AS 'Дата оплаты'
FROM clients JOIN orders USING (client_id)
	JOIN delivery USING (delivery_id)
	JOIN orders_products USING (order_id)
	JOIN products USING (product_id)
WHERE DATEDIFF((SELECT * FROM latest_date), date_order) <= :days;

-- Task 3.1
SELECT product_name AS 'Наименование продукции',
	ROUND(IF(client_name = 'Ресторан "Дубки"', SUM(price_per_kg * amount), 0), 2) AS 'Ресторан "Дубки"',
	ROUND(IF(client_name = 'Їдальня №2', SUM(price_per_kg * amount), 0), 2) AS 'Їдальня №2',
	ROUND(IF(client_name = 'Кафе "Світлана"', SUM(price_per_kg * amount), 0), 2) AS 'Кафе "Світлана"',
	ROUND(IF(client_name = 'Кафе "Вікторія"Ресторан "Сатурн"', SUM(price_per_kg * amount), 0), 2) AS 'Кафе "Вікторія"',
	ROUND(IF(client_name = 'Ресторан "Дубки"', SUM(price_per_kg * amount), 0), 2) AS 'Ресторан "Сатурн"'
FROM clients
	JOIN orders USING (client_id)
	JOIN orders_products USING (order_id)
	JOIN products USING (product_id)
GROUP BY orders_products.product_id;

-- Task 3.2
WITH ordered AS (
    SELECT DISTINCT product_id
    FROM orders JOIN orders_products USING (order_id)
    WHERE date_order >= :from_date AND date_order <= :to_date
)

SELECT product_name AS 'Наименование продукции', price_per_kg AS 'Цена' FROM products
WHERE product_id NOT IN ( SELECT * FROM ordered);

-- Task 4.1
START TRANSACTION;

INSERT INTO orders (order_id, client_id, date_order, date_payment, delivery_id)
VALUES (11, 55, '2026-01-14', '2026-01-15', 2);

INSERT INTO orders_products (order_id, product_id, amount)
VALUES (11, 110100, 3);

COMMIT;

-- Task 4.2
START TRANSACTION;

DELETE FROM orders_products
WHERE order_id = 11;

DELETE FROM orders
WHERE order_id = 11;

COMMIT;

-- Task 4.3
START TRANSACTION;

SELECT COUNT(*) FROM orders_products
WHERE order_id = 1;

DELETE FROM orders_products
WHERE order_id = 1;

SELECT COUNT(*) FROM orders_products
WHERE order_id = 1;

ROLLBACK;

-- Task 4.4
START TRANSACTION;

SELECT * FROM products;

UPDATE products
SET price_per_kg = price_per_kg * 1.50;
SELECT * FROM products;

ROLLBACK;