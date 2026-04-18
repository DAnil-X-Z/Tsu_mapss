## Что делает приложение

Приложение помогает работать с картой кампуса:

- показывает карту;
- строит маршрут между точками;
- показывает точки заведений по типам;
- группирует точки в кластеры;
- позволяет поставить оценку заведению, рисуя цифру на сетке 5x5.

## Как устроен проект

```text
lib/
  main.dart
  app.dart
  core/
    theme/
      app_theme.dart
      app_button_styles.dart
  features/
    splash/
      presentation/
        splash_screen.dart
    navigation/
      presentation/
        main_screen.dart
    home/
      presentation/
        home_page.dart
    map/
      data/
        grid_map_loader.dart
      domain/
        grid_map.dart
        a_star_solver.dart
      presentation/
        map_page.dart
    places/
      data/
        place_catalog.dart
      domain/
        place.dart
    clustering/
      domain/
        dbscan.dart
      presentation/
        clustering_page.dart
    rating/
      domain/
        digit_recognizer.dart
      presentation/
        rating_page.dart
assets/
  map.png
  logo.png
  data/grid.json
  icons/*.svg
docs/
  IMPLEMENTATION.md
```

## Как приложение запускается

1. `main()` запускает `MyApp`.
2. `MyApp` открывает `SplashScreen`.
3. Через 2 секунды открывается `MainScreen`.
4. В `MainScreen` есть верхняя панель, меню справа и страницы приложения.

---

## Описание файлов и функций

## `lib/main.dart`

### `main()`

Старт приложения. Запускает корневой виджет `MyApp`.

## `lib/app.dart`

### `class MyApp`

Главный виджет приложения.

### `build(BuildContext context)`

Создаёт `MaterialApp`:

- ставит тему;
- задаёт стартовый экран `SplashScreen`.

## `lib/core/theme/app_theme.dart`

### `class AppTheme`

Хранит основные цвета и тему приложения.

### Константы цвета

- `brand` — главный синий цвет.
- `brandDark` — тёмный синий.
- `softSurface` — светлый фон для блоков.
- `softDisabled` — фон неактивных кнопок.
- `disabledForeground` — цвет текста/иконок неактивных кнопок.

### `light()`

Создаёт светлую тему:

- настраивает цвета;
- стили `AppBar`;
- стили `Drawer`;
- стиль обычных `ElevatedButton`;
- стиль `SnackBar`.

## `lib/core/theme/app_button_styles.dart`

### `enum AppButtonVariant`

Типы кнопок: `primary`, `soft`, `active`.

### `class AppButtonStyles`

Утилита для единого стиля кнопок.

### `resolve(...)`

Возвращает готовый стиль кнопки с нужной высотой, радиусом и цветами.

### `_colorsFor(...)`

Возвращает цвета фона и текста для выбранного типа кнопки.

## `lib/features/splash/presentation/splash_screen.dart`

### `class SplashScreen`

Экран с логотипом перед открытием приложения.

### `initState()`

Ждёт 2 секунды и открывает `MainScreen`.

### `build(BuildContext context)`

Рисует белый экран и логотип по центру.

## `lib/features/navigation/presentation/main_screen.dart`

### `class MainScreen`

Главный экран-контейнер приложения.

### `_selectedIndex`

Номер текущей вкладки.

### `_buildPages()`

Собирает список страниц:

- `HomePage`
- `MapPage`
- `ClusteringPage`
- `RatingPage`

### `_buildNavItems()`

Создаёт пункты меню справа (название + иконка).

### `build(BuildContext context)`

Собирает основной каркас:

- сверху `AppBar`;
- справа выезжающее меню (`Drawer`);
- в центре активная страница из `IndexedStack`.

### `class _NavItem`

Модель одного пункта меню:

- `title` — текст;
- `icon` — обычная иконка;
- `activeIcon` — иконка активного пункта.

## `lib/features/home/presentation/home_page.dart`

### `class HomePage`

Главная страница с быстрыми кнопками.

### `onQuickNavigate`

Функция, которая переключает вкладку в `MainScreen`.

### `build(BuildContext context)`

Показывает сетку 2x2 из быстрых кнопок:

- кнопка маршрута;
- кнопка кластеров;
- кнопка оценки;
- кнопка карты.

### `class _QuickActionTile`

Одна плитка быстрого действия.

### `_QuickActionTile.build(...)`

Рисует кнопку-плитку с иконкой, заголовком и подзаголовком.

## `lib/features/places/domain/place.dart`

