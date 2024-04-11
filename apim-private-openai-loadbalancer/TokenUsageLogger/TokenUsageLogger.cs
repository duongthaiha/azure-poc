using System;
using System.Text.Json;
using Azure.Messaging.EventHubs;
using Microsoft.ApplicationInsights;
using Microsoft.ApplicationInsights.Extensibility;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
  

namespace Microsoft.TokenUsageLogger
{
    public class OpenAiToken
    {
        public string Timestamp { get; set; }
        public string ApiOperation { get; set; }
        public string AppKey { get; set; }
        public string PromptTokens { get; set; }
        public string CompletionTokens { get; set; }
        public string TotalTokens { get; set; }
        public string SubcriptionId { get; set; }

        public Dictionary<string, string> ToDictionary(){
            var dictionary = new Dictionary<string, string>
            {
                { "Timestamp", Timestamp },
                { "ApiOperation", ApiOperation },
                { "AppKey", AppKey },
                { "PromptTokens", PromptTokens },
                { "CompletionTokens", CompletionTokens },
                { "TotalTokens", TotalTokens },
                { "SubcriptionId", SubcriptionId }
            };

            return dictionary;
        }
    }
    public class TokenUsageLogger
    {
        private readonly ILogger<TokenUsageLogger> _logger;
        private readonly TelemetryClient _telemetryClient;
        public TokenUsageLogger(ILogger<TokenUsageLogger> logger, TelemetryClient telemetryClient)
        {
            _logger = logger;
            _telemetryClient = telemetryClient;
        }

        [Function(nameof(TokenUsageLogger))]
        public void Run([EventHubTrigger("%EventHubName%", Connection = "EventHubConnection")] string[] openAiTokenResponse)
        {
            // foreach (string @event in events)
            // {
            //     _logger.LogInformation("Token Usage: {body}", @event);
            //     // _logger.LogInformation("Event Content-Type: {contentType}", @event.ContentType);
            // }
            //Eventhub Messages arrive as an array            
            foreach (var tokenData in openAiTokenResponse)
            {
                try
                {
                    _logger.LogInformation($"Azure OpenAI Tokens Data Received: {tokenData}");
                    var OpenAiToken = JsonSerializer.Deserialize<OpenAiToken>(tokenData);

                    if (OpenAiToken == null)
                    {
                        _logger.LogError($"Invalid OpenAi Api Token Response Received. Skipping.");
                        continue;
                    }                                    

                    _telemetryClient.TrackEvent("Azure OpenAI Tokens", OpenAiToken.ToDictionary());
                }
                catch (Exception e)
                {
                    _logger.LogError($"Error occured when processing TokenData: {tokenData}", e.Message);
                }
            }
            
        }
    }
}
