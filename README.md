# Game Jolt API for Godot
Only support authenticating(fancy version of checking if username and token are correct), querying users and trophies plus granting and revoking trophies as of this release. Uses `yield()` to avoid signal/callback hell.

## How to install
Download this plugin, put it into your project and enable it in your project settings. It should then be available as a singtleton.

## How to use
Most functions in the API(except one) uses `yield()` to wait for API requests, etc. so you have to also use `yield()` when calling them.

Example:
```gdscript
var success = yield(GameJolt.authenticate("Username", "SuperSecretToken"), "completed")
```

## What about documentations?
Soon:tm:
