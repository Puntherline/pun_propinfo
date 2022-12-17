// Variables
var setting_values = {
	idgun: false,
	all_peds_info: false,
	all_vehicles_info: false,
	all_objects_info: false
};
var resetting_settings = false;



// Toggle a setting
function toggleClicked(e) {

	// Get ID of parent elements until one is found
	var target_id = "";
	var target_element = undefined;
	for (const [_, v] of Object.entries(e.composedPath())) {
		if (v.id != undefined) {
			if (v.id.length > 0) {
				target_id = v.id;
				target_element = v;
				break;
			}
		}
	}

	// Update values and indicators
	setting_values[target_id] = !setting_values[target_id];
	target_element.querySelector(".setting_indicator").classList.toggle("enabled");
	target_element.querySelector(".setting_indicator").classList.toggle("disabled");

	// Toggle setting specific options visible
	var specific_settings = target_element.querySelector(".setting_info > .setting_options");
	if (specific_settings) {
		if (setting_values[target_id] == true) {
			specific_settings.removeAttribute("style");
		} else {
			specific_settings.style.display = "none";
		}
	}

	// Inform client sided Lua
	fetch("https://pun_propinfo/setSettingValue", {
		method: "POST",
		headers: {"Content-Type": "application/json; charset=UTF-8"},
		body: JSON.stringify({
			setting: target_id,
			value: setting_values[target_id]
		})
	});
}



// Update an option
function optionUpdated(e) {

	// Ignore if currently resetting settings
	if (!resetting_settings) {

		// Get ID of element
		var target_element = e.composedPath()[0];
		var target_id = target_element.id;
		var target_type = target_element.type;
		var target_value = "";

		// Get input type
		if (target_type == "checkbox") {
			target_value = target_element.checked;
		} else if (target_type == "number") {
			target_value = Number(target_element.value);
			if (target_value < target_element.min) {
				target_value = Number(target_element.min);
				target_element.value = target_value;
			} else if (target_value > target_element.max) {
				target_value = Number(target_element.max);
				target_element.value = target_value;
			}
		}

		// Inform client sided Lua
		fetch("https://pun_propinfo/setOptionValue", {
			method: "POST",
			headers: {"Content-Type": "application/json; charset=UTF-8"},
			body: JSON.stringify({
				setting: target_id,
				value: target_value
			})
		});
	}
}



// Listen for messages from lua
window.addEventListener("message", (e) => {
	if (e.data.type == "menu") {
		if (e.data.show) {
			document.getElementById("menu").style.display = "flex";
			if (e.data.admin == 1) {
				var hidden_elements = document.querySelectorAll(".admin");
				for (i = 0; i < hidden_elements.length; i++) {
					hidden_elements[i].classList.remove("admin");
				}
			}
		} else {
			document.getElementById("menu").style.display = "none";
		}
	} else if (e.data.type == "options") {
		for (const [k, v] of Object.entries(e.data.values)) {
			var target_element = document.getElementById(k);
			if (target_element.type == "checkbox") {
				target_element.checked = v;
			} else {
				target_element.value = v;
			}
		}
		resetting_settings = false;
	}
});



// Adding event listeners to all buttons
window.addEventListener("DOMContentLoaded", () => {

	// Handling all setting toggles
	var settings_toggles = document.querySelectorAll(".menu_item.toggle > .setting_info > h2");
	for (i = 0; i < settings_toggles.length; i++) {
		settings_toggles[i].addEventListener("click", toggleClicked);
	}

	// Get all inputs
	var option_inputs = document.querySelectorAll("input");
	for (i = 0; i < option_inputs.length; i++) {
		option_inputs[i].addEventListener("change", optionUpdated);
	}

	// Update button
	document.querySelector("#update_proplist > .setting_info > h2").addEventListener("click", () => {
		fetch("https://pun_propinfo/requestProplistUpdate", {
			method: "POST",
			headers: {"Content-Type": "application/json; charset=UTF-8"}
		});
	});

	// Close button
	document.getElementById("close_button").addEventListener("click", () => {
		fetch("https://pun_propinfo/closeMenu", {
			method: "POST",
			headers: {"Content-Type": "application/json; charset=UTF-8"}
		});
		document.getElementById("menu").style.display = "none";
	});

	// Reset settings button
	document.getElementById("adv_reset_all_settings").addEventListener("click", () => {
		resetting_settings = true;
		fetch("https://pun_propinfo/resetSettings", {
			method: "POST",
			headers: {"Content-Type": "application/json; charset=UTF-8"}
		});
	});
});