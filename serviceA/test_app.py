import unittest
from app import app

class TestServiceA(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.client = app.test_client()

    def test_create_user(self):
        response = self.client.post('/user', json={"id": "1", "name": "John"})
        self.assertEqual(response.status_code, 201)
        self.assertIn('User created', response.get_data(as_text=True))

    def test_get_user(self):
        self.client.post('/user', json={"id": "2", "name": "Jane"})
        response = self.client.get('/user/2')
        self.assertEqual(response.status_code, 200)
        self.assertIn('Jane', response.get_data(as_text=True))

    def test_user_not_found(self):
        response = self.client.get('/user/999')
        self.assertEqual(response.status_code, 404)
        self.assertIn('User not found', response.get_data(as_text=True))

if __name__ == '__main__':
    unittest.main()
