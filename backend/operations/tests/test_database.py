"""
Unit tests for Database operations
"""
import unittest
import os
import sys
sys.path.append('.')
from business_logic.database import TaskDatabase

class TestTaskDatabase(unittest.TestCase):
    def setUp(self):
        self.test_db = TaskDatabase('test_tasks.db')
    
    def tearDown(self):
        if os.path.exists('test_tasks.db'):
            os.remove('test_tasks.db')
    
    def test_add_task(self):
        task = self.test_db.add_task("Test Task", 30)
        self.assertIsNotNone(task)
        self.assertEqual(task.title, "Test Task")
        self.assertEqual(task.time_limit_minutes, 30)
        self.assertEqual(task.status, "active")

if __name__ == '__main__':
    unittest.main()
