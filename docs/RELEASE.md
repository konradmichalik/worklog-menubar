# Release

## Steps

1. **Bump version** in `project.yml`:
   ```yaml
   MARKETING_VERSION: "x.y.z"
   ```

2. **Regenerate Xcode project** to sync the version into `project.pbxproj`:
   ```bash
   make xcode
   ```

3. **Commit both files**:
   ```bash
   git add project.yml DevcapApp.xcodeproj/project.pbxproj
   git commit -m "release: vx.y.z"
   ```

4. **Tag the release**:
   ```bash
   git tag vx.y.z
   ```

5. **Push**:
   ```bash
   git push && git push --tags
   ```

## Versioning

Follows [Semantic Versioning](https://semver.org/):

- **Patch** (`0.6.1` → `0.6.2`) — bug fixes, UI tweaks
- **Minor** (`0.6.x` → `0.7.0`) — new features, backward-compatible
- **Major** (`0.x.y` → `1.0.0`) — breaking changes

## Notes

- `project.yml` is the source of truth for the version — `MARKETING_VERSION` maps to the user-facing version string
- `CURRENT_PROJECT_VERSION` stays at `"1"` (incremented only for App Store builds)
- Always run `make xcode` after changing `project.yml` so the generated `.xcodeproj` stays in sync
