import requests
import os
from dotenv import load_dotenv

load_dotenv()

# YouTrack config
YOUTRACK_URL = os.getenv("YOUTRACK_URL")
YOUTRACK_TOKEN = os.getenv("YOUTRACK_TOKEN")

# GitHub config
GITHUB_REPO = os.getenv("GITHUB_REPO")
GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")

headers_yt = {
    "Authorization": f"Bearer {YOUTRACK_TOKEN}",
    "Accept": "application/json"
}

headers_gh = {
    "Authorization": f"token {GITHUB_TOKEN}",
    "Accept": "application/vnd.github+json"
}


def get_youtrack_issues():
    fields = "id,idReadable,summary,comments(text,author(name),created)," \
             "tags(name),customFields(name,value(name))"
    url = f"https://skylight-dibbs.youtrack.cloud/api/issues?fields={fields}"   
    res = requests.get(url, headers=headers_yt)
    res.raise_for_status()
    return res.json()

#url = f"https://{YOUTRACK_URL}/api/issues?fields={fields}"

def find_github_issue_by_title(title):
    url = f"https://api.github.com/search/issues"
    params = {
        "q": f'repo:{GITHUB_REPO} "{title}" in:title',
    }
    res = requests.get(url, headers=headers_gh, params=params)
    res.raise_for_status()
    items = res.json().get("items", [])
    return items[0] if items else None


def sync_comments(yt_issue, gh_issue):
    yt_comments = yt_issue.get("comments", [])
    gh_comments_url = gh_issue["comments_url"]
    res = requests.get(gh_comments_url, headers=headers_gh)
    res.raise_for_status()
    gh_comments = res.json()
    existing_gh_comments_text = {c["body"] for c in gh_comments}

    for comment in yt_comments:
        text = f"(from {comment['author']['name']} at YouTrack)\n{comment['text']}"
        if text not in existing_gh_comments_text:
            print(f"Posting comment to GitHub issue #{gh_issue['number']}")
            requests.post(
                gh_comments_url,
                headers=headers_gh,
                json={"body": text}
            )


def extract_labels_and_status(yt_issue):
    tags = [tag["name"] for tag in yt_issue.get("tags", [])]
    status = None
    for field in yt_issue.get("customFields", []):
        if field["name"].lower() in {"state", "status"}:
            value = field.get("value")
            if value and "name" in value:
                status = f"status: {value['name']}"
                break
    labels = tags + ([status] if status else [])
    return labels


def sync_labels(gh_issue, labels):
    issue_number = gh_issue["number"]
    url = f"https://api.github.com/repos/{GITHUB_REPO}/issues/{issue_number}/labels"
    existing_labels = [l["name"] for l in requests.get(url, headers=headers_gh).json()]
    new_labels = list(set(existing_labels + labels))
    print(f"Updating labels on GitHub issue #{issue_number}: {new_labels}")
    res = requests.put(url, headers=headers_gh, json=new_labels)
    res.raise_for_status()


def main():
    yt_issues = get_youtrack_issues()
    for yt in yt_issues:
        title = yt["summary"]
        print(f"Matching YouTrack issue: {title}")
        gh_issue = find_github_issue_by_title(title)
        if gh_issue:
            sync_comments(yt, gh_issue)
            labels = extract_labels_and_status(yt)
            if labels:
                sync_labels(gh_issue, labels)
        else:
            print(f"No GitHub issue found for: {title}")


if __name__ == "__main__":
    main()
