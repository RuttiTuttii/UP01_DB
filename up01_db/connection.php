<?php
// храним параметры подключения
const DB_HOST = 'localhost';
const DB_NAME = 'market';
const DB_USER = 'root';
const DB_PASSWORD = 'root';
const DB_CHARSET = 'utf8mb4';

// создаем подключение через mysqli
function getMysqliConnection(): mysqli
{
    mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

    $connection = new mysqli(DB_HOST, DB_USER, DB_PASSWORD, DB_NAME);
    $connection->set_charset(DB_CHARSET);

    return $connection;
}

// создаем подключение через pdo
function getPdoConnection(): PDO
{
    $dsn = 'mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=' . DB_CHARSET;

    return new PDO($dsn, DB_USER, DB_PASSWORD, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]);
}

// экранируем текст перед выводом
function escapeHtml(?string $value): string
{
    return htmlspecialchars($value ?? '', ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

// форматируем цену товара
function formatPrice(float|string $price): string
{
    return number_format((float) $price, 2, ',', ' ') . ' ₽';
}

// выполняем безопасный переход
function redirectTo(string $path): never
{
    header('Location: ' . $path);
    exit;
}
