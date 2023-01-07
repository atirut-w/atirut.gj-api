# Home
Integrate Game Jolt API with your Godot game easily and painlessly. No signals
needed.

## Setting up
### Installation
!!! info
    Using the main branch is generally discouraged for production, since it may
    have compat-breaking changes pushed to it at any time. Consider picking
    a branch or a version tag for a major version and sticking to that version
    instead.

#### From GitHub
1. Pick a branch or a tag you want to use.
2. Click on the `<> Code` button and choose "Download as ZIP".
3. Extract the content to your project in the `addons/` directory.

#### As Git submodule
1. Add this repository as a submodule at `addons/`.
2. Checkout a tag or a branch.

### Configuring
1. Navigate to your game's page on Game Jolt, open the three dots menu and
   choose "Manage game".
2. Go to Game API > API Settings and take note of your game's ID and private
   key.
3. Open your project's settings and enable the Game Jolt API plugin.
4. Go to the general tab and choose the Game Jolt API category
5. Put in your game's ID and private key
