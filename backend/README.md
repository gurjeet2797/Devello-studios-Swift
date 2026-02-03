# Devello iOS Backend

Simple Next.js backend API for Devello Studios iOS app, powered by Google Gemini for image lighting and editing.

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/ios/lighting` | Apply lighting style to image |
| POST | `/api/ios/edit` | Apply hotspot-targeted edit to image |
| POST | `/api/ideas/spark` | Generate a draft flow from an idea |
| GET | `/ideas` | Community ideas gallery (server-rendered) |

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

4. (Optional) Configure Supabase for the ideas gallery:
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

5. Run development server:
   ```bash
   npm run dev
   ```

## Smoke Test

From another terminal (while the server is running):
```bash
npm run smoke
```

## Deployment (Vercel)

1. Push to your repository
2. Import project in Vercel
3. Set root directory to `backend`
4. Add `GOOGLE_API_KEY` environment variable
5. (Optional) Add `SUPABASE_URL` and `SUPABASE_ANON_KEY` for `/ideas`
6. Deploy

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

### Idea Spark (`POST /api/ideas/spark`)

Request:
```json
{
  "idea": "A camera app that rewrites your memories into a photo journal"
}
```

Response:
```json
{
  "ok": true,
  "draft": "Title: ...\nOne-liner: ...\n..."
}
```

## Model

Lighting and editing use **Gemini 2.5 Flash (Image)** (`gemini-2.5-flash-image`) for image generation.
Idea Spark uses **Gemini 2.5 Flash** (`gemini-2.5-flash`) for text generation.

## Ideas Table (Supabase)

The iOS app submits ideas directly to Supabase REST. Create a table named `ideas` with columns:

- `id` (uuid, primary key, default `gen_random_uuid()`)
- `text` (text, not null)
- `status` (text, default `submitted`)
- `source` (text, default `ios`)
- `user_id` (uuid, nullable)
- `created_at` (timestamp with time zone, default `now()`)

## iOS Configuration

The iOS app uses `BACKEND_BASE_URL` for Gemini endpoints and Supabase settings for ideas/auth:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_REDIRECT_URL`
