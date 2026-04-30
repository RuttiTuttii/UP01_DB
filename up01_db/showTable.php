<?php
require_once __DIR__ . '/connection.php';

// сбрасываем фильтр
if (($_GET['filter'] ?? '') === 'no') {
    redirectTo('showTable.php');
}

// читаем параметры формы
$allowedSort = ['id', 'name', 'price', 'category'];
$sortBy = in_array($_GET['sortBy'] ?? '', $allowedSort, true) ? $_GET['sortBy'] : 'id';
$filterEnabled = ($_GET['filter'] ?? '') === 'yes';
$name = trim((string) ($_GET['name'] ?? ''));
$description = trim((string) ($_GET['description'] ?? ''));
$price = trim((string) ($_GET['price'] ?? ''));

// открываем подключение
$mysqli = getMysqliConnection();

// собираем условия фильтрации
$whereParts = [];
$params = [];
$types = '';

if ($filterEnabled && $name !== '') {
    $whereParts[] = 'name LIKE ?';
    $params[] = '%' . $name . '%';
    $types .= 's';
}

if ($filterEnabled && $description !== '') {
    $whereParts[] = 'description LIKE ?';
    $params[] = '%' . $description . '%';
    $types .= 's';
}

if ($filterEnabled && $price !== '' && is_numeric($price)) {
    $whereParts[] = 'price <= ?';
    $params[] = (float) $price;
    $types .= 'd';
}

$whereSql = count($whereParts) > 0 ? 'WHERE ' . implode(' AND ', $whereParts) : '';

// выполняем выборку товаров
$sql = "SELECT id, name, description, category, price, logo FROM games $whereSql ORDER BY $sortBy";
$statement = $mysqli->prepare($sql);

if ($types !== '') {
    $statement->bind_param($types, ...$params);
}

$statement->execute();
$games = $statement->get_result()->fetch_all(MYSQLI_ASSOC);

// закрываем подключение
$mysqli->close();

// сохраняем фильтры для ссылок сортировки
$queryForSort = $_GET;
unset($queryForSort['sortBy']);
?>
<!doctype html>
<html lang="ru">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>таблица товаров</title>
    <link rel="stylesheet" href="assets/styles.css">
</head>
<body>
<main class="page">
    <section class="panel">
        <div class="panel__head">
            <div>
                <p class="eyebrow">практические 24-26</p>
                <h1>таблица товаров mysqli</h1>
            </div>
            <a class="button button--ghost" href="index.html">главная</a>
        </div>

        <form class="toolbar" action="showTable.php" method="get">
            <div class="field field--inline">
                <span>сортировка</span>
                <label><input type="radio" name="sortBy" value="name" <?= $sortBy === 'name' ? 'checked' : '' ?>> название</label>
                <label><input type="radio" name="sortBy" value="price" <?= $sortBy === 'price' ? 'checked' : '' ?>> цена</label>
            </div>
            <input type="text" name="name" placeholder="название" value="<?= escapeHtml($name) ?>">
            <input type="text" name="description" placeholder="описание" value="<?= escapeHtml($description) ?>">
            <input type="number" step="0.01" min="0" name="price" placeholder="цена до" value="<?= escapeHtml($price) ?>">
            <button type="submit" name="filter" value="yes">фильтровать</button>
            <button type="submit" name="filter" value="no" class="button--muted">очистить</button>
        </form>

        <form class="mini-form" action="editTable.php" method="get">
            <button class="button" name="ins" type="submit" value="1">добавить</button>
        </form>

        <div class="table-wrap">
            <table>
                <thead>
                <tr>
                    <?php foreach (['id' => 'id', 'name' => 'название', 'category' => 'категория', 'price' => 'цена'] as $column => $label): ?>
                        <?php $queryForSort['sortBy'] = $column; ?>
                        <th><a href="showTable.php?<?= http_build_query($queryForSort) ?>"><?= escapeHtml($label) ?></a></th>
                    <?php endforeach; ?>
                    <th>описание</th>
                    <th>действия</th>
                </tr>
                </thead>
                <tbody>
                <?php foreach ($games as $game): ?>
                    <tr>
                        <td><?= (int) $game['id'] ?></td>
                        <td><?= escapeHtml($game['name']) ?></td>
                        <td><?= escapeHtml($game['category']) ?></td>
                        <td><?= formatPrice($game['price']) ?></td>
                        <td><?= escapeHtml($game['description']) ?></td>
                        <td>
                            <form class="row-actions" action="editTable.php" method="get">
                                <button name="upd" type="submit" value="<?= (int) $game['id'] ?>">редактировать</button>
                                <button name="del" type="submit" value="<?= (int) $game['id'] ?>" class="danger">удалить</button>
                            </form>
                        </td>
                    </tr>
                <?php endforeach; ?>
                </tbody>
            </table>
        </div>

        <?php if (count($games) === 0): ?>
            <p class="empty">записи не найдены</p>
        <?php endif; ?>
    </section>
</main>
</body>
</html>
