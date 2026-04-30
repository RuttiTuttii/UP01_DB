<?php
require_once __DIR__ . '/connection.php';

// читаем действие формы
$action = $_POST['action'] ?? '';
$message = 'команда не выполнена';
$isSuccess = false;

// открываем подключение
$mysqli = getMysqliConnection();

try {
    if ($action === 'delete') {
        // удаляем выбранный товар
        $id = (int) $_POST['id'];
        $statement = $mysqli->prepare('DELETE FROM games WHERE id = ?');
        $statement->bind_param('i', $id);
        $statement->execute();
        $isSuccess = $statement->affected_rows > 0;
        $message = $isSuccess ? 'товар удален' : 'товар не найден';
    }

    if ($action === 'insert') {
        // добавляем новый товар
        $name = trim((string) $_POST['name']);
        $description = trim((string) $_POST['description']);
        $category = trim((string) $_POST['category']);
        $price = (float) $_POST['price'];
        $logo = trim((string) ($_POST['logo'] ?? ''));

        $statement = $mysqli->prepare('INSERT INTO games (name, description, category, price, logo) VALUES (?, ?, ?, ?, ?)');
        $statement->bind_param('sssds', $name, $description, $category, $price, $logo);
        $statement->execute();
        $isSuccess = $statement->affected_rows > 0;
        $message = $isSuccess ? 'товар добавлен' : 'товар не добавлен';
    }

    if ($action === 'update') {
        // обновляем выбранный товар
        $id = (int) $_POST['id'];
        $name = trim((string) $_POST['name']);
        $description = trim((string) $_POST['description']);
        $category = trim((string) $_POST['category']);
        $price = (float) $_POST['price'];
        $logo = trim((string) ($_POST['logo'] ?? ''));

        $statement = $mysqli->prepare('UPDATE games SET name = ?, description = ?, category = ?, price = ?, logo = ? WHERE id = ?');
        $statement->bind_param('sssdsi', $name, $description, $category, $price, $logo, $id);
        $statement->execute();
        $isSuccess = $statement->affected_rows >= 0;
        $message = $isSuccess ? 'товар сохранен' : 'товар не сохранен';
    }
} catch (Throwable $error) {
    // сохраняем текст ошибки
    $message = 'ошибка sql: ' . $error->getMessage();
}

// закрываем подключение
$mysqli->close();
?>
<!doctype html>
<html lang="ru">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>результат</title>
    <link rel="stylesheet" href="assets/styles.css">
</head>
<body>
<main class="page page--center">
    <section class="panel panel--narrow">
        <p class="eyebrow">результат</p>
        <h1><?= $isSuccess ? 'готово' : 'проверь данные' ?></h1>
        <p class="status <?= $isSuccess ? 'is-success' : 'is-error' ?>"><?= escapeHtml($message) ?></p>
        <div class="actions">
            <a class="button" href="showTable.php">к таблице</a>
            <a class="button button--ghost" href="index.html">главная</a>
        </div>
    </section>
</main>
</body>
</html>
