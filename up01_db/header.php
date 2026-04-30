<?php
require_once __DIR__ . '/connection.php';

// подготавливаем значения страницы
$pageTitle = $pageTitle ?? 'market games';
$currentCategory = isset($_GET['category']) ? trim((string) $_GET['category']) : '';
$categories = [];

// загружаем категории для меню
try {
    $pdoForHeader = getPdoConnection();
    $categoryQuery = $pdoForHeader->query('SELECT DISTINCT category FROM games ORDER BY category');
    $categories = $categoryQuery->fetchAll(PDO::FETCH_COLUMN);
} catch (Throwable $error) {
    $categories = [];
}
?>
<!doctype html>
<html lang="ru">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><?= escapeHtml($pageTitle) ?></title>
    <link rel="stylesheet" href="assets/styles.css">
</head>
<body>
<header class="site-header">
    <a class="logo" href="index.html">market games</a>
    <nav class="nav" aria-label="категории">
        <a class="nav__link <?= $currentCategory === '' ? 'is-active' : '' ?>" href="index.php">все</a>
        <?php foreach ($categories as $category): ?>
            <?php if ($category === $currentCategory): ?>
                <span class="nav__link is-active"><?= escapeHtml($category) ?></span>
            <?php else: ?>
                <a class="nav__link" href="index.php?category=<?= urlencode($category) ?>"><?= escapeHtml($category) ?></a>
            <?php endif; ?>
        <?php endforeach; ?>
    </nav>
</header>
