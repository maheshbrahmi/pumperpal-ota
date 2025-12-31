# Firmware Archive

## Version History

| Version | Date | Size | Changes |
|---------|------|------|---------|
| 2.1.0 | 2024-01-15 | 412KB | Solar optimization, voltage fix |
| 2.0.0 | 2024-01-01 | 410KB | Initial production release |

## Rollback Instructions
1. Copy desired version from archive to main directory
2. Update version.json with `"mandatory": true`
3. Commit and push

./build_and_release.sh 2.3.6 '2.3.6'