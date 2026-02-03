import { GoogleGenAI } from '@google/genai';
import { buildEditPrompt, buildIdeaSparkPrompt, getLightingPrompt } from './prompts';

// Initialize the GoogleGenAI client
const apiKey = process.env.GOOGLE_API_KEY;
if (!apiKey || apiKey.trim().length === 0) {
  throw new Error('Missing GOOGLE_API_KEY environment variable');
}
const ai = new GoogleGenAI({ apiKey });

// Gemini 2.5 Flash for image generation (supports native image output)
const GEMINI_MODEL = 'gemini-2.5-flash-image';
const GEMINI_TEXT_MODEL = 'gemini-2.5-flash';

export interface GeminiResult {
  success: boolean;
  imageBase64?: string;
  error?: string;
}

export interface GeminiTextResult {
  success: boolean;
  text?: string;
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

function extractTextFromResponse(response: any): GeminiTextResult {
  const candidates = response.candidates;
  if (!candidates || candidates.length === 0) {
    return { success: false, error: 'No response from Gemini' };
  }

  const parts = candidates[0].content?.parts;
  if (!parts) {
    return { success: false, error: 'No content parts in response' };
  }

  for (const part of parts) {
    if (typeof part.text === 'string' && part.text.trim().length > 0) {
      return { success: true, text: part.text };
    }
  }

  return { success: false, error: 'No text in Gemini response' };
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
    console.log('[Lighting] Style:', style);
    console.log('[Lighting] Prompt:', prompt);

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

    const result = extractImageFromResponse(response);
    console.log('[Lighting] Response candidates:', response?.candidates?.length ?? 0);
    console.log('[Lighting] Output preview:', result.imageBase64?.slice(0, 100) || 'none');
    return result;
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

/**
 * Generate an idea spark draft (text output)
 * @param idea - User-submitted idea text
 */
export async function createIdeaSpark(idea: string): Promise<GeminiTextResult> {
  try {
    const prompt = buildIdeaSparkPrompt(idea);
    const response = await ai.models.generateContent({
      model: GEMINI_TEXT_MODEL,
      contents: [
        {
          role: 'user',
          parts: [{ text: prompt }],
        },
      ],
      config: {
        responseModalities: ['Text'],
      },
    });

    return extractTextFromResponse(response);
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    return { success: false, error: message };
  }
}
