using Telegram, Telegram.API
using Logging, LoggingExtras
using ConfigEnv
using Dates
import JSON

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

# function tracknewbies(msg)
#     chat_id = msg.message.chat.id
#     if !(chat_id in keys(CHATS))
#         CHATS[chat_id] = Dict("new" => Dict{Int, UInt64}(), "old" => Array{UInt64}())
#     end

#     olders = map(filter(u -> u.first <= Age, CHATS[msg.message.chat.id]["new"])) do u
#         u.second 
#     end
#     append!(CHATS[msg.message.chat.id]["olders"], olders)
#     print(msg.message)
#     if (hasfield(msg.message, :new_chat_members))
#         append!(CHATS[msg.message.chat.id]["new"], Date(now()) => msg.new_chat_members)
#     end

#     stringdata = json("chats" => CHATS)
#     open("users.json", "w") do f
#         write(f, stringdata)
#     end

#     CHATS[msg.message.chat.id]["new"]
# end

function extractcommands(message)
    map(filter(ent -> ent["type"] == "bot_command", message.entities)) do ent
        message.text[ent.offset+1:ent.offset+ent.length]
    end
end

@info "Bot Starts"

Myid = getMe().id

# Censor bot
run_bot() do msg
    # tracknewbies(msg) # we may want to turn on censoring only for new members
    # if !(msg.message.from.id in NEWUSERS[msg.message.chat.id]) # 
    #     return nothing
    # end
try
    print(msg)
    if !("message" in keys(msg) && "text" in keys(msg.message))
        return
    end
    message = msg.message

    if message.from == Myid
        return
    end

    if "entities" in keys(message)
        commands = extractcommands(message)
        for cmd in commands
            if cmd == "reload"
                BANLIST = readlines("banlist")
                # CHATS = JSON.parse(open("users.json"))["chats"]
            end
        end
    end

    text = message.text

    if any(occursin.(BANLIST, text))
        @warn "Dameda, this message I'm deleting: " * text
        deleteMessage(message_id = message.message_id, chat_id = message.chat.id)
    end
catch e
    if e isa InterruptException
        @warn "Chavoc is overthrowing... I'm shutting down... for now"
        rethrow(e)
    else 
        rethrow(e)
    end
end
end
