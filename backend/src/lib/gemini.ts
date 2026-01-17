import { GoogleGenerativeAI } from '@google/generative-ai';
import { buildEditPrompt, getLightingPrompt } from './prompts';

const genAI = new GoogleGenerativeAI(process.env.GOOGLE_API_KEY || '');

// Gemini 2.5 Flash for image generation
const GEMINI_MODEL = 'gemini-2.5-flash-preview-04-17';

export interface GeminiResult {
  success: boolean;
  imageDataUrl?: string;
  error?: string;
}

async function fetchImageAsBase64(url: string): Promise<{ data: string; mimeType: string }> {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`Failed to fetch image: ${response.statusText}`);
  }

  const contentType = response.headers.get('content-type') || 'image/jpeg';
  const arrayBuffer = await response.arrayBuffer();
  const base64 = Buffer.from(arrayBuffer).toString('base64');

  return {
    data: base64,
    mimeType: contentType,
  };
}

function getModel() {
  return genAI.getGenerativeModel({
    model: GEMINI_MODEL,
    generationConfig: {
      // @ts-expect-error - responseModalities is valid for image generation models
      responseModalities: ['Text', 'Image'],
    },
  });
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
      const dataUrl = `data:${part.inlineData.mimeType};base64,${part.inlineData.data}`;
      return { success: true, imageDataUrl: dataUrl };
    }
  }

  return { success: false, error: 'No image in Gemini response' };
}

/**
 * Create a lighting edit using Gemini
 */
export async function createLightingEdit(
  imageUrl: string,
  style: string
): Promise<GeminiResult> {
  try {
    const model = getModel();
    const imageData = await fetchImageAsBase64(imageUrl);
    const prompt = getLightingPrompt(style);

    const result = await model.generateContent([
      {
        inlineData: {
          mimeType: imageData.mimeType,
          data: imageData.data,
        },
      },
      { text: prompt },
    ]);

    return extractImageFromResponse(result.response);
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    return { success: false, error: message };
  }
}

/**
 * Create a general edit using Gemini with hotspot targeting
 */
export async function createGeneralEdit(
  imageUrl: string,
  hotspot: { x: number; y: number },
  userPrompt: string
): Promise<GeminiResult> {
  try {
    const model = getModel();
    const imageData = await fetchImageAsBase64(imageUrl);
    const prompt = buildEditPrompt(userPrompt, hotspot);

    const result = await model.generateContent([
      {
        inlineData: {
          mimeType: imageData.mimeType,
          data: imageData.data,
        },
      },
      { text: prompt },
    ]);

    return extractImageFromResponse(result.response);
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    return { success: false, error: message };
  }
}
