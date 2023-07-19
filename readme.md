<div align=center>

# Bard

#### Nim interface for Google Bard batchexecute API

**[About](#about) - [Usage](#usage)** - [License](#license)

</div>

# About

Google Bard AI batchexecute implementation in Nim

Take a look at [clibard](https://github.com/thisago/clibard), an example of how
use this lib.

This project was based in

- [EvanZhouDev/bard-ai ↗](https://github.com/EvanZhouDev/bard-ai "Go to Github")
- [acheong08/Bard ↗](https://github.com/acheong08/Bard "Go to Github")

## Usage

**[Individual prompts example](examples/single.nim)**

```nim
let ai = waitFor newBardAi(
  psid = "__Session-1PSID cookie",
  psidts = "__Session-1PSIDTS cookie"
)

echo waitFor(ai.prompt "Tell me an Asian traditional history in ten words").text
```

<details>
<summary>output</summary>

```text
Sure, here is an Asian traditional history in 10 words:

* **Ancient civilizations, rich cultures, and diverse peoples.**

This 10-word summary captures the essence of Asian traditional history. It highlights the long and rich history of the continent, as well as the diversity of its peoples and cultures. From the ancient civilizations of China, India, and Japan to the more recent cultures of Southeast Asia and the Middle East, Asia is a continent with a vast and complex history.

Here are some other 10-word summaries of Asian traditional history:

* **The Silk Road, trade, and cultural exchange.**
* **Buddhism, Hinduism, and Confucianism.**
* **Imperial dynasties, wars, and revolutions.**
* **Monumental architecture, art, and literature.**
* **Myths, legends, and folktales.**

These are just a few examples of the many ways to summarize Asian traditional history in 10 words. The continent's rich and complex history can be described in many different ways, but these 10-word summaries capture the essence of what makes Asian history so fascinating.
```

</details>

---

**[Chat example](examples/chat.nim)**

```nim
let ai = waitFor newBardAi(
  psid = getEnv("bard_psid"),
  psidts = getEnv("bard_psidts")
)

var chat = ai.newBardAiChat

discard waitFor chat.prompt "my name is Luke"
echo waitFor(chat.prompt "what's my name?").text
```

<details>
<summary>output</summary>

```text
Your name is Luke. You told me that in your previous response.
```

</details>

## License

This library is FOSS, licensed over MIT license.
