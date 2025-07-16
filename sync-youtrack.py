#!/usr/bin/env python3
"""
YouTrack to GitHub Issues Sync Script
Syncs issues, status changes, comments, and assignee changes from YouTrack to GitHub Issues
"""

import os
import json
import logging
import requests
from datetime import datetime, timezone
from typing import Dict, List, Optional, Any

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Configuration from environment variables
YOUTRACK_BASE_URL = os.getenv('YOUTRACK_BASE_URL')
YOUTRACK_TOKEN = os.getenv('YOUTRACK_TOKEN')
YOUTRACK_GITHUB_TOKEN = os.getenv('YOUTRACK_GITHUB_TOKEN')
PROJECT_ID = os.getenv('PROJECT_ID')
GITHUB_REPOSITORY = os.getenv('GITHUB_REPOSITORY')

# State file to track last sync
STATE_FILE = 'sync-youtrack-state.json'

class YouTrackGitHubSync:
    def __init__(self):
        self.youtrack_session = requests.Session()
        self.youtrack_session.headers.update({
            'Authorization': f'Bearer {YOUTRACK_TOKEN}',
            'Accept': 'application/json',
            'Content-Type': 'application/json'
        })
        
        self.github_session = requests.Session()
        self.github_session.headers.update({
            'Authorization': f'token {YOUTRACK_GITHUB_TOKEN}',
            'Accept': 'application/vnd.github.v3+json'
        })
        
        self.state = self.load_sync_state()
    
    def load_sync_state(self) -> Dict[str, Any]:
        """Load or initialize sync state"""
        try:
            if os.path.exists(STATE_FILE):
                with open(STATE_FILE, 'r') as f:
                    return json.load(f)
        except Exception as e:
            logger.warning(f'Could not load sync state: {e}. Starting fresh.')
        
        return {
            'last_sync': 0,
            'issue_mapping': {}  # YouTrack ID -> GitHub issue number
        }
    
    def save_sync_state(self):
        """Save sync state to file"""
        try:
            with open(STATE_FILE, 'w') as f:
                json.dump(self.state, f, indent=2)
        except Exception as e:
            logger.error(f'Failed to save sync state: {e}')
    
    def map_youtrack_status_to_github(self, youtrack_status: str) -> str:
        """Map YouTrack status to GitHub state"""
        status_map = {
            'Open': 'open',
            'In Progress': 'open',
            'To be discussed': 'open',
            'Reopened': 'open',
            'Ready for Review': 'open',
            'Fixed': 'closed',
            'Resolved': 'closed',
            'Closed': 'closed',
            'Won\'t fix': 'closed',
            'Duplicate': 'closed',
            'Incomplete': 'closed',
            'Done': 'closed'
        }
        return status_map.get(youtrack_status, 'open')
    
    def get_updated_youtrack_issues(self, last_sync: int) -> List[Dict]:
        """Get YouTrack issues updated since last sync"""
        try:
            query = f'project: {PROJECT_ID} updated: {last_sync}..'
            params = {
                'query': query,
                'fields': 'id,idReadable,summary,description,state(name),assignee(login,fullName),reporter(login,fullName),created,updated,comments(id,text,author(login,fullName),created,updated)'
            }
            
            response = self.youtrack_session.get(
                f'{YOUTRACK_BASE_URL}/api/issues',
                params=params
            )
            response.raise_for_status()
            
            issues = response.json()
            logger.info(f'Retrieved {len(issues)} updated YouTrack issues')
            return issues
            
        except requests.exceptions.RequestException as e:
            logger.error(f'Error fetching YouTrack issues: {e}')
            return []
    
    def create_github_issue(self, yt_issue: Dict) -> Optional[int]:
        """Create GitHub issue from YouTrack issue"""
        try:
            # Format issue body
            created_date = datetime.fromtimestamp(yt_issue['created'] / 1000, tz=timezone.utc).isoformat()
            reporter = yt_issue.get('reporter', {}).get('fullName', 'Unknown')
            description = yt_issue.get('description', 'No description provided')
            
            body = f"""**YouTrack Issue:** {yt_issue['idReadable']}
**Reporter:** {reporter}
**Created:** {created_date}

---

{description}

---
*This issue was automatically synced from YouTrack*"""
            
            # Prepare issue data
            issue_data = {
                'title': f"[{yt_issue['idReadable']}] {yt_issue['summary']}",
                'body': body,
                'state': self.map_youtrack_status_to_github(yt_issue.get('state', {}).get('name', 'Open')),
                'labels': ['youtrack-sync']
            }
            
            # Add assignee if exists
            assignee = yt_issue.get('assignee', {}).get('login')
            if assignee:
                issue_data['assignee'] = assignee
            
            # Create the issue
            response = self.github_session.post(
                f'https://api.github.com/repos/{GITHUB_REPOSITORY}/issues',
                json=issue_data
            )
            response.raise_for_status()
            
            issue_number = response.json()['number']
            logger.info(f'Created GitHub issue #{issue_number} for YouTrack {yt_issue["idReadable"]}')
            return issue_number
            
        except requests.exceptions.RequestException as e:
            logger.error(f'Error creating GitHub issue for {yt_issue["idReadable"]}: {e}')
            return None
    
    def update_github_issue(self, github_issue_number: int, yt_issue: Dict):
        """Update existing GitHub issue"""
        try:
            update_data = {
                'state': self.map_youtrack_status_to_github(yt_issue.get('state', {}).get('name', 'Open'))
            }
            
            # Update assignee if exists
            assignee = yt_issue.get('assignee', {}).get('login')
            if assignee:
                update_data['assignee'] = assignee
            
            response = self.github_session.patch(
                f'https://api.github.com/repos/{GITHUB_REPOSITORY}/issues/{github_issue_number}',
                json=update_data
            )
            response.raise_for_status()
            
            logger.info(f'Updated GitHub issue #{github_issue_number} for YouTrack {yt_issue["idReadable"]}')
            
        except requests.exceptions.RequestException as e:
            logger.error(f'Error updating GitHub issue #{github_issue_number}: {e}')
    
    def sync_comments(self, github_issue_number: int, yt_issue: Dict, last_sync: int):
        """Sync comments from YouTrack to GitHub"""
        try:
            # Get existing GitHub comments
            response = self.github_session.get(
                f'https://api.github.com/repos/{GITHUB_REPOSITORY}/issues/{github_issue_number}/comments'
            )
            response.raise_for_status()
            
            existing_comments = set()
            for comment in response.json():
                # Extract YouTrack comment ID from comment body
                if '**YouTrack Comment ID:**' in comment['body']:
                    lines = comment['body'].split('\n')
                    for line in lines:
                        if '**YouTrack Comment ID:**' in line:
                            comment_id = line.split('**YouTrack Comment ID:**')[1].strip()
                            existing_comments.add(comment_id)
                            break
            
            # Add new comments from YouTrack
            yt_comments = yt_issue.get('comments', [])
            new_comments = [
                comment for comment in yt_comments
                if comment.get('updated', 0) > last_sync and comment.get('id') not in existing_comments
            ]
            
            for comment in new_comments:
                author = comment.get('author', {}).get('fullName', 'Unknown')
                created_date = datetime.fromtimestamp(comment['created'] / 1000, tz=timezone.utc).isoformat()
                
                comment_body = f"""**YouTrack Comment ID:** {comment['id']}
**Author:** {author}
**Created:** {created_date}

---

{comment.get('text', '')}"""
                
                comment_response = self.github_session.post(
                    f'https://api.github.com/repos/{GITHUB_REPOSITORY}/issues/{github_issue_number}/comments',
                    json={'body': comment_body}
                )
                comment_response.raise_for_status()
                
                logger.info(f'Added comment to GitHub issue #{github_issue_number}')
                
        except requests.exceptions.RequestException as e:
            logger.error(f'Error syncing comments for issue #{github_issue_number}: {e}')
    
    def sync_issues(self):
        """Main sync function"""
        logger.info('Starting YouTrack to GitHub sync...')
        
        last_sync = self.state['last_sync']
        current_time = int(datetime.now(timezone.utc).timestamp() * 1000)  # milliseconds
        
        try:
            # Get updated YouTrack issues
            yt_issues = self.get_updated_youtrack_issues(last_sync)
            
            for yt_issue in yt_issues:
                yt_issue_id = yt_issue['id']
                github_issue_number = self.state['issue_mapping'].get(yt_issue_id)
                
                if not github_issue_number:
                    # Create new GitHub issue
                    new_issue_number = self.create_github_issue(yt_issue)
                    if new_issue_number:
                        self.state['issue_mapping'][yt_issue_id] = new_issue_number
                        
                        # Sync comments for new issue
                        self.sync_comments(new_issue_number, yt_issue, 0)
                else:
                    # Update existing GitHub issue
                    self.update_github_issue(github_issue_number, yt_issue)
                    
                    # Sync new comments
                    self.sync_comments(github_issue_number, yt_issue, last_sync)
            
            # Update last sync time
            self.state['last_sync'] = current_time
            self.save_sync_state()
            
            logger.info('Sync completed successfully')
            
        except Exception as e:
            logger.error(f'Sync failed: {e}')
            raise

def main():
    """Main entry point"""
    # Validate required environment variables
    required_vars = ['YOUTRACK_BASE_URL', 'YOUTRACK_TOKEN', 'YOUTRACK_GITHUB_TOKEN', 'PROJECT_ID', 'GITHUB_REPOSITORY']
    missing_vars = [var for var in required_vars if not os.getenv(var)]
    
    if missing_vars:
        logger.error(f'Missing required environment variables: {", ".join(missing_vars)}')
        return 1
    
    try:
        sync = YouTrackGitHubSync()
        sync.sync_issues()
        return 0
    except Exception as e:
        logger.error(f'Script failed: {e}')
        return 1

if __name__ == '__main__':
    exit(main())