"""Copy public Base IMIS repositories into an existing GitHub organization.

Requires Python 3.11.9, PyGithub 2.5.0, and Git on PATH.
Install: python -m pip install PyGithub==2.5.0
Run: python Clone_repos.py

Copies Git history, branches and tags. Does not migrate issues, pull requests,
release attachments, settings, Git LFS objects or submodule repositories.
Existing destination repositories are skipped. No force pushes or remote deletes.
"""
import base64
from getpass import getpass, GetPassWarning
from importlib.metadata import version, PackageNotFoundError
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import warnings

SOURCE_ORG = "base-imis"


def check_environment():
    if sys.version_info[:3] != (3, 11, 9):
        raise RuntimeError(f"Use Python 3.11.9. Detected {sys.version.split()[0]}.")
    try:
        installed = version("PyGithub")
    except PackageNotFoundError:
        installed = "not installed"
    if installed != "2.5.0":
        raise RuntimeError(f"PyGithub 2.5.0 required; detected {installed}.\n"
                           "Run: python -m pip install PyGithub==2.5.0")
    if not shutil.which("git"):
        raise RuntimeError("Install Git for Windows, then reopen PowerShell.")


def redact(message, token):
    encoded = base64.b64encode(f"x-access-token:{token}".encode()).decode()
    return str(message).replace(encoded, "[REDACTED]").replace(token, "[REDACTED]")


def git_environment(token=None):
    env = os.environ.copy()
    # Credentials exist only in child-process memory, not URLs or config files.
    for key in list(env):
        if key.startswith(("GIT_CONFIG_", "GIT_TRACE")) or key in {
            "GIT_CURL_VERBOSE", "GIT_DIR", "GIT_WORK_TREE", "GIT_INDEX_FILE",
            "GIT_OBJECT_DIRECTORY", "GIT_ALTERNATE_OBJECT_DIRECTORIES",
        }:
            env.pop(key, None)
    config = [("credential.helper", ""), ("http.extraHeader", "")]
    if token:
        encoded = base64.b64encode(f"x-access-token:{token}".encode()).decode()
        config.append(("http.https://github.com/.extraHeader", f"Authorization: Basic {encoded}"))
    env["GIT_CONFIG_COUNT"] = str(len(config))
    for index, (key, value) in enumerate(config):
        env[f"GIT_CONFIG_KEY_{index}"] = key
        env[f"GIT_CONFIG_VALUE_{index}"] = value
    env["GIT_TERMINAL_PROMPT"] = "0"
    env["GCM_INTERACTIVE"] = "Never"
    return env


def run_git(*args, token=None):
    result = subprocess.run(
        ["git", *map(str, args)], capture_output=True, text=True,
        encoding="utf-8", errors="replace", env=git_environment(token),
        timeout=1800, check=False,
    )
    if result.returncode:
        detail = result.stderr.strip() or result.stdout.strip() or "Git command failed."
        raise RuntimeError(redact(detail, token) if token else detail)
    return result.stdout.strip()


def parse_refs(output):
    result = {}
    for line in output.splitlines():
        sha, ref = line.split(None, 1)
        if ref.startswith(("refs/heads/", "refs/tags/")) and not ref.endswith("^{}"):
            result[ref] = sha
    return result


