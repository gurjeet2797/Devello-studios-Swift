import { GoogleGenAI } from '@google/genai';
import { buildEditPrompt, getLightingPrompt } from './prompts';

// Initialize the GoogleGenAI client
const ai = new GoogleGenAI({ apiKey: process.env.GOOGLE_API_KEY || '' });

// Gemini 2.5 Flash for image generation (supports native image output)
const GEMINI_MODEL = 'gemini-2.5-flash-image';

export interface GeminiResult {
  success: boolean;
  imageBase64?: string;
  error?: string;
}

function extractImageFromResponse(response: any): GeminiResult {
  const candidates = response.candidates;

  if (!candidates || candidates.length === 0) {
    return { success: false, error: 'No response from Gemini' };
  }

  const parts = candidates[0].content?.parts;
  if (!parts) {
    return { success: false, error: 'No content parts in response' };
  }

  for (const part of parts) {
    if (part.inlineData?.mimeType?.startsWith('image/')) {
      return { success: true, imageBase64: part.inlineData.data };
    }
  }

  return { success: false, error: 'No image in Gemini response' };
}

/**
 * Create a lighting edit using Gemini
 * @param imageBase64 - Raw base64 encoded image data (no data URL prefix)
 * @param style - Lighting style to apply
 */
export async function createLightingEdit(
  imageBase64: string,
  style: string
): Promise<GeminiResult> {
  try {
    const prompt = getLightingPrompt(style);

    const response = await ai.models.generateContent({
      model: GEMINI_MODEL,
      contents: [
        {
          role: 'user',
          parts: [
            {
              inlineData: {
                mimeType: 'image/jpeg',
                data: imageBase64,
              },
            },
            { text: prompt },
          ],
        },
      ],
      config: {
        responseModalities: ['Text', 'Image'],
      },
    });

    return extractImageFromResponse(response);
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    return { success: false, error: message };
  }
}

/**
 * Create a general edit using Gemini with hotspot targeting
 * @param imageBase64 - Raw base64 encoded image data (no data URL prefix)
 * @param hotspot - Normalized coordinates (0-1) for edit location
 * @param userPrompt - User's edit instruction
 */
export async function createGeneralEdit(
  imageBase64: string,
  hotspot: { x: number; y: number },
  userPrompt: string
): Promise<GeminiResult> {
  try {
    const prompt = buildEditPrompt(userPrompt, hotspot);

    const response = await ai.models.generateContent({
      model: GEMINI_MODEL,
      contents: [
        {
          role: 'user',
          parts: [
            {
              inlineData: {
                mimeType: 'image/jpeg',
                data: imageBase64,
              },
            },
            { text: prompt },
          ],
        },
      ],
      config: {
        responseModalities: ['Text', 'Image'],
      },
    });

    return extractImageFromResponse(response);
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    return { success: false, error: message };
  }
}
