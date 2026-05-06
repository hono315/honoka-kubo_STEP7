-- usersテーブル作成
CREATE TABLE users(
    id INT PRIMARY KEY,
    name VARCHAR(50),
    age INT,
    gender VARCHAR(10),
    created_at DATE
);

-- productsテーブル作成
CREATE TABLE products(
    id INT PRIMARY KEY,
    product_name VARCHAR(100),
    price INT
);

-- ordersテーブル作成
CREATE TABLE orders(
    id INT PRIMARY KEY,
    user_id INT,
    order_date DATE,
    FOREIGN KEY(user_id) REFERENCES users(id)
);

-- order_itemsテーブル作成
CREATE TABLE order_items (
    id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- usersデータ追加
INSERT INTO users (id, name, age, gender, created_at) VALUES
(1, '山田太郎', 28, 'male', '2024-01-10'),
(2, '佐藤花子', 35, 'female', '2024-03-15'),
(3, '鈴木次郎', 42, 'male', '2023-08-20'),
(4, '田中美咲', 23, 'female', '2022-11-05'),
(5, '高橋健一', 30, 'male', '2024-06-01');

-- productsデータ追加
INSERT INTO products (id, product_name, price) VALUES
(1, 'テレビ', 50000),
(2, '冷蔵庫', 70000),
(3, '電子レンジ', 15000),
(4, '掃除機', 20000),
(5, '炊飯器', 18000);

-- ordersデータ追加
INSERT INTO orders (id, user_id, order_date) VALUES
(1, 1, '2024-05-01'),
(2, 1, '2024-05-15'),
(3, 2, '2024-06-01'),
(4, 3, '2024-05-20'),
(5, 4, '2024-06-03'),
(6, 5, '2024-06-05');

-- order_itemsデータ追加
INSERT INTO order_items (id, order_id, product_id, quantity) VALUES
(1, 1, 1, 1),
(2, 1, 3, 2),
(3, 2, 2, 1),
(4, 3, 5, 1),
(5, 4, 4, 1),
(6, 4, 3, 1),
(7, 5, 2, 1),
(8, 6, 1, 1),
(9, 6, 5, 2);

-- 全ユーザー取得
SELECT * FROM users;

-- 2024年のユーザー取得
SELECT * FROM users
WHERE created_at BETWEEN '2024-01-01' AND '2024-12-31';

-- 商品名と価格取得
SELECT product_name, price FROM products;

-- ユーザー名と注文日取得
SELECT users.name, orders.order_date
FROM orders
JOIN users
ON orders.user_id = users.id;

-- 商品名・数量・単価・金額取得
SELECT
    products.product_name,
    order_items.quantity,
    products.price,
    products.price * order_items.quantity AS total_price
FROM order_items
JOIN products
ON order_items.product_id = products.id;

-- ユーザーごとの注文件数
SELECT
    users.name,
    COUNT(orders.id) AS order_count
FROM users
JOIN orders
ON users.id = orders.user_id
GROUP BY users.name;

-- 各ユーザーの総購入金額
SELECT
    users.name,
    SUM(products.price * order_items.quantity) AS total_amount
FROM users
JOIN orders
ON users.id = orders.user_id
JOIN order_items
ON orders.id = order_items.order_id
JOIN products
ON order_items.product_id = products.id
GROUP BY users.name;

-- 最も注文金額が高いユーザー
SELECT
    users.name,
    SUM(products.price * order_items.quantity) AS total_amount
FROM users
JOIN orders
ON users.id = orders.user_id
JOIN order_items
ON orders.id = order_items.order_id
JOIN products
ON order_items.product_id = products.id
GROUP BY users.name
ORDER BY total_amount DESC
LIMIT 1;

-- 各商品が何回注文されたか
SELECT
    products.product_name,
    SUM(order_items.quantity) AS total_quantity
FROM products
JOIN order_items
ON products.id = order_items.product_id
GROUP BY products.product_name;

-- 注文が1回もないユーザー
SELECT users.*
FROM users
LEFT JOIN orders
ON users.id = orders.user_id
WHERE orders.id IS NULL;

-- 1回の注文で2種類以上の商品を購入した注文ID
SELECT order_id
FROM order_items
GROUP BY order_id
HAVING COUNT(product_id) >= 2;

-- 「テレビ」を注文したユーザー名
SELECT DISTINCT users.name
FROM users
JOIN orders
ON users.id = orders.user_id
JOIN order_items
ON orders.id = order_items.order_id
JOIN products
ON order_items.product_id = products.id
WHERE products.product_name = 'テレビ';

-- 明細ごとの注文日・ユーザー名・商品名・数量・合計金額
SELECT
    orders.order_date,
    users.name,
    products.product_name,
    order_items.quantity,
    products.price * order_items.quantity AS total_price
FROM order_items
JOIN orders
ON order_items.order_id = orders.id
JOIN users
ON orders.user_id = users.id
JOIN products
ON order_items.product_id = products.id;

-- 最も多く購入された商品名
SELECT
    products.product_name,
    SUM(order_items.quantity) AS total_quantity
FROM products
JOIN order_items
ON products.id = order_items.product_id
GROUP BY products.product_name
ORDER BY total_quantity DESC
LIMIT 1;

-- 各月の注文件数
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS order_month,
    COUNT(*) AS order_count
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m');

-- 注文のない商品
SELECT products.*
FROM products
LEFT JOIN order_items
ON products.id = order_items.product_id
WHERE order_items.id IS NULL;

-- インデックス追加
CREATE INDEX idx_order_items_product_id
ON order_items(product_id);

-- ユーザーごとの平均注文金額
SELECT
    users.name,
    AVG(order_total.total_amount) AS average_order_amount
FROM users
JOIN orders
ON users.id = orders.user_id
JOIN (
    SELECT
        order_items.order_id,
        SUM(products.price * order_items.quantity) AS total_amount
    FROM order_items
    JOIN products
    ON order_items.product_id = products.id
    GROUP BY order_items.order_id
) AS order_total
ON orders.id = order_total.order_id
GROUP BY users.name;

-- 各ユーザーの最新注文日
SELECT
    users.name,
    MAX(orders.order_date) AS latest_order_date
FROM users
JOIN orders
ON users.id = orders.user_id
GROUP BY users.name;

-- 新規ユーザー追加
INSERT INTO users (id, name, age, gender, created_at)
VALUES (6, '中村愛', 25, 'female', '2025-06-01');

-- 商品追加
INSERT INTO products (id, product_name, price)
VALUES (6, 'エアコン', 60000);

-- 新しい注文追加
INSERT INTO orders (id, user_id, order_date)
VALUES (10, 1, '2025-06-10');

-- 注文明細追加
INSERT INTO order_items (id, order_id, product_id, quantity)
VALUES (10, 10, 6, 1);

-- 年齢更新
UPDATE users
SET age = 24
WHERE name = '田中美咲';

-- 全商品の価格を10%値上げ
UPDATE products
SET price = price * 1.1;

-- 2024年5月以前の注文日を統一
UPDATE orders
SET order_date = '2024-05-01'
WHERE order_date < '2024-05-01';

-- 高橋健一を削除
UPDATE orders
SET user_id = NULL
WHERE user_id = (
    SELECT id
    FROM users
    WHERE name = '高橋健一'
);

DELETE FROM users
WHERE name = '高橋健一';

-- 注文ID5の明細削除
DELETE FROM order_items
WHERE order_id = 5;

-- 一度も注文されていない商品を削除
DELETE FROM products
WHERE id NOT IN (
    SELECT product_id
    FROM order_items
);