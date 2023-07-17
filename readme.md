<div align=center>

# Bard

#### Nim interface of Google Bard free API<br></small><font size="1">(ps: with cli :D)</font>

**[About](#about) - [Usage](#usage)** - [License](#license)

</div>

# About

This project was based in

- [EvanZhouDev/bard-ai ↗](https://github.com/EvanZhouDev/bard-ai "Go to Github")
- [acheong08/Bard ↗](https://github.com/acheong08/Bard "Go to Github")

## Usage

### As CLI app

**Start chat**

```bash
$ bard chat
```

**Single question**

```bash
$ bard prompt Tell me an Asian traditional history in ten words
```

### As library

```nim
import pkg/bard

let ai = newBard "session id"

# single prompt
echo ai.prompt "Tell me an Asian traditional history in ten words"

# conversation
var chat = ai.newChat

discard chat.prompt "my name is Luke"
echo chat.prompt "what's my name?"
```

## License

This library is FOSS, licensed over MIT license.
