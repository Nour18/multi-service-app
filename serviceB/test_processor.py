import unittest
from processor import app
from unittest.mock import patch

class TestServiceB(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.client = app.test_client()

    @patch('processor.requests.get')
    def test_process_user_valid(self, mock_get):
        mock_get.return_value.status_code = 200
        mock_get.return_value.json.return_value = {'id': '1', 'name': 'John'}

        response = self.client.get('/process/1')
        self.assertEqual(response.status_code, 200)
        self.assertIn('JOHN', response.get_data(as_text=True))
    @patch('processor.requests.get')
    def test_process_user_not_found(self, mock_get):
        # Mock a 404 response from Service A for user not found
        mock_get.return_value.status_code = 404
        response = self.client.get('/process/999')
        self.assertEqual(response.status_code, 404)
        self.assertIn('User not found', response.get_data(as_text=True))
if __name__ == '__main__':
    unittest.main()