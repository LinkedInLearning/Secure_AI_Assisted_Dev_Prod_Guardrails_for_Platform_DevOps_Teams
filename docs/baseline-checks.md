# Baseline Checks Setup

This branch demonstrates Teriana Harvest's baseline validation setup with three layers of defense.

## Local Setup

Install pre-commit framework:

```bash
# macOS
brew install pre-commit

# or via pip
pip install pre-commit
```

Install the hooks in your local repository:

```bash
pre-commit install
```

Verify installation:

```bash
pre-commit run --all-files
```

## What Gets Checked

**Pre-commit (local):**
- File hygiene (trailing whitespace, EOF)
- YAML syntax
- Code formatting (Prettier)
- Linting (ESLint)

**CI Pipeline (centralized):**
- TypeScript: format check, linting, tests, build
- Terraform: format check, validation

**Branch Protection (enforcement):**
- Requires PR before merge
- Requires all status checks to pass
- Requires branch to be up to date

## Testing the Flow

1. Make a change with bad formatting
2. Attempt to commit - pre-commit blocks it
3. Fix and commit - pre-commit allows it
4. Push and open PR - CI runs automatically
5. Try to merge - blocked until checks pass