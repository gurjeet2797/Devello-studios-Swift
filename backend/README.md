# Devello iOS Backend

Simple Next.js backend API for Devello Studios iOS app, powered by Google Gemini for image lighting and editing.

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/ios/lighting` | Apply lighting style to image |
| POST | `/api/ios/edit` | Apply hotspot-targeted edit to image |

## Setup

1. Install dependencies:
   ```bash
   cd backend
   npm install
   ```

2. Create environment file:
   ```bash
   cp .env.example .env
   ```

3. Add your Google API key to `.env`:
   ```
   GOOGLE_API_KEY=your_api_key_here
   ```
   Get your key from [Google AI Studio](https://aistudio.google.com/app/apikey)

4. Run development server:
   ```bash
   npm run dev
   ```

## Deployment (Vercel)

1. Push to your repository
2. Import project in Vercel
3. Set root directory to `backend`
4. Add `GOOGLE_API_KEY` environment variable
5. Deploy

## API Details

### Lighting Tool (`POST /api/ios/lighting`)

Request:
```json
{
  "image_base64": "base64_encoded_jpeg_data",
  "style": "Dramatic Daylight"
}
```

Styles: `"Dramatic Daylight"`, `"Midday Bright"`, `"Cozy Evening"`

Response:
```json
{
  "ok": true,
  "image_base64": "base64_encoded_result"
}
```

### Edit Tool (`POST /api/ios/edit`)

Request:
```json
{
  "image_base64": "base64_encoded_jpeg_data",
  "hotspot": { "x": 0.5, "y": 0.5 },
  "prompt": "Remove the red car"
}
```

Response:
```json
{
  "ok": true,
  "image_base64": "base64_encoded_result"
}
```

## Model

Both tools use **Gemini 2.5 Flash** (`gemini-2.5-flash-preview-04-17`) for image generation.

## iOS Configuration

The iOS app only needs `BACKEND_BASE_URL` set in Info.plist. No Supabase configuration required for the tools.
