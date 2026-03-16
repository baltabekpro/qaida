from __future__ import annotations

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.security import hash_password
from app.db.models import (
    BudgetRange,
    Collection,
    CollectionPlace,
    CompanyType,
    Favorite,
    MenuItem,
    Notification,
    NotificationType,
    OpeningHour,
    Place,
    PlaceStatus,
    Review,
    SearchHistory,
    User,
)


def seed_database(db: Session) -> None:
    existing_user = db.scalar(select(User.id).limit(1))
    if existing_user:
        return

    settings = get_settings()
    user = User(
        name='Demo User',
        email=settings.default_user_email,
        password_hash=hash_password('qaida-demo'),
        avatar_url='https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80',
        is_active=True,
        company_type=CompanyType.FRIENDS,
        favorite_categories=['Кафе', 'Ресторан', 'Бар'],
        budget=BudgetRange.MEDIUM,
        notifications_enabled=True,
        enabled_notification_types=[
            NotificationType.NEW_PLACE.value,
            NotificationType.REMINDER.value,
            NotificationType.RECOMMENDATION.value,
        ],
    )
    db.add(user)
    db.flush()

    place_specs = [
        {
            'name': 'The Choco',
            'category': 'Кафе',
            'short_description': 'Популярная кофейня для встреч и спокойной работы.',
            'description': 'Уютная кофейня с завтраками, десертами и авторскими напитками в центре Алматы.',
            'rating': 4.8,
            'review_count': 186,
            'address': 'пр. Абая 21, Алматы',
            'budget': BudgetRange.MEDIUM,
            'status': PlaceStatus.OPEN,
            'image_url': 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=1200&q=80',
            'tags': ['coffee', 'friends', 'solo', 'wifi'],
            'amenities': ['WiFi', 'Завтраки', 'Терраса'],
            'gallery': [
                'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=1200&q=80',
                'https://images.unsplash.com/photo-1445116572660-236099ec97a0?auto=format&fit=crop&w=1200&q=80',
            ],
            'latitude': 43.238949,
            'longitude': 76.889709,
            'popularity_score': 97,
            'menu': [
                ('Flat White', 'Напитки', 1800),
                ('Cheesecake', 'Десерты', 2200),
            ],
        },
        {
            'name': 'Aura Rooftop',
            'category': 'Ресторан',
            'short_description': 'Панорамный ресторан для свиданий и особых поводов.',
            'description': 'Вечерний ресторан с панорамой города, коктейльной картой и live DJ по выходным.',
            'rating': 4.7,
            'review_count': 124,
            'address': 'ул. Сатпаева 11, Алматы',
            'budget': BudgetRange.HIGH,
            'status': PlaceStatus.OPEN,
            'image_url': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=1200&q=80',
            'tags': ['couple', 'friends', 'rooftop'],
            'amenities': ['Парковка', 'Терраса', 'Бронирование'],
            'gallery': [
                'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=1200&q=80',
            ],
            'latitude': 43.23417,
            'longitude': 76.94561,
            'popularity_score': 88,
            'menu': [
                ('Стейк рибай', 'Основное', 10500),
                ('Signature Sour', 'Напитки', 4200),
            ],
        },
        {
            'name': 'Nomad Garden',
            'category': 'Парк',
            'short_description': 'Зелёное пространство для прогулок, пикника и семейного отдыха.',
            'description': 'Парк с тихими аллеями, детской зоной и сезонными ярмарками.',
            'rating': 4.6,
            'review_count': 91,
            'address': 'ул. Толе би 98, Алматы',
            'budget': BudgetRange.LOW,
            'status': PlaceStatus.OPEN,
            'image_url': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1200&q=80',
            'tags': ['family', 'solo', 'outdoor'],
            'amenities': ['Детская зона', 'Парковка'],
            'gallery': [
                'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1200&q=80',
            ],
            'latitude': 43.25532,
            'longitude': 76.92848,
            'popularity_score': 80,
            'menu': [],
        },
        {
            'name': 'Qymyz Cinema Club',
            'category': 'Кино',
            'short_description': 'Небольшой кинотеатр с атмосферой клубного просмотра.',
            'description': 'Авторское кино, тематические показы и обсуждения после сеанса.',
            'rating': 4.5,
            'review_count': 57,
            'address': 'пр. Достык 55, Алматы',
            'budget': BudgetRange.MEDIUM,
            'status': PlaceStatus.OPEN,
            'image_url': 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=1200&q=80',
            'tags': ['friends', 'couple', 'night'],
            'amenities': ['Бар', 'Парковка'],
            'gallery': [
                'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=1200&q=80',
            ],
            'latitude': 43.23383,
            'longitude': 76.95638,
            'popularity_score': 72,
            'menu': [
                ('Попкорн XL', 'Снэки', 1600),
                ('Лимонад', 'Напитки', 1200),
            ],
        },
        {
            'name': 'Saffron Family Hall',
            'category': 'Ресторан',
            'short_description': 'Семейный ресторан с детским меню и просторными залами.',
            'description': 'Большой семейный ресторан для ужинов, встреч и праздничных дней.',
            'rating': 4.4,
            'review_count': 73,
            'address': 'мкр. Самал-2, 33, Алматы',
            'budget': BudgetRange.MEDIUM,
            'status': PlaceStatus.OPEN,
            'image_url': 'https://images.unsplash.com/photo-1559339352-11d035aa65de?auto=format&fit=crop&w=1200&q=80',
            'tags': ['family', 'halal', 'kids'],
            'amenities': ['Детское меню', 'Парковка', 'Халал'],
            'gallery': [
                'https://images.unsplash.com/photo-1559339352-11d035aa65de?auto=format&fit=crop&w=1200&q=80',
            ],
            'latitude': 43.22672,
            'longitude': 76.94814,
            'popularity_score': 78,
            'menu': [
                ('Плов', 'Основное', 3400),
                ('Семейный сет', 'Основное', 12900),
            ],
        },
    ]

    places: list[Place] = []
    for spec in place_specs:
        place = Place(
            name=spec['name'],
            category=spec['category'],
            short_description=spec['short_description'],
            description=spec['description'],
            rating=spec['rating'],
            review_count=spec['review_count'],
            address=spec['address'],
            budget=spec['budget'],
            status=spec['status'],
            image_url=spec['image_url'],
            tags=spec['tags'],
            amenities=spec['amenities'],
            gallery=spec['gallery'],
            latitude=spec['latitude'],
            longitude=spec['longitude'],
            popularity_score=spec['popularity_score'],
        )
        place.opening_hours = [
            OpeningHour(day='Mon', open_time='09:00', close_time='22:00'),
            OpeningHour(day='Tue', open_time='09:00', close_time='22:00'),
            OpeningHour(day='Wed', open_time='09:00', close_time='22:00'),
            OpeningHour(day='Thu', open_time='09:00', close_time='22:00'),
            OpeningHour(day='Fri', open_time='09:00', close_time='23:00'),
            OpeningHour(day='Sat', open_time='10:00', close_time='23:00'),
            OpeningHour(day='Sun', open_time='10:00', close_time='21:00'),
        ]
        place.menu_items = [
            MenuItem(name=name, category=category, price=price, description=None)
            for name, category, price in spec['menu']
        ]
        places.append(place)
        db.add(place)

    db.flush()

    reviews = [
        Review(place_id=places[0].id, user_id=user.id, rating=5, text='Отличное место для кофе и спокойной встречи.'),
        Review(place_id=places[1].id, user_id=user.id, rating=5, text='Очень красивый вид и сильная вечерняя атмосфера.'),
        Review(place_id=places[4].id, user_id=user.id, rating=4, text='Хороший вариант для семейного ужина.'),
    ]
    db.add_all(reviews)

    favorites = [
        Favorite(user_id=user.id, place_id=places[0].id),
        Favorite(user_id=user.id, place_id=places[1].id),
    ]
    db.add_all(favorites)

    collection = Collection(user_id=user.id, name='На выходные')
    db.add(collection)
    db.flush()
    db.add_all(
        [
            CollectionPlace(collection_id=collection.id, place_id=places[1].id),
            CollectionPlace(collection_id=collection.id, place_id=places[3].id),
        ]
    )

    db.add_all(
        [
            Notification(
                user_id=user.id,
                type=NotificationType.RECOMMENDATION,
                title='Новая подборка для друзей',
                message='Мы нашли 3 новых места для вечерней встречи неподалёку.',
                action_url='/places',
                read=False,
            ),
            Notification(
                user_id=user.id,
                type=NotificationType.REMINDER,
                title='Напоминание о сохранённом месте',
                message='Aura Rooftop всё ещё в избранном. Вечером там свободные столики.',
                action_url=f'/places/{places[1].id}',
                read=False,
            ),
        ]
    )

    db.add_all(
        [
            SearchHistory(user_id=user.id, query='кофейня', filters={'categories': ['Кафе'], 'companyType': 'friends'}),
            SearchHistory(user_id=user.id, query='семейный ресторан', filters={'categories': ['Ресторан'], 'companyType': 'family'}),
        ]
    )

    db.commit()
