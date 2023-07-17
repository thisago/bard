import pkg/bard

let ai = newBard "session id"

var chat = ai.newChat

discard chat.prompt "my name is Luke"
echo chat.prompt "what's my name?"
