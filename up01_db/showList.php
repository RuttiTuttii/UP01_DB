<?php
require_once __DIR__ . '/connection.php';

// задаем параметры вывода
$limit = 3;
$page = max(1, (int) ($_GET['page'] ?? 1));
$category = trim((string) ($_GET['category'] ?? ''));
$offset = ($page - 1) * $limit;

// открываем подключение
$mysqli = getMysqliConnection();

// загружаем список категорий
$categoryResult = $mysqli->query('SELECT DISTINCT category FROM games ORDER BY category');
$categories = $categoryResult->fetch_all(MYSQLI_ASSOC);

// собираем условие категории
$where = '';
$countParams = [];
$countTypes = '';

if ($category !== '') {
    $where = 'WHERE category = ?';
    $countParams[] = $category;
    $countTypes .= 's';
}

// считаем количество товаров
$countStatement = $mysqli->prepare("SELECT COUNT(*) AS total FROM games $where");

if ($countTypes !== '') {
    $countStatement->bind_param($countTypes, ...$countParams);
}

$countStatement->execute();
$totalItems = (int) $countStatement->get_result()->fetch_assoc()['total'];
$totalPages = max(1, (int) ceil($totalItems / $limit));
$page = min($page, $totalPages);
$offset = ($page - 1) * $limit;

// получаем товары для текущей страницы
$itemsSql = "SELECT id, name, description, price, category FROM games $where ORDER BY name LIMIT ?, ?";
$itemsStatement = $mysqli->prepare($itemsSql);

if ($countTypes !== '') {
    $itemsStatement->bind_param($countTypes . 'ii', $category, $offset, $limit);
} else {
    $itemsStatement->bind_param('ii', $offset, $limit);
}

$itemsStatement->execute();
$games = $itemsStatement->get_result()->fetch_all(MYSQLI_ASSOC);

// закрываем подключение
$mysqli->close();
?>
<!doctype html>
<html lang="ru">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>список товаров</title>
    <link rel="stylesheet" href="assets/styles.css">
</head>
<body>
<main class="page">
    <section class="panel">
        <div class="panel__head">
            <div>
                <p class="eyebrow">практические 23 и 25</p>
                <h1>список товаров mysqli</h1>
            </div>
            <a class="button button--ghost" href="index.html">главная</a>
        </div>

        <nav class="chips" aria-label="категории">
            <a class="chip <?= $category === '' ? 'is-active' : '' ?>" href="showList.php">все</a>
            <?php foreach ($categories as $item): ?>
                <?php $categoryName = $item['category']; ?>
                <?php if ($categoryName === $category): ?>
                    <span class="chip is-active"><?= escapeHtml($categoryName) ?></span>
                <?php else: ?>
                    <a class="chip" href="showList.php?category=<?= urlencode($categoryName) ?>"><?= escapeHtml($categoryName) ?></a>
                <?php endif; ?>
            <?php endforeach; ?>
        </nav>

        <div class="list">
            <?php foreach ($games as $game): ?>
                <article class="card">
                    <p class="card__meta"><?= escapeHtml($game['category']) ?></p>
                    <h2><?= escapeHtml($game['name']) ?></h2>
                    <p><?= escapeHtml($game['description']) ?></p>
                    <strong><?= formatPrice($game['price']) ?></strong>
                </article>
            <?php endforeach; ?>

            <?php if (count($games) === 0): ?>
                <p class="empty">товары не найдены</p>
            <?php endif; ?>
        </div>

        <nav class="pagination" aria-label="страницы">
            <?php for ($i = 1; $i <= $totalPages; $i++): ?>
                <?php $url = 'showList.php?page=' . $i . ($category !== '' ? '&category=' . urlencode($category) : ''); ?>
                <?php if ($i === $page): ?>
                    <span class="pagination__item is-active"><?= $i ?></span>
                <?php else: ?>
                    <a class="pagination__item" href="<?= $url ?>"><?= $i ?></a>
                <?php endif; ?>
            <?php endfor; ?>
        </nav>
    </section>
</main>
</body>
</html>