### `enum PlaceType`

Типы заведений (кофе, блины, полный обед, перекус).
Для каждого типа есть:

- название;
- путь к иконке;
- цвет.

### `class CampusPlace`

Модель одной точки заведения:

- `id`;
- `name`;
- `type`;
- `position` (координаты на карте в диапазоне 0..1).

## `lib/features/places/data/place_catalog.dart`

### `class PlaceCatalog`

Справочник заведений.

### `places`

Список всех заведений на карте.
Используется в кластерах и в экране оценки.

## `lib/features/map/domain/grid_map.dart`

### `class GridMap`

Данные сетки карты для маршрута:

- ширина;
- высота;
- матрица клеток.

### `isWalkable(int x, int y)`

Проверяет, можно ли пройти через клетку.

### `class Cell`

Координата клетки (`x`, `y`).

### `operator ==` и `hashCode`

Нужны, чтобы клетки корректно работали в `Set` и `Map`.

## `lib/features/map/data/grid_map_loader.dart`

### `class GridMapLoader`

Загружает сетку из файла ассетов.

### `loadFromAssets(String path)`

Читает JSON и возвращает `GridMap`.

## `lib/features/map/domain/a_star_solver.dart`

### `class AStarSolver`

Ищет маршрут алгоритмом A\*.

### `findPath(...)`

Основной поиск пути:

- переводит старт/финиш в клетки;
- проверяет, что клетки проходимые;
- запускает A\*;
- если путь найден, возвращает список точек маршрута;
- если путь не найден, возвращает пустой список.

### `toCell(...)`

Переводит координату на карте в клетку сетки.

### `toNormalizedCenter(...)`

Переводит клетку сетки обратно в координату карты.

### `_manhattan(...)`

Считает эвристику Манхэттена для A\*.

### `_neighbors(...)`

Возвращает соседние проходимые клетки (вверх/вниз/влево/вправо).

## `lib/features/map/presentation/map_page.dart`

### `enum _PickMode`

Режим выбора точки: нет выбора, старт, финиш.

### `class MapPage`

Экран карты и маршрута.

### Основные поля состояния

- `_start` — стартовая точка;
- `_finish` — конечная точка;
- `_path` — построенный маршрут;
- `_grid` — сетка карты;
- `_isGridLoading` — идёт ли загрузка карты;
- `_isBuildingRoute` — идёт ли расчёт маршрута.

### `_isGridReady`

Проверяет, что сетка карты уже загружена.

### `_canBuildRoute`

Проверяет, что можно строить маршрут (есть сетка, старт, финиш, нет активного расчёта).

### `initState()`

При открытии экрана запускает загрузку сетки.

### `_loadGrid()`

Загружает `grid.json`, очищает старые точки и путь.
Если ошибка — показывает сообщение.

### `_selectMode(...)`

Включает или выключает режим выбора старта/финиша.

### `_handleMapTap(...)`

Обрабатывает тап по карте:

- берёт координату тапа;
- переводит её в клетку;
- проверяет проходимость;
- ставит старт или финиш;
- сбрасывает старый маршрут.

### `_buildRoute()`

Считает путь через `AStarSolver` и сохраняет результат.
Если путь пустой — показывает сообщение.

### `_resetAll()`

Сбрасывает режим выбора, старт, финиш и маршрут.

### `build(BuildContext context)`

Собирает экран:

- слой карты;
- слой препятствий;
- слой маршрута;
- нижняя панель кнопок управления.

### `class _ObstaclePainter`

Рисует непроходимые клетки поверх карты.

### `_ObstaclePainter.paint(...)`

Проходит по матрице и закрашивает непроходимые клетки.

### `_ObstaclePainter.shouldRepaint(...)`

Говорит, когда слой нужно перерисовать.

### `class _MapPainter`

Рисует путь и метки `S`/`F`.

### `_MapPainter.paint(...)`

Рисует линию маршрута и точки старта/финиша.

### `_MapPainter._drawPoint(...)`

Рисует одну точку-маркер с буквой внутри.

### `_MapPainter.shouldRepaint(...)`

Говорит, когда слой нужно перерисовать.

### `class _MapActionButton`

Кнопка нижней панели карты.

### `_MapActionButton.build(...)`

Рисует кнопку с иконкой и подписью.
Поддерживает состояние загрузки (спиннер).

## `lib/features/clustering/domain/dbscan.dart`

### `class Dbscan`

Алгоритм группировки точек DBSCAN.

