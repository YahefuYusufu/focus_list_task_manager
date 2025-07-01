from flask import Flask, request, jsonify
from flask_cors import CORS
from datetime import datetime
from application_server.models import Task
from business_logic.database import TaskDatabase

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter app

# Initialize database
db = TaskDatabase()

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({'status': 'healthy', 'timestamp': datetime.now().isoformat()})

@app.route('/tasks', methods=['POST'])
def create_task():
    try:
        data = request.get_json()
        
        if not data or 'title' not in data or 'time_limit_minutes' not in data:
            return jsonify({'error': 'Missing title or time_limit_minutes'}), 400
        
        title = data['title'].strip()
        time_limit_minutes = int(data['time_limit_minutes'])
        
        if not title:
            return jsonify({'error': 'Title cannot be empty'}), 400
        
        if time_limit_minutes <= 0:
            return jsonify({'error': 'Time limit must be positive'}), 400
        
        task = db.add_task(title, time_limit_minutes)
        
        return jsonify({
            'message': 'Task created successfully',
            'task': task.to_dict()
        }), 201
        
    except ValueError:
        return jsonify({'error': 'Invalid time_limit_minutes format'}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/tasks', methods=['GET'])
def get_tasks():
    try:
        tasks = db.get_all_tasks()
        
        # Check for expired tasks and update them
        for task in tasks:
            if task.is_expired() and task.status == 'active':
                task.mark_missed()
                db.update_task_status(task.id, 'missed')
        
        # Group tasks by status
        active_tasks = [task.to_dict() for task in tasks if task.status == 'active']
        completed_tasks = [task.to_dict() for task in tasks if task.status == 'completed']
        missed_tasks = [task.to_dict() for task in tasks if task.status == 'missed']
        
        return jsonify({
            'active': active_tasks,
            'completed': completed_tasks,
            'missed': missed_tasks
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/tasks/<int:task_id>', methods=['GET'])
def get_task(task_id):
    """Get a specific task by ID"""
    try:
        task = db.get_task_by_id(task_id)
        
        if not task:
            return jsonify({'error': 'Task not found'}), 404
        
        # Check if task expired
        if task.is_expired() and task.status == 'active':
            task.mark_missed()
            db.update_task_status(task.id, 'missed')
        
        return jsonify({'task': task.to_dict()})
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/tasks/<int:task_id>/complete', methods=['PUT'])
def complete_task(task_id):
    try:
        task = db.get_task_by_id(task_id)
        
        if not task:
            return jsonify({'error': 'Task not found'}), 404
        
        if task.status != 'active':
            return jsonify({'error': f'Task is already {task.status}'}), 400
        
        if task.is_expired():
            db.update_task_status(task_id, 'missed')
            return jsonify({
                'message': 'Task was expired and marked as missed',
                'task': task.to_dict()
            }), 200
        
        db.update_task_status(task_id, 'completed')
        task.mark_completed()
        
        return jsonify({
            'message': 'Task completed successfully',
            'task': task.to_dict()
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/tasks/<int:task_id>/check-expiry', methods=['PUT'])
def check_task_expiry(task_id):
    """Check and update task expiry status"""
    try:
        task = db.get_task_by_id(task_id)
        
        if not task:
            return jsonify({'error': 'Task not found'}), 404
        
        if task.is_expired() and task.status == 'active':
            task.mark_missed()
            db.update_task_status(task_id, 'missed')
            
            return jsonify({
                'message': 'Task expired and marked as missed',
                'task': task.to_dict(),
                'status_changed': True
            })
        
        return jsonify({
            'message': 'Task status unchanged',
            'task': task.to_dict(),
            'status_changed': False
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/tasks/<int:task_id>', methods=['DELETE'])
def delete_task(task_id):
    """Delete a task"""
    try:
        print(f"🗑️ Attempting to delete task with ID: {task_id}")
        success = db.delete_task(task_id)
        print(f"🗑️ Delete operation success: {success}")
        
        if not success:
            return jsonify({'error': 'Task not found'}), 404
        
        return jsonify({'message': 'Task deleted successfully'})
        
    except Exception as e:
        print(f"❌ Error deleting task: {str(e)}")  # This will show in server logs
        return jsonify({'error': str(e)}), 500

@app.route('/tasks/stats', methods=['GET'])
def get_task_stats():
    """Get task statistics"""
    try:
        tasks = db.get_all_tasks()
        
        # Update expired tasks first
        for task in tasks:
            if task.is_expired() and task.status == 'active':
                task.mark_missed()
                db.update_task_status(task.id, 'missed')
        
        # Calculate stats
        total_tasks = len(tasks)
        active_count = len([t for t in tasks if t.status == 'active'])
        completed_count = len([t for t in tasks if t.status == 'completed'])
        missed_count = len([t for t in tasks if t.status == 'missed'])
        
        completion_rate = (completed_count / total_tasks * 100) if total_tasks > 0 else 0
        
        return jsonify({
            'total_tasks': total_tasks,
            'active_tasks': active_count,
            'completed_tasks': completed_count,
            'missed_tasks': missed_count,
            'completion_rate': round(completion_rate, 2)
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    print("🚀 Starting Task Manager Backend...")
    print("📍 Server running on http://localhost:5007")
    print("✅ Ready for Flutter app!")
    app.run(debug=True, host='0.0.0.0', port=5007)