"""initial schema

Revision ID: 0001_initial
Revises:
Create Date: 2026-03-09 00:00:00
"""

from alembic import op
import sqlalchemy as sa


revision = '0001_initial'
down_revision = None
branch_labels = None
depends_on = None


company_type = sa.Enum('SOLO', 'COUPLE', 'FRIENDS', 'FAMILY', name='companytype')
budget_range = sa.Enum('LOW', 'MEDIUM', 'HIGH', name='budgetrange')
place_status = sa.Enum('OPEN', 'CLOSED', 'COMING_SOON', name='placestatus')
notification_type = sa.Enum('NEW_PLACE', 'REMINDER', 'SAVED_PLACE', 'RECOMMENDATION', 'BOOKING', name='notificationtype')


def upgrade() -> None:
    bind = op.get_bind()
    company_type.create(bind, checkfirst=True)
    budget_range.create(bind, checkfirst=True)
    place_status.create(bind, checkfirst=True)
    notification_type.create(bind, checkfirst=True)

    op.create_table(
        'users',
        sa.Column('id', sa.String(length=36), primary_key=True, nullable=False),
        sa.Column('name', sa.String(length=120), nullable=False),
        sa.Column('email', sa.String(length=255), nullable=False),
        sa.Column('password_hash', sa.String(length=255), nullable=False),
        sa.Column('avatar_url', sa.String(length=500), nullable=True),
        sa.Column('is_active', sa.Boolean(), nullable=False, server_default=sa.text('true')),
        sa.Column('company_type', company_type, nullable=False),
        sa.Column('favorite_categories', sa.JSON(), nullable=False),
        sa.Column('budget', budget_range, nullable=False),
        sa.Column('notifications_enabled', sa.Boolean(), nullable=False, server_default=sa.text('true')),
        sa.Column('enabled_notification_types', sa.JSON(), nullable=False),
    )
    op.create_index('ix_users_email', 'users', ['email'], unique=True)

    op.create_table(
        'places',
        sa.Column('id', sa.String(length=36), primary_key=True, nullable=False),
        sa.Column('name', sa.String(length=255), nullable=False),
        sa.Column('category', sa.String(length=120), nullable=False),
        sa.Column('short_description', sa.String(length=255), nullable=False),
        sa.Column('description', sa.Text(), nullable=False),
        sa.Column('rating', sa.Float(), nullable=False),
        sa.Column('review_count', sa.Integer(), nullable=False),
        sa.Column('address', sa.String(length=255), nullable=False),
        sa.Column('budget', budget_range, nullable=False),
        sa.Column('status', place_status, nullable=False),
        sa.Column('image_url', sa.String(length=500), nullable=True),
        sa.Column('tags', sa.JSON(), nullable=False),
        sa.Column('amenities', sa.JSON(), nullable=False),
        sa.Column('gallery', sa.JSON(), nullable=False),
        sa.Column('latitude', sa.Float(), nullable=False),
        sa.Column('longitude', sa.Float(), nullable=False),
        sa.Column('popularity_score', sa.Integer(), nullable=False),
    )
    op.create_index('ix_places_name', 'places', ['name'], unique=False)
    op.create_index('ix_places_category', 'places', ['category'], unique=False)

    op.create_table(
        'opening_hours',
        sa.Column('id', sa.String(length=36), primary_key=True, nullable=False),
        sa.Column('place_id', sa.String(length=36), sa.ForeignKey('places.id', ondelete='CASCADE'), nullable=False),
        sa.Column('day', sa.String(length=16), nullable=False),
        sa.Column('open_time', sa.String(length=5), nullable=False),
        sa.Column('close_time', sa.String(length=5), nullable=False),
    )
    op.create_index('ix_opening_hours_place_id', 'opening_hours', ['place_id'], unique=False)

    op.create_table(
        'menu_items',
        sa.Column('id', sa.String(length=36), primary_key=True, nullable=False),
        sa.Column('place_id', sa.String(length=36), sa.ForeignKey('places.id', ondelete='CASCADE'), nullable=False),
        sa.Column('name', sa.String(length=255), nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('category', sa.String(length=80), nullable=False),
        sa.Column('price', sa.Float(), nullable=False),
        sa.Column('currency', sa.String(length=8), nullable=False),
        sa.Column('image_url', sa.String(length=500), nullable=True),
    )
    op.create_index('ix_menu_items_place_id', 'menu_items', ['place_id'], unique=False)

    op.create_table(
        'collections',
        sa.Column('id', sa.String(length=36), primary_key=True, nullable=False),
        sa.Column('user_id', sa.String(length=36), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('name', sa.String(length=120), nullable=False),
        sa.Column('created_at', sa.DateTime(), nullable=False),
    )
    op.create_index('ix_collections_user_id', 'collections', ['user_id'], unique=False)

    op.create_table(
        'notifications',
        sa.Column('id', sa.String(length=36), primary_key=True, nullable=False),
        sa.Column('user_id', sa.String(length=36), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('type', notification_type, nullable=False),
        sa.Column('title', sa.String(length=160), nullable=False),
        sa.Column('message', sa.Text(), nullable=False),
        sa.Column('action_url', sa.String(length=500), nullable=True),
        sa.Column('read', sa.Boolean(), nullable=False, server_default=sa.text('false')),
        sa.Column('created_at', sa.DateTime(), nullable=False),
    )
    op.create_index('ix_notifications_user_id', 'notifications', ['user_id'], unique=False)

    op.create_table(
        'reviews',
        sa.Column('id', sa.String(length=36), primary_key=True, nullable=False),
        sa.Column('place_id', sa.String(length=36), sa.ForeignKey('places.id', ondelete='CASCADE'), nullable=False),
        sa.Column('user_id', sa.String(length=36), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('rating', sa.Integer(), nullable=False),
        sa.Column('text', sa.Text(), nullable=False),
        sa.Column('created_at', sa.DateTime(), nullable=False),
    )
    op.create_index('ix_reviews_place_id', 'reviews', ['place_id'], unique=False)
    op.create_index('ix_reviews_user_id', 'reviews', ['user_id'], unique=False)

    op.create_table(
        'search_history',
        sa.Column('id', sa.String(length=36), primary_key=True, nullable=False),
        sa.Column('user_id', sa.String(length=36), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('query', sa.String(length=255), nullable=False),
        sa.Column('filters', sa.JSON(), nullable=False),
        sa.Column('created_at', sa.DateTime(), nullable=False),
    )
    op.create_index('ix_search_history_user_id', 'search_history', ['user_id'], unique=False)

    op.create_table(
        'favorites',
        sa.Column('user_id', sa.String(length=36), sa.ForeignKey('users.id', ondelete='CASCADE'), primary_key=True),
        sa.Column('place_id', sa.String(length=36), sa.ForeignKey('places.id', ondelete='CASCADE'), primary_key=True),
        sa.Column('created_at', sa.DateTime(), nullable=False),
    )

    op.create_table(
        'collection_places',
        sa.Column('collection_id', sa.String(length=36), sa.ForeignKey('collections.id', ondelete='CASCADE'), primary_key=True),
        sa.Column('place_id', sa.String(length=36), sa.ForeignKey('places.id', ondelete='CASCADE'), primary_key=True),
    )


def downgrade() -> None:
    bind = op.get_bind()
    op.drop_table('collection_places')
    op.drop_table('favorites')
    op.drop_index('ix_search_history_user_id', table_name='search_history')
    op.drop_table('search_history')
    op.drop_index('ix_reviews_user_id', table_name='reviews')
    op.drop_index('ix_reviews_place_id', table_name='reviews')
    op.drop_table('reviews')
    op.drop_index('ix_notifications_user_id', table_name='notifications')
    op.drop_table('notifications')
    op.drop_index('ix_collections_user_id', table_name='collections')
    op.drop_table('collections')
    op.drop_index('ix_menu_items_place_id', table_name='menu_items')
    op.drop_table('menu_items')
    op.drop_index('ix_opening_hours_place_id', table_name='opening_hours')
    op.drop_table('opening_hours')
    op.drop_index('ix_places_category', table_name='places')
    op.drop_index('ix_places_name', table_name='places')
    op.drop_table('places')
    op.drop_index('ix_users_email', table_name='users')
    op.drop_table('users')
    notification_type.drop(bind, checkfirst=True)
    place_status.drop(bind, checkfirst=True)
    budget_range.drop(bind, checkfirst=True)
    company_type.drop(bind, checkfirst=True)