### `run(...)`

Запускает кластеризацию и возвращает метки для точек:

- номер кластера;
- или шум.

### `_expandCluster(...)`

Расширяет найденный кластер по соседним точкам.

### `_regionQuery(...)`

Ищет соседей точки в радиусе `eps`.

## `lib/features/clustering/presentation/clustering_page.dart`

### `enum _PageMode`

Режим экрана:

- `filter` — только фильтрация по типу;
- `clustering` — режим кластеризации.

### `class ClusteringPage`

Экран фильтрации и кластеризации точек на карте.

### `_visibleFilterPlaces`

Возвращает точки выбранного типа для режима фильтра.

### `_clusterInputIndices()`

Возвращает индексы точек, которые будут переданы в DBSCAN.

### `_clusterPreviewLabels()`

Готовит временные метки до запуска DBSCAN.

### `_runDbscan()`

Запускает DBSCAN с текущими параметрами `eps` и `minPts`.

### `_buildDbscanSummary(...)`

Собирает короткую статистику по результату кластеризации.

### `_chipStyle(...)`

Возвращает стиль кнопок режима и параметров.

### `build(BuildContext context)`

Собирает экран с:

- картой;
- режимами фильтрации/кластеризации;
- параметрами `eps` и `minPts`;
- кнопкой запуска.

### `class _TypeDropdown`

Выпадающий список выбора типа заведения.

### `_TypeDropdown.build(...)`

Рисует dropdown с иконками типов.

### `class _FilterPlacesPainter`

Рисует точки выбранного типа.

### `_FilterPlacesPainter.paint(...)`

Рисует маркеры точек на карте.

### `_FilterPlacesPainter.shouldRepaint(...)`

Проверяет необходимость перерисовки.

### `class _DbscanPainter`

Рисует точки по результату DBSCAN.

### `_DbscanPainter.paint(...)`

Отрисовывает точки разными цветами по меткам.

### `_DbscanPainter._colorForLabel(...)`

Выбирает цвет точки по её метке.

### `_DbscanPainter.shouldRepaint(...)`

Проверяет необходимость перерисовки.

## `lib/features/rating/domain/digit_recognizer.dart`

### `class DigitRecognition`

Результат распознавания:

- какая цифра найдена;
- уверенность;
- вероятности для всех цифр.

### `class DigitRecognizer`

Распознаёт цифру по рисунку на сетке 5x5.

### `size`

Размер сетки (`5`).

### `_templates`

Шаблоны цифр от 0 до 9 (эталонные матрицы).

### `recognize(List<bool> input)`

Распознаёт цифру:

- проверяет размер входа;
- считает похожесть с каждым шаблоном;
- выбирает лучший вариант;
- возвращает результат с уверенностью.

### `_softmax(...)`

Преобразует оценки в вероятности.

## `lib/features/rating/presentation/rating_page.dart`

### `class RatingPage`

Экран, где пользователь выбирает заведение и ставит оценку.

### `_filteredPlaces`

Возвращает заведения по выбранному типу.

### `_toggleCell(int index)`

Переключает одну клетку 5x5 и пересчитывает распознавание.

### `_clearDigitGrid()`

Очищает сетку и текущий результат распознавания.

### `_saveRating()`

Сохраняет оценку для выбранного заведения и показывает сообщение.

### `_averageFor(String placeId)`

Считает среднюю оценку выбранного заведения.

### `build(BuildContext context)`

Собирает экран:

- выбор типа;
- выбор заведения;
- сетка 5x5;
- кнопки очистки и сохранения;
- вывод распознанной цифры и уверенности.

### `class _TypeDropdown`

Dropdown выбора типа заведения.

### `_TypeDropdown.build(...)`

Рисует выпадающий список с иконками и названиями.

---

## Файлы данных и картинки

- `assets/data/grid.json` — сетка проходимости для карты.
- `assets/map.png` — картинка карты.
- `assets/logo.png` — логотип.
- `assets/icons/*.svg` — иконки для кнопок и типов заведений.

## Как хранятся данные во время работы

- Маршрут хранится в состоянии `MapPage`.
- Результаты кластеризации хранятся в состоянии `ClusteringPage`.
- Оценки хранятся в памяти в `RatingPage` и пропадают после перезапуска приложения.

## Текущие ограничения

- Оценки пока не сохраняются в базу/файл.
- Маршрут строится только по 4 направлениям (без диагоналей).
- DBSCAN работает по координатам точек из каталога и параметрам, заданным на экране.
