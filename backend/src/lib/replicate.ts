import Replicate from 'replicate';
import { getLightingPrompt } from './prompts';

const replicate = new Replicate({
  auth: process.env.REPLICATE_API_TOKEN,
});

// Flux Kontext Max model for lighting
const LIGHTING_MODEL = 'black-forest-labs/flux-kontext-max';
const LIGHTING_VERSION = 'b94039e52f5065899a5f50cc69186801e28d63c74b0a3dafc22ea93bbdf4c36c';

export interface ReplicatePrediction {
  id: string;
  status: 'starting' | 'processing' | 'succeeded' | 'failed' | 'canceled';
  output?: string | string[];
  error?: string;
}

export async function createLightingPrediction(
  imageUrl: string,
  style: string
): Promise<ReplicatePrediction> {
  const prompt = getLightingPrompt(style);

  const prediction = await replicate.predictions.create({
    version: LIGHTING_VERSION,
    input: {
      input_image: imageUrl,
      prompt: prompt,
      aspect_ratio: 'match_input_image',
      output_format: 'png',
      safety_tolerance: 2,
    },
  });

  return {
    id: prediction.id,
    status: prediction.status as ReplicatePrediction['status'],
    output: prediction.output as string | string[] | undefined,
    error: prediction.error as string | undefined,
  };
}

export async function getPredictionStatus(predictionId: string): Promise<ReplicatePrediction> {
  const prediction = await replicate.predictions.get(predictionId);

  // Extract output URL - Replicate may return array or string
  let outputUrl: string | undefined;
  if (prediction.output) {
    if (Array.isArray(prediction.output) && prediction.output.length > 0) {
      outputUrl = prediction.output[0];
    } else if (typeof prediction.output === 'string') {
      outputUrl = prediction.output;
    }
  }

  return {
    id: prediction.id,
    status: prediction.status as ReplicatePrediction['status'],
    output: outputUrl,
    error: prediction.error as string | undefined,
  };
}
