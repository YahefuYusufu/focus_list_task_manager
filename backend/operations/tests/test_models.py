import unittest
import os
import sys
import tempfile
from datetime import datetime, timedelta

# Add parent directory to path for imports
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from business_logic.database import TaskDatabase
from application_server.models import Task


class TestTaskDatabase(unittest.TestCase):
    
    def setUp(self):
        """Set up test database before each test"""
        # Create temporary database file
        self.db_fd, self.db_path = tempfile.mkstemp()
        self.db = TaskDatabase(self.db_path)
    
    def tearDown(self):
        """Clean up after each test"""
        os.close(self.db_fd)
        os.unlink(self.db_path)
    
    def test_init_database(self):
        """Test database initialization"""
        # Database should be created and accessible
        tasks = self.db.get_all_tasks()
        self.assertEqual(len(tasks), 0)
    
    def test_add_task(self):
        """Test adding a new task"""
        task = self.db.add_task("Test Task", 30)
        
        self.assertIsNotNone(task.id)
        self.assertEqual(task.title, "Test Task")
        self.assertEqual(task.time_limit_minutes, 30)
        self.assertEqual(task.status, "active")
        self.assertIsInstance(task.created_at, datetime)
    
    def test_add_multiple_tasks(self):
        """Test adding multiple tasks"""
        task1 = self.db.add_task("Task 1", 15)
        task2 = self.db.add_task("Task 2", 45)
        
        self.assertNotEqual(task1.id, task2.id)
        
        tasks = self.db.get_all_tasks()
        self.assertEqual(len(tasks), 2)
    
    def test_get_all_tasks(self):
        """Test retrieving all tasks"""
        # Add test tasks
        self.db.add_task("Task 1", 30)
        self.db.add_task("Task 2", 60)
        
        tasks = self.db.get_all_tasks()
        self.assertEqual(len(tasks), 2)
        
        # Should be ordered by created_at DESC (newest first)
        self.assertEqual(tasks[0].title, "Task 2")
        self.assertEqual(tasks[1].title, "Task 1")
    
    def test_get_task_by_id(self):
        """Test retrieving task by ID"""
        created_task = self.db.add_task("Find Me", 25)
        
        found_task = self.db.get_task_by_id(created_task.id)
        
        self.assertIsNotNone(found_task)
        self.assertEqual(found_task.id, created_task.id)
        self.assertEqual(found_task.title, "Find Me")
        self.assertEqual(found_task.time_limit_minutes, 25)
    
    def test_get_task_by_invalid_id(self):
        """Test retrieving task with invalid ID"""
        task = self.db.get_task_by_id(999)
        self.assertIsNone(task)
    
    def test_update_task_status(self):
        """Test updating task status"""
        task = self.db.add_task("Status Test", 30)
        
        # Update to completed
        success = self.db.update_task_status(task.id, "completed")
        self.assertTrue(success)
        
        # Verify update
        updated_task = self.db.get_task_by_id(task.id)
        self.assertEqual(updated_task.status, "completed")
    
    def test_update_task_status_invalid_id(self):
        """Test updating status of non-existent task"""
        success = self.db.update_task_status(999, "completed")
        self.assertFalse(success)
    
    def test_delete_task(self):
        """Test deleting a task"""
        task = self.db.add_task("Delete Me", 30)
        
        # Verify task exists
        found_task = self.db.get_task_by_id(task.id)
        self.assertIsNotNone(found_task)
        
        # Delete task
        success = self.db.delete_task(task.id)
        self.assertTrue(success)
        
        # Verify task is gone
        deleted_task = self.db.get_task_by_id(task.id)
        self.assertIsNone(deleted_task)
    
    def test_delete_task_invalid_id(self):
        """Test deleting non-existent task"""
        success = self.db.delete_task(999)
        self.assertFalse(success)
    
    def test_task_status_transitions(self):
        """Test various status transitions"""
        task = self.db.add_task("Status Transitions", 30)
        
        # Active -> Completed
        self.db.update_task_status(task.id, "completed")
        updated_task = self.db.get_task_by_id(task.id)
        self.assertEqual(updated_task.status, "completed")
        
        # Completed -> Missed (unusual but possible)
        self.db.update_task_status(task.id, "missed")
        updated_task = self.db.get_task_by_id(task.id)
        self.assertEqual(updated_task.status, "missed")
