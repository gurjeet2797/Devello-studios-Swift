# Devello iOS Backend

Next.js backend API for Devello Studios iOS app, providing image lighting and editing capabilities.

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/ios/lighting` | Create lighting prediction (async, requires polling) |
| POST | `/api/ios/edit` | Create general edit (synchronous) |
| GET | `/api/ios/jobs/:jobId` | Poll job status for lighting predictions |

## Setup

1. Install dependencies:
   ```bash
   cd backend
   npm install
   ```

2. Copy environment variables:
   ```bash
   cp .env.example .env
   ```

3. Fill in the environment variables in `.env`:
   - `REPLICATE_API_TOKEN` - From [Replicate](https://replicate.com/account/api-tokens)
   - `GOOGLE_API_KEY` - From [Google AI Studio](https://aistudio.google.com/app/apikey)
   - `SUPABASE_JWT_SECRET` - From Supabase Dashboard > Settings > API > JWT Settings

4. Run development server:
   ```bash
   npm run dev
   ```

## Deployment (Vercel)

1. Push to your repository
2. Import project in Vercel
3. Set root directory to `backend`
4. Add environment variables in Vercel dashboard
5. Deploy

## API Details

### Lighting Tool
- Uses Replicate's `flux-kontext-max` model
- Supports 3 styles: "Dramatic Daylight", "Midday Bright", "Cozy Evening"
- Async processing - returns job ID, poll for result

### Edit Tool
- Uses Google Gemini `gemini-2.0-flash-exp`
- Synchronous - returns result directly
- Supports hotspot-based localized edits

## iOS Integration

Update `Devello-Studios-Info.plist` with the deployed backend URL:
```xml
<key>BACKEND_BASE_URL</key>
<string>https://your-vercel-app.vercel.app</string>
```
