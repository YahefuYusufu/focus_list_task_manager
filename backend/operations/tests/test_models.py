"""
Unit tests for Task model
"""
import unittest
import sys
sys.path.append('.')
from datetime import datetime, timedelta
from application_server.models import Task

class TestTaskModel(unittest.TestCase):
    def setUp(self):
        self.task = Task(
            id=1,
            title="Test Task",
            time_limit_minutes=30
        )
    
    def test_task_creation(self):
        self.assertEqual(self.task.id, 1)
        self.assertEqual(self.task.title, "Test Task")
        self.assertEqual(self.task.time_limit_minutes, 30)
        self.assertEqual(self.task.status, "active")
    
    def test_remaining_seconds(self):
        remaining = self.task.get_remaining_seconds()
        self.assertGreater(remaining, 0)
        self.assertLessEqual(remaining, 30 * 60)
    
    def test_task_expiry(self):
        # Create a task that should be expired
        expired_task = Task(
            id=2,
            title="Expired Task",
            time_limit_minutes=0.01,  # Very short time
            created_at=datetime.now() - timedelta(minutes=1)
        )
        self.assertTrue(expired_task.is_expired())

if __name__ == '__main__':
    unittest.main()
