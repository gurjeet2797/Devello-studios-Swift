// Types matching iOS API models

export interface IOSLightingRequest {
  image_base64: string;
  style?: string;
}

export interface IOSSingleEditRequest {
  image_base64: string;
  hotspot: IOSHotspot;
  prompt: string;
}

export interface IOSHotspot {
  x: number;
  y: number;
}

export interface IOSActionResponse {
  ok: boolean;
  image_base64?: string;
  error?: string;
}

export type LightingStyle = 'Dramatic Daylight' | 'Midday Bright' | 'Cozy Evening';
