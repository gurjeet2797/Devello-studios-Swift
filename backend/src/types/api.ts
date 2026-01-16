// Types matching iOS API models

export interface IOSLightingRequest {
  image_url: string;
  style: string;
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
  status?: string;
  output_url?: string;
  input_url?: string;
  request_id?: string;
  job_id?: string;
  model?: string;
  error?: string;
  code?: string;
}

export interface IOSJobResponse {
  ok: boolean;
  status?: string;
  output_url?: string;
  request_id?: string;
  job_id?: string;
  error?: string;
  code?: string;
}

export type LightingStyle = 'Dramatic Daylight' | 'Midday Bright' | 'Cozy Evening';
