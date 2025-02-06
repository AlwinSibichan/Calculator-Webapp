import json
import pytest
from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_index_route(client):
    """Test the index route returns HTTP 200"""
    response = client.get('/')
    assert response.status_code == 200

def test_calculate_addition(client):
    """Test the addition operation"""
    response = client.post('/calculate',
                         data=json.dumps({'num1': 5, 'num2': 3, 'operation': 'add'}),
                         content_type='application/json')
    data = json.loads(response.data)
    assert response.status_code == 200
    assert data['result'] == 8

def test_calculate_division_by_zero(client):
    """Test division by zero error handling"""
    response = client.post('/calculate',
                         data=json.dumps({'num1': 5, 'num2': 0, 'operation': 'divide'}),
                         content_type='application/json')
    assert response.status_code == 400
    data = json.loads(response.data)
    assert 'error' in data
    assert 'Division by zero' in data['error'] 