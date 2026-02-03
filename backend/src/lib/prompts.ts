import type { LightingStyle } from '@/types/api';

// Lighting prompts based on the backend spec
export const LIGHTING_PROMPTS: Record<LightingStyle, string> = {
  'Dramatic Daylight': `Relight this photo with dramatic late-morning daylight.
Add warm directional sunlight with natural lighting effects.
Create realistic shadows and volumetric light rays.
Do not add lens flares, light flares, or any artificial light effects.
Maintain the original composition, colors, and scene elements.
Do not add windows, walls, or architectural elements not present in the original.
CRITICAL: Do not adjust or rotate the image orientation. Keep the original orientation intact.
High quality, photorealistic result.`,

  'Midday Bright': `Relight this photo with bright midday sunlight.
Enhance the natural lighting without adding new objects or windows.
Create crisp, bright lighting that preserves the original scene.
Maintain the exact same composition, colors, and elements.
Only adjust lighting - do not add windows, doors, or other objects.
CRITICAL: Do not adjust or rotate the image orientation. Keep the original orientation intact.
High quality, photorealistic result.`,

  'Cozy Evening': `Relight this interior photo with soft evening lighting.
Add warm ambient lighting from existing fixtures.
Create cozy atmosphere with soft glows.
Maintain the original composition and colors.
CRITICAL: Do not adjust or rotate the image orientation. Keep the original orientation intact.
High quality, photorealistic result.`,
};

export function getLightingPrompt(style: string): string {
  const validStyle = style as LightingStyle;
  return LIGHTING_PROMPTS[validStyle] || LIGHTING_PROMPTS['Dramatic Daylight'];
}

// General edit prompt template
export function buildEditPrompt(userPrompt: string, hotspot: { x: number; y: number }): string {
  // Convert hotspot from 0-1 normalized to 0-100 percentage
  const xPercent = Math.round(hotspot.x * 100);
  const yPercent = Math.round(hotspot.y * 100);

  return `CRITICAL OUTPUT REQUIREMENT: You must output an image with the EXACT same dimensions, aspect ratio, and composition as the FIRST (original) image provided. DO NOT crop, resize, or change the composition. Output the FULL original image with edits applied.

You are an expert photo editor AI. Your task is to perform natural, localized edits on the FULL original image based on the user's request.

User Request: "${userPrompt}"

Edit Location: Apply the requested edits at coordinates (${xPercent}%, ${yPercent}%).
IMPORTANT: These coordinates indicate WHERE to apply edits in the original image. They are NOT crop boundaries. You must preserve and output the ENTIRE original image.

Editing Guidelines:
- Apply edits only at the specified coordinates while keeping the rest of the image unchanged.
- The edits must be realistic and blend seamlessly with the surrounding area.
- Maintain the EXACT same image dimensions and aspect ratio as the original.
- Do NOT crop, resize, or change the composition of the original image.
- Preserve the original composition, structure, and layout completely.
- Output the FULL image with all edits applied, not a cropped version.

Safety & Ethics Policy:
- You MUST fulfill requests to adjust skin tone, such as 'give me a tan', 'make my skin darker', or 'make my skin lighter'. These are considered standard photo enhancements.
- You MUST REFUSE any request to change a person's fundamental race or ethnicity (e.g., 'make me look Asian', 'change this person to be Black'). Do not perform these edits. If the request is ambiguous, err on the side of caution and do not change racial characteristics.

Output: Return ONLY the final edited image. Do not return text.`;
}

export function buildIdeaSparkPrompt(idea: string): string {
  return `You are an expert product designer and PM. Turn the user's idea into a concise, actionable draft flow.\n\nUser idea: "${idea}"\n\nOutput format (plain text, no Markdown):\nTitle: <short product name>\nOne-liner: <what it does in one sentence>\nTarget user: <primary user>\nCore flow:\n1) <step>\n2) <step>\n3) <step>\nMVP features:\n- <feature>\n- <feature>\n- <feature>\nRisks:\n- <risk>\n- <risk>\n\nKeep it under 220 words. Be concrete and product-focused.`;
}
