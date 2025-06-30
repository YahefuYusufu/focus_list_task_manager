from datetime import datetime, timedelta
from typing import Dict, Any

class Task:
    def __init__(self, id: int, title: str, time_limit_minutes: int, 
                 created_at: datetime = None, status: str = 'active'):
        self.id = id
        self.title = title
        self.time_limit_minutes = time_limit_minutes
        self.created_at = created_at or datetime.now()
        self.status = status
        self.expires_at = self.created_at + timedelta(minutes=time_limit_minutes)
    
    def to_dict(self) -> Dict[str, Any]:
        return {
            'id': self.id,
            'title': self.title,
            'time_limit_minutes': self.time_limit_minutes,
            'created_at': self.created_at.isoformat(),
            'expires_at': self.expires_at.isoformat(),
            'status': self.status,
            'remaining_seconds': self.get_remaining_seconds()
        }
    
    def get_remaining_seconds(self) -> int:
        if self.status != 'active':
            return 0
        remaining = (self.expires_at - datetime.now()).total_seconds()
        return max(0, int(remaining))
    
    def is_expired(self) -> bool:
        return self.status == 'active' and datetime.now() >= self.expires_at
    
    def mark_completed(self):
        self.status = 'completed'
    
    def mark_missed(self):
        self.status = 'missed'
