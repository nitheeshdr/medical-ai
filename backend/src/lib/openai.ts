import OpenAI from 'openai'

// NVIDIA NIM API is OpenAI-compatible — swap the base URL and key
let client: OpenAI | null = null

export function getAIClient(): OpenAI {
  if (!client) {
    const apiKey = process.env.NVIDIA_API_KEY || process.env.OPENAI_API_KEY || ''
    const useNvidia = Boolean(process.env.NVIDIA_API_KEY)
    client = new OpenAI({
      apiKey,
      baseURL: useNvidia ? 'https://integrate.api.nvidia.com/v1' : undefined,
    })
  }
  return client
}

// Default model: NVIDIA Llama 3.1 NIM, fallback to gpt-4o-mini
export function getDefaultModel(): string {
  return process.env.NVIDIA_API_KEY
    ? (process.env.NVIDIA_MODEL || 'meta/llama-3.1-70b-instruct')
    : 'gpt-4o-mini'
}

/** @deprecated use getAIClient() */
export const getOpenAI = getAIClient

export async function streamChat(messages: OpenAI.Chat.ChatCompletionMessageParam[]) {
  return getAIClient().chat.completions.create({
    model: getDefaultModel(),
    messages,
    stream: true,
    temperature: 0.6,
    top_p: 0.95,
    max_tokens: 1024,
  })
}

export async function analyzeText(systemPrompt: string, userContent: string): Promise<string> {
  const response = await getAIClient().chat.completions.create({
    model: getDefaultModel(),
    messages: [
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userContent },
    ],
    temperature: 0.4,
    max_tokens: 2048,
  })
  return response.choices[0].message.content || ''
}

// NVIDIA vision model for image OCR/analysis
const VISION_MODEL = 'nvidia/llama-3.2-11b-vision-instruct'

export async function analyzeImageWithVision(
  imageBase64: string,
  mimeType: string,
  systemPrompt: string,
): Promise<string> {
  const client = getAIClient()
  // Use vision model if NVIDIA key is set, otherwise fallback to text-only
  const model = process.env.NVIDIA_API_KEY ? VISION_MODEL : getDefaultModel()

  const response = await client.chat.completions.create({
    model,
    messages: [
      { role: 'system', content: systemPrompt },
      {
        role: 'user',
        content: [
          {
            type: 'image_url',
            image_url: { url: `data:${mimeType};base64,${imageBase64}` },
          },
          {
            type: 'text',
            text: 'Please analyze this prescription image and extract all medical information.',
          },
        ] as OpenAI.Chat.ChatCompletionContentPart[],
      },
    ],
    temperature: 0.3,
    max_tokens: 2048,
  })
  return response.choices[0].message.content || ''
}
