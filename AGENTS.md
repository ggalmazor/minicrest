# Building Guidelines for AI Assistants

This document provides guidelines for AI assistants (like Claude) when working on this project.

## Development Philosophy

### Test-Driven Development (TDD)

This project follows strict TDD:

1. **Write a failing test first** (Red)
2. **Write minimal code to pass the test** (Green)
3. **Refactor while keeping tests green**
4. **Commit after every green cycle**

**Never write production code without a failing test first.**

### Grey-Box Testing Approach

- **Test observable behavior**, not implementation details
- **Favor integration tests** over isolated unit tests
- **Avoid mocking** except when absolutely necessary

### Commit Strategy

- Commit after **every test goes green**
- Use **small, atomic commits**
- Commit message format:
  - `change: <description>` - for changes to the observable behavior
  - `refactor: <description>` - for refactors
  - `chore: <description>` - for anything else: documentation, formatting, etc.

## Project Structure

```
gwt/
├── .tool-versions           # ASDF config file
├── Gemfile                  # Bundler config file
├── AGENTS.md                # This file
├── lib/                     # Implementation of this library
├── test/                    # Test files
```

## TDD Workflow

### 1. Before Writing Any Code

- Read the implementation plan (`docs/implementation-plan.md`)
- Identify the next TDD cycle to implement
- Understand the expected behavior

### 2. Red Phase

Create a test file in `tests/` that mirrors the source structure:

- If implementing `lib/minicrest/foo.ts`, create `test/lib/minicrest/foo_test.rb`
- Write one or more tests that define the expected behavior
- Tests should **fail** when first run
- Run `minitest` to confirm failure

### 3. Green Phase

- Create the corresponding source file in `lib/`
- Write **minimal code** to make the test pass
- Avoid over-engineering or adding features not tested
- Run `minitest` until all tests pass

### 4. Commit

```bash
git add tests/git/repo.test.ts src/git/repo.ts
git commit -m "Change: <describe the new behavior>"
```

### 5. Refactor Phase (optional)

- Wait until there's enough repetition to warrant refactoring. Skip this step if not applicable.
- Clean up code while keeping tests green
- Extract duplicated logic
- Improve naming
- Run `minitest` frequently to ensure tests still pass

### 6. Commit

```bash
git add tests/git/repo.test.ts src/git/repo.ts
git commit -m "Refactor: <describe the refactor>"
```

### 7. Repeat

Move to the next TDD cycle in the implementation plan.

## Testing Guidelines

### Test Observable Behavior

Focus on **what** the code does, not **how** it does it:
- Outputs
- Side effects
- Errors

### Minimize Mocking

Use real implementations whenever possible:

### Test Error Conditions

Test both success and failure paths:

### Integration Tests

Test complete workflows

## Summary: TDD Checklist

For each feature:

- [ ] Write failing test(s) that define expected behavior
- [ ] Run tests to confirm failure (`minitest`)
- [ ] Write minimal code to make tests pass
- [ ] Run tests to confirm success
- [ ] Commit the changes
- [ ] Refactor while keeping tests green
- [ ] Commit the refactor
- [ ] Move to next TDD cycle

**Remember**: Test first, code second, commit often!
