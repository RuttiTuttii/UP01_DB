<?php
$pageTitle = 'информация о товаре';
require_once __DIR__ . '/header.php';

// читаем идентификатор товара
$id = max(0, (int) ($_GET['id'] ?? 0));
$pdo = getPdoConnection();

// получаем основную информацию
$gameStatement = $pdo->prepare('SELECT id, name, description, category, price, logo FROM games WHERE id = ?');
$gameStatement->execute([$id]);
$game = $gameStatement->fetch();

// получаем фотографии товара
$photos = [];

if ($game) {
    $photoStatement = $pdo->prepare('SELECT path FROM photos WHERE game_id = ? ORDER BY id');
    $photoStatement->execute([$id]);
    $photos = $photoStatement->fetchAll();
}
?>
<main class="page">
    <section class="panel">
        <?php if ($game): ?>
            <article class="product">
                <img class="product__logo" src="<?= escapeHtml($game['logo'] ?: 'assets/images/default-logo.svg') ?>" alt="<?= escapeHtml($game['name']) ?>">
                <div class="product__body">
                    <p class="eyebrow"><?= escapeHtml($game['category']) ?></p>
                    <h1><?= escapeHtml($game['name']) ?></h1>
                    <p><?= escapeHtml($game['description']) ?></p>
                    <strong><?= formatPrice($game['price']) ?></strong>
                    <button type="button" disabled>добавление в корзину есть в zip</button>
                </div>
            </article>

            <div class="gallery">
                <?php foreach ($photos as $photo): ?>
                    <img src="<?= escapeHtml($photo['path']) ?>" alt="иллюстрация товара">
                <?php endforeach; ?>
            </div>
        <?php else: ?>
            <p class="empty">товар не найден</p>
        <?php endif; ?>
    </section>
</main>
<?php require_once __DIR__ . '/footer.php'; ?>
