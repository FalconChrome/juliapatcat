using Telegram, Telegram.API
using Logging, LoggingExtras
using ConfigEnv
using Dates
import JSON

cd("/home/caster/dev/assisters/")

dotenv()

tg = TelegramClient()
tg_logger = TelegramLogger(tg; async = false)
demux_logger = TeeLogger(
    MinLevelLogger(tg_logger, Logging.Warn),
    ConsoleLogger()
)
global_logger(demux_logger)

BANLIST = readlines("banlist")

CHATS = JSON.parse(open("users.json"))["chats"]
Age = 7 # days before newby becomes an old

@info "Bot Starts"

# Censor bot
run_bot() do msg
    # tracknewbies(msg) # we may want to turn on censoring only for new members
    # if !(msg.message.from.id in NEWUSERS[msg.message.chat.id]) # 
    #     return nothing
    # end
    text = msg.message.text

    if any(occursin.(BANLIST, text))
        @warn "Dameda, this message I'm deleting: " * text
        deleteMessage(message_id = msg.message.message_id, chat_id = msg.message.chat.id)
    end
end
