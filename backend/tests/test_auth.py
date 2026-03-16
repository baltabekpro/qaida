from __future__ import annotations


def test_register_and_auth_me(client):
    register_response = client.post(
        '/api/v1/auth/register',
        json={'name': 'Test User', 'email': 'user@example.com', 'password': 'password123'},
    )

    assert register_response.status_code == 201
    tokens = register_response.json()
    access_token = tokens['accessToken']

    me_response = client.get('/api/v1/auth/me', headers={'Authorization': f'Bearer {access_token}'})

    assert me_response.status_code == 200
    assert me_response.json()['email'] == 'user@example.com'


def test_refresh_rotation_and_reuse_detection_revokes_family(client):
    login_response = client.post(
        '/api/v1/auth/login',
        json={'email': 'demo@qaida.app', 'password': 'qaida-demo'},
    )
    assert login_response.status_code == 200
    initial_tokens = login_response.json()

    refresh_response = client.post(
        '/api/v1/auth/refresh',
        json={'refreshToken': initial_tokens['refreshToken']},
    )
    assert refresh_response.status_code == 200
    rotated_tokens = refresh_response.json()

    reused_response = client.post(
        '/api/v1/auth/refresh',
        json={'refreshToken': initial_tokens['refreshToken']},
    )
    assert reused_response.status_code == 401
    assert reused_response.json()['code'] == 'refresh_token_reuse_detected'

    family_revoked_response = client.post(
        '/api/v1/auth/refresh',
        json={'refreshToken': rotated_tokens['refreshToken']},
    )
    assert family_revoked_response.status_code == 401
    assert family_revoked_response.json()['code'] == 'revoked_refresh_family'


def test_logout_revokes_access_and_refresh_tokens(client):
    login_response = client.post(
        '/api/v1/auth/login',
        json={'email': 'demo@qaida.app', 'password': 'qaida-demo'},
    )
    assert login_response.status_code == 200
    tokens = login_response.json()
    headers = {'Authorization': f"Bearer {tokens['accessToken']}"}

    logout_response = client.post('/api/v1/auth/logout', json={'refreshToken': tokens['refreshToken']}, headers=headers)
    assert logout_response.status_code == 200
    assert logout_response.json()['accepted'] is True

    me_response = client.get('/api/v1/auth/me', headers=headers)
    assert me_response.status_code == 401

    refresh_response = client.post('/api/v1/auth/refresh', json={'refreshToken': tokens['refreshToken']})
    assert refresh_response.status_code == 401


def test_health_reports_database_and_redis(client):
    response = client.get('/health')

    assert response.status_code == 200
    payload = response.json()
    assert payload['status'] == 'ok'
    assert payload['services']['database']['status'] == 'ok'
    assert payload['services']['redis']['status'] == 'ok'