def copy_one(repo, target_org, target_name, token):
    from github import GithubException
    try:
        target_org.get_repo(repo.name)
    except GithubException as exc:
        if exc.status != 404:
            raise
    else:
        print("  SKIPPED: already exists; no changes made.")
        return "skipped"

    source_url = f"https://github.com/{SOURCE_ORG}/{repo.name}.git"
    target_url = f"https://github.com/{target_name}/{repo.name}.git"
    created = False
    try:
        # Own unique temporary directory; never deletes a user-selected folder.
        with tempfile.TemporaryDirectory(prefix="imis-copy-", ignore_cleanup_errors=True) as tmp:
            local = Path(tmp) / "repository.git"
            print("  Downloading Git history...")
            run_git("clone", "--bare", source_url, local)
            expected = parse_refs(run_git(
                "-C", local, "for-each-ref", "--format=%(objectname) %(refname)",
                "refs/heads/", "refs/tags/",
            ))
            print("  Creating public destination repository...")
            destination = target_org.create_repo(
                repo.name, private=False, auto_init=False,
                description=repo.description or "Copy of a Base IMIS repository",
            )
            created = True
            if expected:
                print("  Uploading branches and tags...")
                run_git("-C", local, "push", "--atomic", target_url,
                        "refs/heads/*:refs/heads/*", "refs/tags/*:refs/tags/*", token=token)
                actual = parse_refs(run_git("ls-remote", "--refs", target_url, token=token))
                if actual != expected:
                    raise RuntimeError("Branch/tag verification did not match the downloaded copy.")
                if f"refs/heads/{repo.default_branch}" in expected:
                    destination.edit(default_branch=repo.default_branch)
            print(f"  COPIED: https://github.com/{target_name}/{repo.name}")
            return "copied"
    except Exception:
        if created:
            print("  Destination created, but copying or setup did not finish.")
            print(f"  Trainer review needed: https://github.com/{target_name}/{repo.name}")
            print("  A rerun will skip this repository; it is not automatically deleted or overwritten.")
        raise


def main():
    # check_environment()
    from github import Auth, Github, GithubException
    print("IMIS repository copying | Python 3.11.9 | PyGithub 2.5.0")
    print("Use an existing, empty training organization that you own.")
    target = input("Target organization name (not its URL): ").strip()
    if not re.fullmatch(r"[A-Za-z0-9](?:[A-Za-z0-9-]{0,37}[A-Za-z0-9])?", target):
        raise RuntimeError("Enter only the organization name, for example imis-training-alex.")
    if target.casefold() == SOURCE_ORG.casefold():
        raise RuntimeError("The target must be different from base-imis.")
    with warnings.catch_warnings():
        warnings.simplefilter("error", GetPassWarning)
        token = getpass("GitHub token (input is hidden): ").strip()
    if not token:
        raise RuntimeError("No token entered. Nothing was copied.")
    client = Github(auth=Auth.Token(token), timeout=60, retry=0)
    try:
        user = client.get_user().login
        target_org = client.get_organization(target)
        target = target_org.login
        source = client.get_organization(SOURCE_ORG)
        repos = sorted(source.get_repos(type="public"), key=lambda r: r.name.lower())
        print(f"\nSigned in as: {user}\nSource: {SOURCE_ORG}\nTarget: {target}")
        print(f"Public source repositories ({len(repos)}):")
        for repo in repos:
            print(f"  - {repo.name}")
        if not repos:
            raise RuntimeError("No public source repositories were found.")
        print("\nNew copies will be PUBLIC. Existing target repositories will be skipped.")
        if input(f"Type {target} to begin, or press Enter to cancel: ").strip() != target:
            print("Cancelled. No repositories were created.")
            return 0
        counts = {"copied": 0, "skipped": 0, "failed": 0}
        for index, repo in enumerate(repos, 1):
            print(f"\n[{index}/{len(repos)}] {repo.name}")
            try:
                counts[copy_one(repo, target_org, target, token)] += 1
            except Exception as exc:
                counts["failed"] += 1
                detail = f"GitHub HTTP {exc.status}: {exc.data}" if isinstance(exc, GithubException) else str(exc)
                print("  FAILED: " + redact(detail, token))
        print("\nResult: " + ", ".join(f"{n} {label}" for label, n in counts.items()))
        print(f"Check: https://github.com/{target}?tab=repositories")
        print("Delete your temporary training token in GitHub settings when finished.")
        return 1 if counts["failed"] else 0
    except Exception as exc:
        print("ERROR: " + redact(str(exc), token))
        return 1
    finally:
        client.close()


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (KeyboardInterrupt, EOFError):
        print("\nStopped. Check the target organization before trying again.")
        sys.exit(130)
    except GetPassWarning:
        print("Hidden token entry is unavailable. Run this script in PowerShell.")
        sys.exit(1)
    except Exception as exc:
        print(f"ERROR: {exc}")
        sys.exit(1)
