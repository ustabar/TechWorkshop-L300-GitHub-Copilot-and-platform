using System.Text;
using System.Text.Json;

namespace ZavaStorefront.Services
{
    public class ChatService
    {
        private readonly IConfiguration _configuration;
        private readonly IHttpClientFactory _httpClientFactory;
        private readonly ILogger<ChatService> _logger;

        public ChatService(IConfiguration configuration, IHttpClientFactory httpClientFactory, ILogger<ChatService> logger)
        {
            _configuration = configuration;
            _httpClientFactory = httpClientFactory;
            _logger = logger;
        }

        public async Task<string> SendMessageAsync(string userMessage)
        {
            try
            {
                var endpoint = _configuration["Foundry:Phi4Endpoint"];
                var apiKey = _configuration["Foundry:ApiKey"];

                if (string.IsNullOrEmpty(endpoint) || string.IsNullOrEmpty(apiKey))
                {
                    _logger.LogError("Foundry endpoint or API key is not configured");
                    return "Error: Foundry endpoint is not configured.";
                }

                var client = _httpClientFactory.CreateClient();
                
                // Prepare the request payload
                var requestPayload = new
                {
                    messages = new[]
                    {
                        new { role = "user", content = userMessage }
                    },
                    max_tokens = 1024,
                    temperature = 0.7
                };

                var jsonContent = JsonSerializer.Serialize(requestPayload);
                var httpContent = new StringContent(jsonContent, Encoding.UTF8, "application/json");

                // Add authorization header
                client.DefaultRequestHeaders.Add("Authorization", $"Bearer {apiKey}");

                _logger.LogInformation("Sending message to Phi4 endpoint: {Endpoint}", endpoint);

                var response = await client.PostAsync(endpoint, httpContent);

                if (!response.IsSuccessStatusCode)
                {
                    _logger.LogError("Phi4 endpoint returned status code: {StatusCode}", response.StatusCode);
                    return $"Error: Received status code {response.StatusCode} from Phi4 endpoint.";
                }

                var responseContent = await response.Content.ReadAsStringAsync();
                _logger.LogInformation("Received response from Phi4 endpoint");

                // Parse the response to extract the message content
                var responseData = JsonSerializer.Deserialize<JsonElement>(responseContent);
                
                // Try to extract the message from the response
                // This assumes a response format like { "choices": [{ "message": { "content": "..." } }] }
                if (responseData.TryGetProperty("choices", out var choices) && choices.GetArrayLength() > 0)
                {
                    var firstChoice = choices[0];
                    if (firstChoice.TryGetProperty("message", out var message) && 
                        message.TryGetProperty("content", out var content))
                    {
                        return content.GetString() ?? "Empty response from Phi4.";
                    }
                }

                // Fallback: return the raw response if structure doesn't match expected format
                return responseContent;
            }
            catch (HttpRequestException ex)
            {
                _logger.LogError(ex, "HTTP request failed when contacting Phi4 endpoint");
                return $"Error: Failed to contact Phi4 endpoint. {ex.Message}";
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "An unexpected error occurred");
                return $"Error: An unexpected error occurred. {ex.Message}";
            }
        }
    }
}
