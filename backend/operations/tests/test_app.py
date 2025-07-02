import unittest
import json
import tempfile
import os
from app import app
from business_logic.database import TaskDatabase


class TestFlaskApp(unittest.TestCase):
    
    def setUp(self):
        """Set up test client and database"""
        # Create temporary database
        self.db_fd, self.db_path = tempfile.mkstemp()
        
        # Patch the database in the app
        app.config['TESTING'] = True
        app.config['DATABASE'] = self.db_path
        
        # Replace the global db with test database
        import app as app_module
        app_module.db = TaskDatabase(self.db_path)
        
        self.client = app.test_client()
    
    def tearDown(self):
        """Clean up after tests"""
        os.close(self.db_fd)
        os.unlink(self.db_path)
    
    def test_health_check(self):
        """Test health check endpoint"""
        response = self.client.get('/health')
        self.assertEqual(response.status_code, 200)
        
        data = json.loads(response.data)
        self.assertEqual(data['status'], 'healthy')
        self.assertIn('timestamp', data)
    
    def test_create_task_success(self):
        """Test creating a task successfully"""
        task_data = {
            'title': 'Test Task',
            'time_limit_minutes': 30
        }
        
        response = self.client.post('/tasks', 
                                   data=json.dumps(task_data),
                                   content_type='application/json')
        
        self.assertEqual(response.status_code, 201)
        
        data = json.loads(response.data)
        self.assertEqual(data['message'], 'Task created successfully')
        self.assertIn('task', data)
        self.assertEqual(data['task']['title'], 'Test Task')
        self.assertEqual(data['task']['time_limit_minutes'], 30)
        self.assertEqual(data['task']['status'], 'active')
    
    def test_create_task_missing_data(self):
        """Test creating task with missing data"""
        task_data = {'title': 'Test Task'}  # Missing time_limit_minutes
        
        response = self.client.post('/tasks',
                                   data=json.dumps(task_data),
                                   content_type='application/json')
        
        self.assertEqual(response.status_code, 400)
        
        data = json.loads(response.data)
        self.assertIn('error', data)
    
    def test_create_task_empty_title(self):
        """Test creating task with empty title"""
        task_data = {
            'title': '   ',  # Empty/whitespace title
            'time_limit_minutes': 30
        }
        
        response = self.client.post('/tasks',
                                   data=json.dumps(task_data),
                                   content_type='application/json')
        
        self.assertEqual(response.status_code, 400)
        
        data = json.loads(response.data)
        self.assertEqual(data['error'], 'Title cannot be empty')
    
    def test_create_task_invalid_time_limit(self):
        """Test creating task with invalid time limit"""
        task_data = {
            'title': 'Test Task',
            'time_limit_minutes': 0  # Invalid time limit
        }
        
        response = self.client.post('/tasks',
                                   data=json.dumps(task_data),
                                   content_type='application/json')
        
        self.assertEqual(response.status_code, 400)
        
        data = json.loads(response.data)
        self.assertEqual(data['error'], 'Time limit must be positive')
    
    def test_get_all_tasks_empty(self):
        """Test getting all tasks when database is empty"""
        response = self.client.get('/tasks')
        self.assertEqual(response.status_code, 200)
        
        data = json.loads(response.data)
        self.assertEqual(len(data['active']), 0)
        self.assertEqual(len(data['completed']), 0)
        self.assertEqual(len(data['missed']), 0)
    
    def test_get_all_tasks_with_data(self):
        """Test getting all tasks with data"""
        # Create test tasks
        task1_data = {'title': 'Task 1', 'time_limit_minutes': 30}
        task2_data = {'title': 'Task 2', 'time_limit_minutes': 45}
        
        self.client.post('/tasks', data=json.dumps(task1_data), content_type='application/json')
        self.client.post('/tasks', data=json.dumps(task2_data), content_type='application/json')
        
        response = self.client.get('/tasks')
        self.assertEqual(response.status_code, 200)
        
        data = json.loads(response.data)
        self.assertEqual(len(data['active']), 2)
        self.assertEqual(len(data['completed']), 0)
        self.assertEqual(len(data['missed']), 0)
    
    def test_get_task_by_id(self):
        """Test getting specific task by ID"""
        # Create a task first
        task_data = {'title': 'Find Me', 'time_limit_minutes': 30}
        create_response = self.client.post('/tasks', 
                                          data=json.dumps(task_data),
                                          content_type='application/json')
        created_task = json.loads(create_response.data)['task']
        task_id = created_task['id']
        
        # Get the task
        response = self.client.get(f'/tasks/{task_id}')
        self.assertEqual(response.status_code, 200)
        
        data = json.loads(response.data)
        self.assertEqual(data['task']['id'], task_id)
        self.assertEqual(data['task']['title'], 'Find Me')
    
    def test_get_task_not_found(self):
        """Test getting non-existent task"""
        response = self.client.get('/tasks/999')
        self.assertEqual(response.status_code, 404)
        
        data = json.loads(response.data)
        self.assertEqual(data['error'], 'Task not found')
    
    def test_complete_task(self):
        """Test completing a task"""
        # Create a task first
        task_data = {'title': 'Complete Me', 'time_limit_minutes': 30}
        create_response = self.client.post('/tasks',
                                          data=json.dumps(task_data),
                                          content_type='application/json')
        created_task = json.loads(create_response.data)['task']
        task_id = created_task['id']
        
        # Complete the task
        response = self.client.put(f'/tasks/{task_id}/complete')
        self.assertEqual(response.status_code, 200)
        
        data = json.loads(response.data)
        self.assertEqual(data['message'], 'Task completed successfully')
        self.assertEqual(data['task']['status'], 'completed')
    
    def test_complete_nonexistent_task(self):
        """Test completing non-existent task"""
        response = self.client.put('/tasks/999/complete')
        self.assertEqual(response.status_code, 404)
        
        data = json.loads(response.data)
        self.assertEqual(data['error'], 'Task not found')
    
    def test_delete_task(self):
        """Test deleting a task"""
        # Create a task first
        task_data = {'title': 'Delete Me', 'time_limit_minutes': 30}
        create_response = self.client.post('/tasks',
                                          data=json.dumps(task_data),
                                          content_type='application/json')
        created_task = json.loads(create_response.data)['task']
        task_id = created_task['id']
        
        # Delete the task
        response = self.client.delete(f'/tasks/{task_id}')
        self.assertEqual(response.status_code, 200)
        
        data = json.loads(response.data)
        self.assertEqual(data['message'], 'Task deleted successfully')
        
        # Verify task is gone
        get_response = self.client.get(f'/tasks/{task_id}')
        self.assertEqual(get_response.status_code, 404)
    
    def test_delete_nonexistent_task(self):
        """Test deleting non-existent task"""
        response = self.client.delete('/tasks/999')
        self.assertEqual(response.status_code, 404)
        
        data = json.loads(response.data)
        self.assertEqual(data['error'], 'Task not found')
    
    def test_get_task_stats_empty(self):
        """Test getting stats with no tasks"""
        response = self.client.get('/tasks/stats')
        self.assertEqual(response.status_code, 200)
        
        data = json.loads(response.data)
        self.assertEqual(data['total_tasks'], 0)
        self.assertEqual(data['active_tasks'], 0)
        self.assertEqual(data['completed_tasks'], 0)
        self.assertEqual(data['missed_tasks'], 0)
        self.assertEqual(data['completion_rate'], 0)
    
    def test_get_task_stats_with_data(self):
        """Test getting stats with tasks"""
        # Create and complete some tasks
        task1_data = {'title': 'Task 1', 'time_limit_minutes': 30}
        task2_data = {'title': 'Task 2', 'time_limit_minutes': 45}
        
        # Create tasks
        create1 = self.client.post('/tasks', data=json.dumps(task1_data), content_type='application/json')
        create2 = self.client.post('/tasks', data=json.dumps(task2_data), content_type='application/json')
        
        task1_id = json.loads(create1.data)['task']['id']
        
        # Complete one task
        self.client.put(f'/tasks/{task1_id}/complete')
        
        # Get stats
        response = self.client.get('/tasks/stats')
        self.assertEqual(response.status_code, 200)
        
        data = json.loads(response.data)
        self.assertEqual(data['total_tasks'], 2)
        self.assertEqual(data['active_tasks'], 1)
        self.assertEqual(data['completed_tasks'], 1)
        self.assertEqual(data['missed_tasks'], 0)
        self.assertEqual(data['completion_rate'], 50.0)
