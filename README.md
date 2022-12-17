# Puntherline's Propinfo

<br>

## Features
- Point your gun at nearly any ped, vehicle or object to find out its' hash, name, position and rotation.
- Draw boxes around peds, vehicles and objects to mark them easily.
- Draw text about multiple peds, vehicles or objects containing their info on screen.
- In game customizability with client-sided saving functionality using resource KVP's.
- Periodic version checks.
- Native addon vehicle support, just click Update in game.
- Potential addon ped and prop support via community based lists.
- HTML based UI for all the customizable options.
- Only slightly botched code.

<br>

## Installation
- Go to the [Releases](https://github.com/Puntherline/pun_propinfo/releases) page and download `pun_propinfo.zip`.
- Unzip the `pun_propinfo` folder inside your `resources` folder or a sub-folder containing `[square_brackets]`.
- Add `ensure pun_propinfo` to your `server.cfg` or make sure that your sub-folder is being started instead. [More info](https://docs.fivem.net/docs/scripting-manual/introduction/introduction-to-resources/#resource-directories).

<br>

## Setup
| Feature | Enable for | What you need to do |
| --- | --- | --- |
| `propinfo` command use | Everybody | • Set `anybody_use_command` to `true` in config. |
| `propinfo` command use | Certain people | • Set `anybody_use_command` to `false` in config.<br> • Give users or groups the `propinfo_use` ace. [More info](https://docs.fivem.net/docs/server-manual/server-commands/#access-control-commands). |
| Updating proplist | Everybody (Not recommended!) | • Set `anybody_can_update` to `true` in config. |
| Updating proplist | Certain people | • Set `anybody_can_update` to `false` in config.<br>• Give users or groups the `propinfo_update` ace. [More info](https://docs.fivem.net/docs/server-manual/server-commands/#access-control-commands). |
| Updating proplist | Server only | • Set `anybody_can_update` to `false` in config.<br>• Remove the `propinfo_update` ace from all groups and users. |

<br>

## In Game Use
Type `/propinfo` into your chat resource or into your F8 client console, from there it should be fairly obvious: Click the headings of a setting to enable or disable it. When enabled, it will give you a few more options you can tweak to your liking. The options will be saved locally on your PC, so the next time you use pun_propinfo, your settings should remain the same!

To update the proplist, you can either type `proplist update` into the server console which will download and generate a default proplist. This will contain all vehicles that are in the game by default. If you are using addon vehicles on your server, go in game, open the UI and click the "Update Proplist" button and wait for it to finish, then ensure the resource. By doing this via the client side, all addon vehicles that are on your server will automatically be added!
