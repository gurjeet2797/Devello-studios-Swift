// Types matching iOS API models

export interface IOSLightingRequest {
  image_url: string;
  style?: string;
}

export interface IOSSingleEditRequest {
  image_url: string;
  hotspot: IOSHotspot;
  prompt: string;
}

export interface IOSHotspot {
  x: number;
  y: number;
}

export interface IOSActionResponse {
  ok: boolean;
  output_url?: string;
  error?: string;
}

export type LightingStyle = 'Dramatic Daylight' | 'Midday Bright' | 'Cozy Evening';
