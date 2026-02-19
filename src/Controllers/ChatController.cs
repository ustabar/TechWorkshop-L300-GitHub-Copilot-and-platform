using Microsoft.AspNetCore.Mvc;
using ZavaStorefront.Services;

namespace ZavaStorefront.Controllers;

public class ChatController : Controller
{
    private readonly ChatService _chatService;
    private readonly ILogger<ChatController> _logger;

    public ChatController(ChatService chatService, ILogger<ChatController> logger)
    {
        _chatService = chatService;
        _logger = logger;
    }

    public IActionResult Index()
    {
        _logger.LogInformation("Loading chat page");
        return View();
    }

    [HttpPost]
    public async Task<IActionResult> SendMessage(string message)
    {
        if (string.IsNullOrWhiteSpace(message))
        {
            return Json(new { success = false, error = "Message cannot be empty" });
        }

        _logger.LogInformation("Sending message to Phi4: {Message}", message);

        var response = await _chatService.SendMessageAsync(message);
        
        return Json(new { success = true, response = response });
    }
}
