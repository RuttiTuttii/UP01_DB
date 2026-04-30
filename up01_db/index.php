<?php
$pageTitle = 'витрина pdo';
require_once __DIR__ . '/header.php';

// читаем выбранную категорию
$category = trim((string) ($_GET['category'] ?? ''));
$pdo = getPdoConnection();

// готовим запрос списка товаров
if ($category !== '') {
    $statement = $pdo->prepare('SELECT id, name, description, category FROM games WHERE category = ? ORDER BY name');
    $statement->execute([$category]);
} else {
    $statement = $pdo->query('SELECT id, name, description, category FROM games ORDER BY name');
}

$games = $statement->fetchAll();
?>
<main class="page">
    <section class="panel">
        <div class="panel__head">
            <div>
                <p class="eyebrow">практическая 27</p>
                <h1>витрина pdo</h1>
            </div>
            <a class="button button--ghost" href="index.html">главная</a>
        </div>

        <div class="list">
            <?php foreach ($games as $game): ?>
                <article class="card card--row">
                    <div>
                        <p class="card__meta"><?= escapeHtml($game['category']) ?></p>
                        <h2><?= escapeHtml($game['name']) ?></h2>
                        <p><?= escapeHtml($game['description']) ?></p>
                    </div>
                    <a class="button button--ghost" href="info.php?id=<?= (int) $game['id'] ?>">подробнее</a>
                </article>
            <?php endforeach; ?>

            <?php if (count($games) === 0): ?>
                <p class="empty">товары не найдены</p>
            <?php endif; ?>
        </div>
    </section>
</main>
<?php require_once __DIR__ . '/footer.php'; ?>
