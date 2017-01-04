# DiscordBot

An improved implementation of my old IRC bot, [BobboBot](https://github.com/JeffBobbo/BobboBot), for Discord.

Commands are implemented as their own modules, which are loaded via the `modules.json` file. Some of the commands provided are game specific, but can easily be removed by removing their entry in `modules.json`.

Currently the bot has some hard-coded rules and isn't particularly flexible.

# Dependencies
- [**Net::Discord**](https://github.com/vsTerminus/Net-Discord)
- **JSON**
- **Mojo::IOLoop**
- **DBI**
  - **DBD::SQLite** (by default, but can be changed)
- **Math::Random::MT**

Various commands have their own dependencies:
- urban
  - WebService::UrbanDictionary
  - WebService::UrbanDictionary::Term
  - WebService::UrbanDictionary::Term::Definition
  - URI::Encode
- haiku
  - Lingua::EN::Syllable
- encode
  - Digest::MD5
  - Digest::SHA
  - Digest::CRC
  - MIME::Base64
