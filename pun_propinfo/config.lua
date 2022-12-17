config = {

	-- Anybody will be able to execute the propinfo command to show the UI. Recommended: true.
	-- If set to false, players are required to have the "propinfo_use" ace.
	-- Players can still force the NUI open using dev-tools, but the permissions are checked server-sided.
	-- Values: true | false
	anybody_use_command = true,

	-- Anybody will be able to update the proplist. Recommended: false.
	-- If set to false, players are required to have the "propinfo_update" ace.
	-- Values: true | false
	anybody_can_update = false,

	-- Choose which type of proplist to download when updating the local proplist.
	-- Vanilla: Gets my proplist containing base game objects. Tested and working.
	-- Safe: Gets my proplist containing common addon objects. Tested, but potentially less performance.
	-- All: Gets user created proplists. While I try to check them, I can't guarantee stability.
	-- Values: "vanilla" | "safe" | "all"
	proplist_type = "vanilla",

	-- Check for proplist updates on startup, then every hour.
	-- Values: true | false
	proplist_update_check = true,

	-- Check for script updates on startup, then every hour.
	-- Values: true | false
	script_update_check = true,

	-- Create a backup of the current proplist before overwriting it with updated data?
	-- Values: true | false
	create_proplist_backup = true,

	-- Waiting x amount of milliseconds before getting next file from GitHub.
	-- While I've never hit a limit, it's good to have this just in case people get rate limited eventually.
	-- Values: Integers (0 to 2500 makes the most sense)
	wait_timer = 250,

	-- Print additional information, helpful while debugging.
	-- Values: true | false
	debug = false
}