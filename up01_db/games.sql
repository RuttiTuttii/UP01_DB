CREATE DATABASE IF NOT EXISTS market CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE market;

DROP TABLE IF EXISTS cart;
DROP TABLE IF EXISTS photos;
DROP TABLE IF EXISTS games;

CREATE TABLE games (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(80) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    logo VARCHAR(255) NULL
);

CREATE TABLE photos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    game_id INT NOT NULL,
    path VARCHAR(255) NOT NULL,
    CONSTRAINT fk_photos_games FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE
);

CREATE TABLE cart (
    id INT AUTO_INCREMENT PRIMARY KEY,
    game_id INT NOT NULL UNIQUE,
    added_at DATETIME NOT NULL,
    CONSTRAINT fk_cart_games FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE
);

INSERT INTO games (name, description, category, price, logo) VALUES
('hollow knight', 'атмосферная метроидвания с исследованием мира, боссами и ручной рисовкой.', 'metroidvania', 499.00, 'assets/images/default-logo.svg'),
('stardew valley', 'спокойная ферма с крафтом, отношениями с жителями и развитием участка.', 'simulation', 349.00, 'assets/images/default-logo.svg'),
('celeste', 'точный платформер про восхождение на гору и преодоление себя.', 'platformer', 399.00, 'assets/images/default-logo.svg'),
('disco elysium', 'ролевая игра с глубокими диалогами, расследованием и необычной системой навыков.', 'rpg', 699.00, 'assets/images/default-logo.svg'),
('dead cells', 'динамичный roguelite с быстрыми боями, прокачкой и процедурными уровнями.', 'roguelite', 549.00, 'assets/images/default-logo.svg'),
('outer wilds', 'исследовательское приключение про космос, тайны древней цивилизации и цикл времени.', 'adventure', 799.00, 'assets/images/default-logo.svg'),
('hades', 'экшен roguelite с мифологией, яркими персонажами и постоянным прогрессом.', 'roguelite', 649.00, 'assets/images/default-logo.svg'),
('terraria', 'песочница с добычей ресурсов, строительством, боями и большим количеством предметов.', 'sandbox', 299.00, 'assets/images/default-logo.svg');

INSERT INTO photos (game_id, path) VALUES
(1, 'assets/images/default-shot.svg'),
(1, 'assets/images/default-shot.svg'),
(2, 'assets/images/default-shot.svg'),
(3, 'assets/images/default-shot.svg'),
(4, 'assets/images/default-shot.svg'),
(5, 'assets/images/default-shot.svg'),
(6, 'assets/images/default-shot.svg'),
(7, 'assets/images/default-shot.svg'),
(8, 'assets/images/default-shot.svg');
