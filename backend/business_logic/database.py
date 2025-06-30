import sqlite3
from datetime import datetime
from typing import List, Optional
from application_server.models import Task

class TaskDatabase:
    def __init__(self, db_name: str = 'tasks.db'):
        self.db_name = db_name
        self.init_database()
    
    def init_database(self):
        with sqlite3.connect(self.db_name) as conn:
            conn.execute('''
                CREATE TABLE IF NOT EXISTS tasks (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    title TEXT NOT NULL,
                    time_limit_minutes INTEGER NOT NULL,
                    created_at TEXT NOT NULL,
                    status TEXT DEFAULT 'active'
                )
            ''')
            conn.commit()
    
    def add_task(self, title: str, time_limit_minutes: int) -> Task:
        created_at = datetime.now()
        with sqlite3.connect(self.db_name) as conn:
            cursor = conn.execute('''
                INSERT INTO tasks (title, time_limit_minutes, created_at, status)
                VALUES (?, ?, ?, ?)
            ''', (title, time_limit_minutes, created_at.isoformat(), 'active'))
            task_id = cursor.lastrowid
            conn.commit()
        
        return Task(
            id=task_id,
            title=title,
            time_limit_minutes=time_limit_minutes,
            created_at=created_at,
            status='active'
        )
    
    def get_all_tasks(self) -> List[Task]:
        with sqlite3.connect(self.db_name) as conn:
            conn.row_factory = sqlite3.Row
            cursor = conn.execute('SELECT * FROM tasks ORDER BY created_at DESC')
            rows = cursor.fetchall()
        
        tasks = []
        for row in rows:
            task = Task(
                id=row['id'],
                title=row['title'],
                time_limit_minutes=row['time_limit_minutes'],
                created_at=datetime.fromisoformat(row['created_at']),
                status=row['status']
            )
            tasks.append(task)
        return tasks
    
    def get_task_by_id(self, task_id: int) -> Optional[Task]:
        with sqlite3.connect(self.db_name) as conn:
            conn.row_factory = sqlite3.Row
            cursor = conn.execute('SELECT * FROM tasks WHERE id = ?', (task_id,))
            row = cursor.fetchone()
        
        if not row:
            return None
        
        return Task(
            id=row['id'],
            title=row['title'],
            time_limit_minutes=row['time_limit_minutes'],
            created_at=datetime.fromisoformat(row['created_at']),
            status=row['status']
        )
    
    def update_task_status(self, task_id: int, status: str) -> bool:
        with sqlite3.connect(self.db_name) as conn:
            cursor = conn.execute('UPDATE tasks SET status = ? WHERE id = ?', (status, task_id))
            conn.commit()
            return cursor.rowcount > 0
