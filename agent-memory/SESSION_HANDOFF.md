# SESSION HANDOFF — jarvis-ai-next

**Session:** 1 (project creation)
**Date:** 2026-10-17
**State:** All source files created locally. Awaiting first commit + CI run.

---

## Read first (every session)
1. `agent-memory/PROJECT_CONSTITUTION.md` — rules, never skip
2. `agent-memory/CURRENT_STATE.md` — verified status
3. `agent-memory/DECISIONS.md` — why things are built the way they are
4. `agent-memory/TASK_BACKLOG.md` — what to do next
5. `agent-memory/KNOWN_ISSUES.md` — blockers
6. Check CI: https://github.com/m1ckey-bpl/jarvis-ai-next/actions

---

## Exact next action

Push all committed files to GitHub main branch. The iOS workflow will trigger automatically. Monitor for build errors.

```powershell
$GIT = "C:\Users\HP\AppData\Local\hermes\tools\git-2.53.0+3-win32-x64\bin\git.exe"
$REPO = "C:\Users\HP\.gemini\antigravity\scratch\jarvis-ai-next"
& $GIT -C $REPO -c user.name="JARVIS Agent" -c user.email="agent@jarvis.ai" add -A
& $GIT -C $REPO -c user.name="JARVIS Agent" -c user.email="agent@jarvis.ai" commit -m "feat: initial project — native iOS JARVIS AI assistant v1.0.0-dev"
& $GIT -C $REPO remote set-url origin "https://YOUR_TOKEN@github.com/m1ckey-bpl/jarvis-ai-next.git"
& $GIT -C $REPO push -u origin HEAD:main
```

---

## Files changed this session

All files — this is session 1 (initial creation). See CURRENT_STATE.md for full list.

---

## Important environment notes

- **Git binary:** `C:\Users\HP\AppData\Local\hermes\tools\git-2.53.0+3-win32-x64\bin\git.exe`
- **Always use** inline identity: `git -c user.name='JARVIS Agent' -c user.email='agent@jarvis.ai' commit`
- **Remote URL with auth:** `https://<TOKEN>@github.com/m1ckey-bpl/jarvis-ai-next.git`
- **Never touch** the jarvis-ai-ios repository
- **No local Xcode** — all iOS compilation via GitHub Actions macos-14

---

## If CI fails

1. Read the exact error from the Actions log
2. Most likely: Swift type errors, missing imports, or pbxproj issues
3. Fix the specific file(s), commit, push, re-check
4. Never suppress errors to get a green build

---

## After first green CI run

1. Tag `v1.0.0`
2. Download and verify the IPA artifact
3. Record SHA-256 in CURRENT_STATE.md
4. Ask user to install the IPA and test
5. Ask user for Gemini API key (only after IPA installs successfully)
