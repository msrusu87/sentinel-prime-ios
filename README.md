# Sentinel Prime — iOS App

SwiftUI app for monitoring Sentinel Prime training, chatting with the model, and viewing model card info.

## Architecture

- **TrainingView**: Live training metrics (step, loss, throughput, ETA) with 30s auto-refresh from `sentinel.qubitpage.com/api`
- **ChatView**: Send messages to the model with voice input (iOS Speech framework)
- **ModelCardView**: Static model info, fusion sources, dataset stats, external links
- **SentinelAPI**: Async networking layer hitting Mission Control REST endpoints

## API Endpoints Used

| Endpoint | Purpose |
|----------|--------|
| `/api/overview` | Training metrics + shard stats |
| `/api/system` | VRAM/RAM usage |
| `/api/processes` | Live process list |
| `/api/logs/{name}?n=N` | Tail N lines of a named log |
| `/api/chat` | Chat with model (POST) |

## Build Requirements

- Xcode 16+ / macOS 14+
- iOS 17.0 deployment target
- Swift 5.9+

## GitHub Actions CI/CD

The workflow at `.github/workflows/ios-deploy.yml` builds on `macos-14` runners.

### Required GitHub Secrets

| Secret | Description |
|--------|-------------|
| `ASC_KEY_ID` | App Store Connect API Key ID |
| `ASC_ISSUER_ID` | App Store Connect Issuer ID |
| `ASC_PRIVATE_KEY` | Contents of the `.p8` private key file |
| `TEAM_ID` | Apple Developer Team ID |
| `CERTIFICATE_P12` | Base64-encoded distribution certificate (.p12) |
| `CERTIFICATE_PASSWORD` | Password for the .p12 certificate |
| `PROVISIONING_PROFILE` | Base64-encoded provisioning profile (.mobileprovision) |

### Deploying

```bash
git tag v1.0.0
git push origin v1.0.0
```
