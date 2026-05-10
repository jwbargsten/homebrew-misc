# Bug: status view cursor jumps from 1st to 3rd file after staging

## Symptom

In the status view, with 4 modified files in "Changes not staged for commit:"
and at least one file already in "Changes to be committed:", pressing `u` on
the first modified file stages it correctly, but the cursor lands on the
**3rd** modified file instead of the **2nd** — one file is skipped.

## Root cause

`src/status.c:632-659` (`status_update`) does, after a successful `git add`:

```c
if (!show_untracked_only && line->type != LINE_STAT_STAGED && !no_files_staged)
    view->pos.lineno += 1;
```

The `+= 1` was added in `06dd7a8b` (May 2022) and refined in `0199babc`
(Mar 2025). Its intent: in the "normal" case the staged section grows by one
line and the unstaged section shrinks by one line, so the cursor at line `N`
(the just-staged file) needs to advance to `N+1` to land on what is now the
next file in the unstaged section.

This model holds when the file being staged is **new** to the staged
section: staged grows by 1, unstaged shrinks by 1, lines above the unstaged
section all shift down by exactly 1, and `+= 1` correctly compensates so
that prev_pos still points at the next file.

It breaks when the file is in `MM` state — already-staged hunks **and**
further unstaged changes — so it appears in **both** the staged section and
the unstaged section. `git diff-index --cached` and `git diff-files` are
independent runs at `src/status.c:399-400`; tig parses the file once into
each section. Pressing `u` on the unstaged copy fully stages the file and
removes it from the unstaged section, but the staged section does **not**
grow (the file was already listed there). Net: the view loses 1 line; but
`pos.lineno` was bumped by +1 anyway, so the cursor effectively overshoots
by 2 instead of by 1.

## Trace: 4 `MM` files (foo, bar, baz, qux)

Before staging `foo` (cursor on foo at unstaged-L7):

```
L0  HEADER
L1  STAGED header
L2  foo            (staged)
L3  bar            (staged)
L4  baz            (staged)
L5  qux            (staged)
L6  UNSTAGED header
L7  foo            ← cursor (unstaged)
L8  bar            (unstaged)
L9  baz            (unstaged)
L10 qux            (unstaged)
L11 UNTRACKED header
L12 (no files)
```

`no_files_staged == false` (staged section has files). `status_update`
increments `pos.lineno` to **8**. `reset_view` saves `prev_pos.lineno = 8`.

After `git add foo` and rebuild — foo is no longer unstaged; staged
unchanged in count:

```
L0  HEADER
L1  STAGED header
L2  foo
L3  bar
L4  baz
L5  qux
L6  UNSTAGED header
L7  bar           ← user expects cursor here
L8  baz           ← cursor actually here (the bug)
L9  qux
L10 UNTRACKED header
L11 (no files)
```

`status_restore` (`src/status.c:202-226`) walks forward from `prev_pos=8`
looking for a line with data. Line 8 already has data (`baz`), so the loop
exits immediately. Cursor lands on `baz` — the 3rd file.

The same off-by-one shows up in any case where the file's name is already
present in the staged section at stage time: e.g., a file partially staged
in a previous step and then fully staged via `u`.

## Why the "1 staged + 4 modified, no MM" trace looked fine

When the staged section contains files **unrelated** to the one being
staged, staged grows by +1 and unstaged shrinks by -1, the absolute position
of the next unstaged file is unchanged, and `+= 1` correctly advances the
cursor onto it. The bug only surfaces when the file's *name* is already in
the staged section.

## Fix

The minimal, behavior-preserving fix is to skip the increment when the
just-staged file is already represented in the staged section. Then the
staged section won't grow, and the cursor doesn't need to advance.

**Location:** `src/status.c:655-656`.

**Approach:** before incrementing, scan `view->line[1..lines]` for any
`LINE_STAT_STAGED` entry whose `status->new.name` equals the name of the
file being staged. If found, skip the increment.

```c
if (!show_untracked_only && line->type != LINE_STAT_STAGED && !no_files_staged) {
    struct status *file = line->data;
    bool already_in_staged = false;
    int i;

    for (i = 1; file && i < view->lines; i++) {
        struct line *l = &view->line[i];
        struct status *s = l->data;

        if (l->type == LINE_STAT_STAGED && s &&
            !strcmp(s->new.name, file->new.name)) {
            already_in_staged = true;
            break;
        }
    }

    if (!already_in_staged)
        view->pos.lineno += 1;
}
```

`struct status` is defined in `include/tig/status.h`; `new.name` is the
field used elsewhere in this file (see `src/status.c:127, 136-138, 142`).

### Alternative: remove the `+= 1` entirely

Removing the increment unconditionally also produces correct cursor
placement in every case I traced, including the original `06dd7a8b`
empty-staged case: `status_restore`'s forward search at
`src/status.c:209-210` already skips past section headers and `(no files)`
placeholders to find the next data-bearing line. This is a smaller diff but
a broader behavior change to a function whose history shows two prior fix
attempts; the targeted check above matches existing style and is easier to
revert if a corner case surfaces.

## Verification

End-to-end repro before the fix, expected pass after:

1. In a throwaway git repo, commit a file `foo`. Modify it. `git add foo`.
   Modify `foo` again — `foo` is now in `MM` state.
2. Repeat for `bar`, `baz`, `qux` so all four are `MM`.
3. `tig status`. Cursor on `foo` in "Changes not staged for commit:".
4. Press `u`.
   - **Without the fix:** cursor on `baz`.
   - **With the fix:** cursor on `bar`.

Also re-run `make test-status` to confirm no regression in `file-name-test`,
`refresh-test`, and `untracked-files-test`. A new test asserting the
post-stage screen for `MM` files would prevent regressions.

## Open question

If pressing `u` on a fresh modified file that does **not** appear in the
staged section also reproduces the bug, the diagnosis is incomplete — most
likely the binary is a pre-`06dd7a8b` build (older than May 2022). Confirm
with `tig --version`. Otherwise the `MM` diagnosis stands.

## History

- `06dd7a8b` (2022-05-15): introduced `no_files_staged` flag to suppress the
  increment when the staged section's `(no files)` placeholder disappears
  on first stage. Fixes #842, #1028.
- `0199babc` (2025-03-24): added `!show_untracked_only` guard to suppress
  the increment in untracked-only mode. Fixes #1371.
- This bug: same `+= 1` is wrong for `MM` files, where the staged section
  doesn't grow even though a file leaves the unstaged section.
