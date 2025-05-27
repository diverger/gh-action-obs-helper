# Development Guide

This guide explains how to develop, build, and release the GH OBS Helper.

## 🏗️ Build Process

### Local Development

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Build the action:**
   ```bash
   npm run build
   # or use the build script:
   ./build.sh
   ```

3. **Test TypeScript compilation:**
   ```bash
   npx tsc --noEmit
   ```

### GitHub Actions Build

The project includes automated build workflows:

#### 1. **Build and Package** (`build-and-package.yml`)
- **Triggers:** Push to main/master/develop branches, PRs, manual dispatch
- **Actions:**
  - Builds TypeScript to JavaScript
  - Validates compilation
  - Auto-commits `dist/` changes on push
  - Creates build artifacts for PRs

#### 2. **Release** (`release.yml`)
- **Triggers:** Git tags starting with `v*`, manual dispatch
- **Actions:**
  - Builds the action
  - Creates GitHub releases
  - Uploads release packages
  - Updates major version tags (e.g., `v1` → `v1.2.3`)

## 📁 Project Structure

```
├── src/                   # TypeScript source code
│   ├── index.ts          # Main entry point
│   ├── obs-manager.ts    # OBS operations
│   ├── file-manager.ts   # File handling
│   ├── utils.ts          # Utilities
│   └── types.ts          # Type definitions
├── dist/                 # Built JavaScript (tracked in git)
├── .github/workflows/    # GitHub Actions workflows
├── action.yml           # Action definition
├── package.json         # Dependencies and scripts
└── README.md           # User documentation
```

## 🔄 Development Workflow

### 1. Making Changes

1. Edit TypeScript files in `src/`
2. Test locally:
   ```bash
   ./build.sh
   ```
3. Test the action:
   ```bash
   ./test-all-operations.sh
   ```

### 2. Committing Changes

When you push to main/master/develop:
- GitHub Actions automatically builds and updates `dist/`
- No manual build step required

### 3. Creating Releases

#### Option A: Git Tags (with Manual Release Notes)
```bash
# 1. Create manual release notes
cp RELEASE_NOTES_TEMPLATE.md RELEASE_NOTES.md
# Edit RELEASE_NOTES.md with your release details

# 2. Commit the release notes
git add RELEASE_NOTES.md
git commit -m "docs: Add release notes for v1.0.0"

# 3. Create and push the tag
git tag v1.0.0
git push origin v1.0.0

# 4. Clean up (optional)
git rm RELEASE_NOTES.md
git commit -m "docs: Remove release notes after release"
```

#### Option B: Git Tags (Auto-generated Notes)
```bash
git tag v1.0.0
git push origin v1.0.0
```

#### Option C: Manual Dispatch
1. Go to Actions → Release and Tag
2. Click "Run workflow"
3. Enter tag version (e.g., `v1.0.0`)
4. If you want custom notes, create `RELEASE_NOTES.md` first

## 📝 Creating Manual Release Notes

### Best Practice: Manual Release Notes

For professional releases, create detailed release notes manually:

1. **Copy the template:**
   ```bash
   cp RELEASE_NOTES_TEMPLATE.md RELEASE_NOTES.md
   ```

2. **Edit RELEASE_NOTES.md** with:
   - New features and improvements
   - Bug fixes and changes
   - Breaking changes (if any)
   - Migration instructions
   - Usage examples

3. **Create release:**
   ```bash
   # Commit release notes
   git add RELEASE_NOTES.md
   git commit -m "docs: Add release notes for v1.0.0"

   # Create and push tag
   git tag v1.0.0
   git push origin v1.0.0

   # Optional: Clean up after release
   git rm RELEASE_NOTES.md
   git commit -m "docs: Remove release notes after release"
   ```

### Automatic Release Notes (Fallback)

If no `RELEASE_NOTES.md` exists, the workflow generates basic release notes automatically.

## 🧪 Testing

### Local Testing
```bash
# Test all operations (dry run)
./test-all-operations.sh

# Generate test files
./generate-test-files.sh
```

### GitHub Actions Testing
- **Quick Test:** Manual workflow for single file upload
- **Comprehensive Tests:** Upload, download, sync scenarios
- **Build Tests:** Automated testing of built action

## 📦 Distribution

### For Users
Users reference the action like:
```yaml
uses: your-username/gh-obs-helper@v1
```

### For Contributors
- `dist/` folder must be committed (required for GitHub Actions)
- Build artifacts are automatically updated
- Releases include packaged action files

## 🔧 Key Files

| File | Purpose |
|------|---------|
| `action.yml` | Defines action inputs/outputs |
| `src/index.ts` | Main action logic |
| `dist/index.js` | Compiled JavaScript (auto-generated) |
| `package.json` | Dependencies and build scripts |
| `build.sh` | Local build helper script |

## 🚀 Release Process

1. **Development:** Make changes in `src/`
2. **Testing:** Use test workflows
3. **Build:** Auto-built on push
4. **Release:** Tag version → Auto-release
5. **Distribution:** Users reference by tag

## 📋 Best Practices

- Always test changes with `./build.sh`
- Use semantic versioning for tags (`v1.0.0`)
- Keep `dist/` folder in sync with source
- Update README.md for user-facing changes
- Test with actual OBS credentials before release

## 🐛 Troubleshooting

### Build Issues
```bash
# Clean build
rm -rf dist/ node_modules/
npm install
npm run build
```

### TypeScript Errors
```bash
# Check compilation
npx tsc --noEmit
```

### Action Not Working
1. Check `dist/index.js` exists and is recent
2. Verify `action.yml` parameter names match code
3. Test with dry_run: true first
