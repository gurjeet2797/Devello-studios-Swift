import { GoogleGenerativeAI } from '@google/generative-ai';
import { buildEditPrompt } from './prompts';

const genAI = new GoogleGenerativeAI(process.env.GOOGLE_API_KEY || '');

// Primary model for image generation
const GEMINI_MODEL = 'gemini-2.0-flash-exp';

export interface GeminiEditResult {
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

export async function createGeneralEdit(
  imageUrl: string,
  hotspot: { x: number; y: number },
  userPrompt: string
): Promise<GeminiEditResult> {
  try {
    const model = genAI.getGenerativeModel({
      model: GEMINI_MODEL,
      generationConfig: {
        // @ts-expect-error - responseModalities is valid for image generation models
        responseModalities: ['Text', 'Image'],
      },
    });

    // Fetch and convert image to base64
    const imageData = await fetchImageAsBase64(imageUrl);

    // Build the enhanced prompt with hotspot
    const prompt = buildEditPrompt(userPrompt, hotspot);

    // Create the request with image and prompt
    const result = await model.generateContent([
      {
        inlineData: {
          mimeType: imageData.mimeType,
          data: imageData.data,
        },
      },
      { text: prompt },
    ]);

    const response = result.response;
    const candidates = response.candidates;

    if (!candidates || candidates.length === 0) {
      return {
        success: false,
        error: 'No response from Gemini',
      };
    }

    // Look for image in response parts
    const parts = candidates[0].content?.parts;
    if (!parts) {
      return {
        success: false,
        error: 'No content parts in response',
      };
    }

    for (const part of parts) {
      if (part.inlineData?.mimeType?.startsWith('image/')) {
        const dataUrl = `data:${part.inlineData.mimeType};base64,${part.inlineData.data}`;
        return {
          success: true,
          imageDataUrl: dataUrl,
        };
      }
    }

    return {
      success: false,
      error: 'No image in Gemini response',
    };
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    return {
      success: false,
      error: message,
    };
  }
}
