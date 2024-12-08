/**
* @file		themes.js
* @brief	Function to generate theme colors.
* @author	My name is CHENG XIE. I am your God! wa hahaha...
* @version	1.0
* @date		2024-12-08
*/

function get(colorBackground, colorLayout) {
	let background		= "#000000";
	let text			= "#ebebeb";
	let gradientstart	= "#001f1f1f";
	let gradientend		= "#FF000000";
	let accent			= "#288928";

	switch (colorBackground) {
		case "White":
			background		= "#ebebeb";
			gradientstart	= "#00ebebeb";
			gradientend		= "#FFebebeb";
			text			= "#101010";
			break;
		case "Gray":
			background		= "#1f1f1f";
			gradientstart	= "#001f1f1f";
			gradientend		= "#FF1F1F1F";
			break;
		case "Blue":
			background		= "#1d253d";
			gradientstart	= "#001d253d";
			gradientend		= "#FF1d253d";
			break;
		case "Green":
			background		= "#054b16";
			gradientstart	= "#00054b16";
			gradientend		= "#00054b16";
			break;
		case "Red":
			background		= "#520000";
			gradientstart	= "#00520000";
			gradientend		= "#FF520000";
			break;
		case "Black":
		default:
			background		= "#000000";
			gradientstart	= "#001f1f1f";
			gradientend		= "#FF000000";
			break;
	}

	switch (colorLayout) {
		case "Light Green": accent = "#65b032"; break;
		case "Turquoise": accent = "#288e80"; break;
		case "Dark Red": accent = "#ab283b"; break;
		case "Light Red": accent = "#e52939"; break;
		case "Dark Pink": accent = "#c52884"; break;
		case "Light Pink": accent = "#ee6694"; break;
		case "Dark Blue": accent = "#30519c"; break;
		case "Light Blue": accent = "#288dcf"; break;
		case "Orange": accent = "#ed5b28"; break;
		case "Yellow": accent = "#ed9728"; break;
		case "Magenta": accent = "#b857c6"; break;
		case "Purple": accent = "#825fb1"; break;
		case "Dark Gray": accent = "#5e5c5d"; break;
		case "Light Gray": accent = "#818181"; break;
		case "Steel": accent = "#768294"; break;
		case "Stone": accent = "#658780"; break;
		case "Dark Brown": accent = "#806044"; break;
		case "Light Brown": accent = "#7e715c"; break;
		case "Dark Green": 
		default:
			accent = "#288928";
			break;
	}

	return {
		primary:		background,
		secondary:      "#303030",
		accent:         accent,
		highlight:      accent,
		text:           text,
		button:         accent,
		gradientstart:  gradientstart,
		gradientend:    gradientend
	};
}
