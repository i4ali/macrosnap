# Instructions for Claude Code

This document contains important instructions for Claude when working on the MacroSnap project.

**Note**: MacroSnap uses CloudKit for iCloud sync. Users' data is stored in their own iCloud accounts. No authentication is required.

## Task Management Workflow

### 1. Todo List Management
- Use the `TodoWrite` tool to track all Phase 1 tasks from ROADMAP.md
- Mark tasks as `in_progress` when starting work
- Mark tasks as `completed` when finished
- Keep exactly ONE task as `in_progress` at any time

### 2. CRITICAL: Update ROADMAP.md After Each Completion

**IMPORTANT:** Every time you mark a task as `completed` in the todo list, you MUST immediately update the corresponding checkbox in ROADMAP.md.

**Process:**
1. Complete a task (e.g., "Supabase database schema")
2. Mark it as `completed` using `TodoWrite`
3. **IMMEDIATELY** update ROADMAP.md:
   - Find the corresponding task in Phase 1
   - Change `- [ ]` to `- [x]`
   - Use the `Edit` tool to make the change

**Example:**
```markdown
Before:
- [ ] Supabase database schema
  - Users table
  - Macro entries table
  - Goals table

After:
- [x] Supabase database schema
  - Users table
  - Macro entries table
  - Goals table
```

### 3. Task Completion Sequence

For every completed task:
```
1. TodoWrite (mark as completed)
2. Edit ROADMAP.md (update checkbox to [x])
3. Provide summary to user
```

**DO NOT** batch ROADMAP.md updates. Update immediately after each task completion.

### 4. Phase Transitions

When all tasks in a phase are complete:
1. Update all checkboxes in that phase section
2. Note the phase completion in the summary
3. Ask user before starting the next phase

### 5. File Organization

Follow this structure:
```
MacroSnap/
├── MacroSnap/
│   ├── MacroSnap/
│   │   ├── CoreData/          # CoreData models and CloudKit sync
│   │   ├── Models/             # Domain models
│   │   ├── Views/              # SwiftUI views
│   │   ├── ViewModels/         # View models
│   │   ├── Services/           # Business logic, CloudKit sync
│   │   └── Utils/              # Helpers, extensions
│   └── MacroSnap.xcodeproj
├── ROADMAP.md                  # Project roadmap (keep updated!)
├── CLAUDE.md                   # This file
└── screen*.md                  # Design specs
```

### 6. Best Practices

- **Always read screen*.md files** when building UI components
- **Follow ROADMAP.md task order** - it's optimized for dependencies
- **Use proper iOS conventions** - native feel is a core principle
- **Comment complex logic** - but keep code clean
- **Create READMEs** for new directories explaining structure
- **Test as you go** - ensure features work before moving on

### 7. Code Style

- Use Swift naming conventions
- Prefer SwiftUI over UIKit
- Use `// MARK: -` for section organization
- Keep functions small and focused
- Use extensions for organization
- Add sample data in extensions for previews

### 8. Git Commits (Future)

When user requests commits:
- Use descriptive commit messages
- Reference completed ROADMAP tasks
- Follow conventional commits format

### 9. Progress Reporting

After completing each task, provide:
- ✅ Task name and number
- Brief description of what was created
- File paths created/modified
- Progress percentage (X/33 tasks for Phase 1)
- Next task preview

### 10. Error Handling

If you encounter issues:
1. Document the blocker
2. Update the task status to reflect the issue
3. Ask user for guidance
4. DO NOT mark incomplete tasks as completed

## Current Phase: Phase 1 (MVP)

**Total Phase 1 Tasks:** 33
**Completed:** Track in todo list
**Current Focus:** Building foundation → Authentication → UI → Settings

## Remember

- ROADMAP.md is the source of truth
- Todo list tracks implementation progress
- **Keep them in sync!**
- Update ROADMAP.md **immediately** after each completion
- User relies on ROADMAP.md to track overall project progress
