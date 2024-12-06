import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.12

FocusScope {
id: root
	
	property int virtualKeyboardIndex: 0

	Rectangle {
	id: buttonKeyContainer
		anchors {
			top: parent.top
			left: parent.left
		}
		width: parent.width
		height: 35
		color: "#171717"
		border.color: "#171717"
		radius: 0
		border.width: 3

		property int selectedIndex: 0

		Row {
			width: parent.width
			height: parent.height
			spacing: 0

			Repeater {
				model: 2
				Image {
					width: buttonKeyContainer.width / 2
					height: parent.height
					source: "../assets/images/key/" + (index ? "del" : "spacebar") + ".svg" 
					fillMode: Image.PreserveAspectFit
				}
			}
		}

		Rectangle {
		id: selectorRectangle
			width: buttonKeyContainer.width / 2
			height: 35
			x: width * buttonKeyContainer.selectedIndex;
			color: "transparent"
			border.color: "white"
			border.width: 2
			visible: root.focus && buttonKeyContainer.focus
			clip: true
			radius:0
		}

		Keys.onPressed: {
			sfxNav.play();
			if (!event.isAutoRepeat) {
				if (event.key === Qt.Key_Left) {
					if (buttonKeyContainer.selectedIndex > 0) {
						buttonKeyContainer.selectedIndex--;
					}
				} else if (event.key === Qt.Key_Right) {
					if (buttonKeyContainer.selectedIndex < 1) {
						buttonKeyContainer.selectedIndex++;
					} else {
						if (gamesFiltered.hasResults) {
							resultsGrid.focus = true;
						} else {
							virtualKeyboardIndex = 0
							virtualKeyboardContainer.focus = true;
						}
					}
				} else if (event.key === Qt.Key_Down) {
					if (buttonKeyContainer.selectedIndex === 0) {
						virtualKeyboardIndex = 1
					} else {
						virtualKeyboardIndex = 4
					}
					virtualKeyboardContainer.focus = true;
				} else if (!event.isAutoRepeat && api.keys.isAccept(event)) {
					if (buttonKeyContainer.selectedIndex === 0) {
						searchText += " ";
					} else if (buttonKeyContainer.selectedIndex === 1) {
						searchText = searchText.slice(0, -1);
					}
				}
			}
		}
	}

	Rectangle {
	id: virtualKeyboardContainer
		width: parent.width
		height: parent.height * 0.38
		color: "#171717"
		border.color: "#171717"
		radius: 0
		border.width: 3
		focus: true

		anchors {
			top:buttonKeyContainer.bottom
			left: parent.left
		}

		Column {
			anchors.fill: parent
			spacing: 5

			GridLayout {
			id: keyboardGrid
				columns: 6
				rows: 6
				anchors.horizontalCenter: parent.horizontalCenter
				columnSpacing: (parent.width - (6 * 40)) / 7
				rowSpacing: (parent.height - (6 * 40)) / 7

				Repeater {
					model: 26 + 10
					Rectangle {
						width: 40
						height: 40
						clip: true
						color: "transparent"
						border.color: {
							if (virtualKeyboardIndex === index && virtualKeyboardContainer.focus) {
								return root.focus ? "white" : "transparent"
							} else if (virtualKeyboardContainer.focus) {
								return "transparent"
							}
							return "#171717"
						}
						border.width: 0.5
						radius: 0

						Item {
							anchors.fill: parent
							Text {
								anchors.centerIn: parent
								text: index < 26 ? String.fromCharCode(97 + index) : (index < 26 + 10 ? index - 26 : "")
								// Tamaño del texto proporcional al tamaño de la celda
								font.pixelSize: Math.min(keyboardGrid.width / keyboardGrid.columns, keyboardGrid.height / keyboardGrid.rows) * 0.5
								color: "grey"
								horizontalAlignment: Text.AlignHCenter
								verticalAlignment: Text.AlignVCenter
							}
						}
					}
				}
			}
		}

		Keys.onPressed: {
			sfxNav.play();
			if (!event.isAutoRepeat && api.keys.isAccept(event)) {
				if (virtualKeyboardIndex < 26) {
					searchText += String.fromCharCode(97 + virtualKeyboardIndex);
				} else {
					searchText += virtualKeyboardIndex - 26;
				}
			} else if (event.key === Qt.Key_Left && virtualKeyboardIndex === 0) {
				//searchVisible = false;
				//sidebarFocused = true;
			} else if (event.key === Qt.Key_Left) {
				if (virtualKeyboardIndex > 0 ){
					//if (virtualKeyboardIndex === 5 || virtualKeyboardIndex === 11 || virtualKeyboardIndex === 17 || virtualKeyboardIndex === 23 || virtualKeyboardIndex === 29 || virtualKeyboardIndex === 35 || virtualKeyboardIndex === 41) {
						////searchVisible = false;
						////sidebarFocused = true;
					//}
					virtualKeyboardIndex--;
				}
			} else if (event.key === Qt.Key_Right) {
				if (virtualKeyboardIndex < (26 + 12) - 1) {
					if (gamesFiltered.hasResults) {
						if (virtualKeyboardIndex === 5 || virtualKeyboardIndex === 11 || virtualKeyboardIndex === 17 || virtualKeyboardIndex === 23 || virtualKeyboardIndex === 29 || virtualKeyboardIndex === 35) {
							resultsGrid.focus = true;
							return;
						}
					}
					virtualKeyboardIndex++;
					//if (virtualKeyboardIndex === 6 || virtualKeyboardIndex === 12 || virtualKeyboardIndex === 18 || virtualKeyboardIndex === 24 || virtualKeyboardIndex === 30 || virtualKeyboardIndex === 36) {
						//resultsGrid.focus = true;
					//}
				}
			} else if (event.key === Qt.Key_Up) {
				if (virtualKeyboardIndex >= 6) {
					virtualKeyboardIndex -= 6;
				} else if (virtualKeyboardIndex >= 0 && virtualKeyboardIndex <= 2) {
					buttonKeyContainer.selectedIndex = 0;
					buttonKeyContainer.focus = true
				} else if (virtualKeyboardIndex >= 3 && virtualKeyboardIndex <= 5) {
					buttonKeyContainer.selectedIndex = 1;
					buttonKeyContainer.focus = true
				}
			} else if (event.key === Qt.Key_Down) {
				if (virtualKeyboardIndex < (26 + 10) - 6) {
					virtualKeyboardIndex += 6;
				}  else if (event.key === Qt.Key_Down) {
					if (virtualKeyboardIndex < (26 + 10) - 6) {
						virtualKeyboardIndex += 6;
					} else if (virtualKeyboardIndex >= 30 && virtualKeyboardIndex <= 35) {
						//if (searchResults.visible && resultsList.model.count > 0) {
							//resultsList.focus = true;
						//}
					}
				}
			} else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
				if (virtualKeyboardIndex < 26) {
					searchText += String.fromCharCode(65 + virtualKeyboardIndex);
				} else {
					searchText += virtualKeyboardIndex - 26;
				}
			}
		}
	}


}










