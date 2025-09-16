# Schema.org ImageObject Markup Implementation

## Обзор

В проект была добавлена поддержка Schema.org разметки для изображений с использованием типа `ImageObject`. Это улучшает SEO и позволяет поисковым системам лучше понимать содержимое изображений.

## Реализованная функциональность

### Хелпер SchemaHelper

Создан модуль `app/helpers/schema_helper.rb`, который предоставляет следующие методы:

**Основные методы:**
- `generate_image_schema(image_url, options = {})` - базовый метод для генерации Schema.org разметки
- `product_image_schema(product, mobile = false)` - генерация разметки для изображений продуктов
- `photo_image_schema(photo)` - генерация разметки для фотографий в альбомах
- `slide_image_schema(slide)` - генерация разметки для слайдов

**Новые методы (добавлены в обновлении):**
- `smile_image_schema(smile, alt_text = nil)` - для изображений отзывов/smiles
- `category_image_schema(category)` - для изображений категорий
- `product_modal_image_schema(product, angular_image_var = nil)` - для модальных окон продуктов
- `complex_product_image_schema(product, image_url)` - для сложных изображений продуктов
- `news_image_schema(news)` - для изображений новостей и статей

### Интегрированные места

1. **Карточки продуктов** (`app/views/product/_cardplace.haml`)
   - Заменена старая неполная Schema.org разметка на полную
   - Используется `product_image_schema(product, true)` для мобильных изображений

2. **Альбомы фотографий**
   - `app/views/album/show.haml` - отдельные фотографии в альбоме
   - `app/views/album/index.haml` - превью фотографий для каждого альбома

3. **Слайдшоу** (`app/views/layouts/parts/_slideshow.haml`)
   - Добавлена разметка для всех слайдов

4. **Страницы отзывов** (`app/views/smiles/show.erb`)
   - Добавлена разметка для изображений продуктов в отзывах
   - **Новое:** Главные изображения в блоке `.img-box` с разметкой `smile_image_schema`

5. **Модальные окна продуктов** (`app/views/product/_item_modal.html.erb`)
   - **Новое:** Добавлена разметка для главных изображений товаров в блоке `.itemImg`
   - Поддерживает Angular переменные для динамических изображений

6. **Страницы категорий** (`app/views/category/perekrestok.haml`)
   - **Новое:** Разметка для изображений категорий в карусели
   - **Новое:** Разметка для сложных изображений продуктов с динамическими URL

7. **Блок "Статьи о цветах"** (`app/views/category/news/_latest_news.haml`)
   - **Новое:** Разметка для изображений новостей и статей

## Генерируемая разметка

Пример сгенерированной разметки:

```json
{
  "@context": "http://schema.org",
  "@type": "ImageObject",
  "contentUrl": "https://domain.ru/images/product.jpg",
  "datePublished": "2023-01-01",
  "name": "Название изображения",
  "description": "Описание изображения",
  "width": "650",
  "height": "650",
  "author": "Rozario Flowers"
}
```

## Динамические данные

Все возможные данные берутся из переменных:

- **contentUrl**: Полный URL изображения с учетом поддомена
- **datePublished**: Дата создания записи в формате YYYY-MM-DD
- **name**: 
  - Для продуктов: `product.header`
  - Для фотографий: `photo.title`
  - Для слайдов: `slide.text` или "Slideshow Image"
- **description**:
  - Для продуктов: `product.alt` или `product.header`
  - Для фотографий: `photo.title`
  - Для слайдов: `slide.text` или "Slideshow Image"
- **width/height**: 
  - Мобильные: 650x650
  - Десктоп: 1315x650
- **author**: Всегда "Rozario Flowers"

## Тестирование

Создан полный набор тестов в `test/schema_helper_test.rb`, который проверяет:

- Генерацию базовой Schema.org разметки
- Генерацию разметки с опциональными параметрами
- Специфичные методы для продуктов, фотографий и слайдов
- Корректность формирования полных URL
- Валидность генерируемого JSON

## Запуск тестов

```bash
ruby test/schema_helper_test.rb
```

## Совместимость

- Не изменяется структура БД
- Использует существующие данные из моделей
- Обратно совместимо с существующей разметкой
- Работает с существующей системой поддоменов
