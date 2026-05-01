# Sentinel Prime — iOS App

SwiftUI app for monitoring Sentinel Prime training, chatting with the model, and viewing model card info.

## Architecture

- **TrainingView**: Live training metrics (step, loss, throughput, ETA) with 30s auto-refresh from `sentinel.qubitpage.com/api`
- **ChatView**: Send messages to the model with voice input (iOS Speech framework)
- **ModelCardView**: Static model info, fusion sources, dataset stats, external links
- **SentinelAPI**: Async networking layer hitting Mission Control REST endpoints

## Build Requirements

- Xcode 16+ / macOS 14+
- iOS 17.0 deployment target
- Swift 5.9+

## CI/CD — Automatic Code Signing

The workflow uses **Xcode Automatic Code Signing** with the App Store Connect API key.
The macOS runner automatically manages certificates and provisioning profiles — **no manual certificate export required.**

### Required GitHub Secrets (only 4)

| Secret | Description | How to find it |
|--------|-------------|----------------|
| `ASC_KEY_ID` | API Key ID | ✅ Already set: `32548MCWA6` |
| `ASC_PRIVATE_KEY` | Contents of .p8 key | ✅ Already set |
| `ASC_ISSUER_ID` | Issuer UUID | appstoreconnect.apple.com → Users & Access → Integrations → App Store Connect API (shown at top) |
| `TEAM_ID` | 10-char Team ID | developer.apple.com/account → Membership details |

### Quick Setup (after getting the 2 IDs)

```bash
# One-command setup:
python scripts/deploy/set_ios_secrets.py --issuer YOUR_ISSUER_UUID --team YOUR_TEAM_ID
```

### Deploying

```bash
git tag v1.0.0
git push origin v1.0.0
```

Or trigger manually from GitHub Actions tab → "Run workflow".
