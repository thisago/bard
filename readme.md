<div align=center>
<img alt="Google Bard Logo" src="https://camo.githubusercontent.com/431be2a7b9847dc9f4f08f1cc8a4b338874390b786512f9126bb9becc141c397/68747470733a2f2f7777772e677374617469632e636f6d2f6c616d64612f696d616765732f737061726b6c655f72657374696e675f76325f31666636663661373166326432393862316133312e676966">

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

> **Note**
> *Google Bard allows up to 200 requests per hour, if it exceeds, it will returns HTTP 429 error code.* - Source: Google Bard

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

## FAQ

## What is "Google Bard sent an unrecognizable response" error?

<details>
  <summary>View error example</summary>

  ```
  Exception message: Google Bard sent an unrecognizable response: `)]}'

  [["wrb.fr",null,null,null,null,[8]],["di",69],["af.httprm",69,"3783202389886124604",21]]`
   [BardUnrecognizedResp]
  ```
</details>

**It's generally rate limit.**


## License

This library is FOSS, licensed over MIT license.
