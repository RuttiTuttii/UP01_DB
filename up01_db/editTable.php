<?php
require_once __DIR__ . '/connection.php';

// определяем режим формы
$mode = 'insert';
$game = [
    'id' => 0,
    'name' => '',
    'description' => '',
    'category' => '',
    'price' => '',
    'logo' => '',
];

// открываем подключение
$mysqli = getMysqliConnection();

if (isset($_GET['del'])) {
    $mode = 'delete';
    $id = (int) $_GET['del'];

    // получаем запись для подтверждения удаления
    $statement = $mysqli->prepare('SELECT id, name FROM games WHERE id = ?');
    $statement->bind_param('i', $id);
    $statement->execute();
    $game = $statement->get_result()->fetch_assoc() ?: $game;
}

if (isset($_GET['upd'])) {
    $mode = 'update';
    $id = (int) $_GET['upd'];

    // получаем исходные данные для редактирования
    $statement = $mysqli->prepare('SELECT id, name, description, category, price, logo FROM games WHERE id = ?');
    $statement->bind_param('i', $id);
    $statement->execute();
    $game = $statement->get_result()->fetch_assoc() ?: $game;
}

// закрываем подключение
$mysqli->close();
?>
<!doctype html>
<html lang="ru">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>редактирование</title>
    <link rel="stylesheet" href="assets/styles.css">
</head>
<body>
<main class="page page--center">
    <section class="panel panel--narrow">
        <?php if ($mode === 'delete'): ?>
            <p class="eyebrow">удаление</p>
            <h1>удалить товар?</h1>
            <p>товар: <strong><?= escapeHtml($game['name']) ?></strong></p>
            <div class="actions">
                <form action="saveTable.php" method="post">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="id" value="<?= (int) $game['id'] ?>">
                    <button class="danger" type="submit">да</button>
                </form>
                <a class="button button--ghost" href="showTable.php">нет</a>
            </div>
        <?php else: ?>
            <p class="eyebrow"><?= $mode === 'update' ? 'изменение' : 'добавление' ?></p>
            <h1><?= $mode === 'update' ? 'редактировать товар' : 'добавить товар' ?></h1>
            <form class="form-grid" action="saveTable.php" method="post">
                <input type="hidden" name="action" value="<?= $mode === 'update' ? 'update' : 'insert' ?>">
                <input type="hidden" name="id" value="<?= (int) $game['id'] ?>">

                <label>название
                    <input type="text" name="name" value="<?= escapeHtml($game['name']) ?>" required>
                </label>

                <label>категория
                    <input type="text" name="category" value="<?= escapeHtml($game['category']) ?>" required>
                </label>

                <label>цена
                    <input type="number" step="0.01" min="0" name="price" value="<?= escapeHtml((string) $game['price']) ?>" required>
                </label>

                <label>логотип
                    <input type="text" name="logo" value="<?= escapeHtml($game['logo']) ?>" placeholder="assets/images/logo.svg">
                </label>

                <label class="field--full">описание
                    <textarea name="description" rows="5" required><?= escapeHtml($game['description']) ?></textarea>
                </label>

                <div class="actions">
                    <button type="submit">сохранить</button>
                    <a class="button button--ghost" href="showTable.php">назад</a>
                </div>
            </form>
        <?php endif; ?>
    </section>
</main>
</body>
</html>
