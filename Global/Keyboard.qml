import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.12

FocusScope {
id: root
	
	property int virtualKeyboardIndex: 0
	property string searchText: searchTerm

    signal changeFocus

	Rectangle {
	id: buttonKeyContainer
		anchors {
			top: parent.top
			left: parent.left
		}
		width: parent.width
		height: vpx(35)
		color: "#171717"
		border.color: "#171717"
		radius: 0
		border.width: vpx(3)

		property int selectedIndex: 0

		Row {
			width: parent.width
			height: parent.height
			spacing: 0

			Repeater {
			id: buttonKeyRepeater
				model: 2
				Image {
					width: buttonKeyContainer.width / buttonKeyRepeater.count
					height: parent.height
					source: "../assets/images/key/" + (index ? "del" : "spacebar") + ".svg" 
					fillMode: Image.PreserveAspectFit
				}
			}
		}

		Rectangle {
		id: selectorRectangle
			width: parent.width / buttonKeyRepeater.count
			height: vpx(35)
			x: width * parent.selectedIndex;
			color: "transparent"
			border.color: "white"
			border.width: vpx(2)
			visible: root.focus && parent.focus
			clip: true
			radius:0
		}

		function onKeyPressed(event) {
			switch (event.key) {
				case Qt.Key_Left: {
					if (selectedIndex > 0) {
						selectedIndex--;
					} else {
						selectedIndex = buttonKeyRepeater.count - 1;
					}
				}
				break;
				case Qt.Key_Right: {
					if (selectedIndex < (buttonKeyRepeater.count - 1)) {
						selectedIndex++;
					} else {
						changeFocus()
						if (root.focus) {
							selectedIndex = 0;
						}
					}
				}
				break;
				case Qt.Key_Up: {
					if (selectedIndex === 0) {
						virtualKeyboardIndex = 31
					} else {
						virtualKeyboardIndex = 34
					}
					virtualKeyboardContainer.focus = true;
				} 
				break;
				case Qt.Key_Down: {
					if (selectedIndex === 0) {
						virtualKeyboardIndex = 1
					} else {
						virtualKeyboardIndex = 4
					}
					virtualKeyboardContainer.focus = true;
				} 
				break;
				default: {
					if (api.keys.isAccept(event)) {		
						if (selectedIndex === 0) {
							searchText += " ";
						} else if (selectedIndex === 1) {
							searchText = searchText.slice(0, -1);
						}
					}
				}
				break;
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
		border.width: vpx(3)
		focus: true

		anchors {
			top:buttonKeyContainer.bottom
			left: parent.left
		}

		Column {
			anchors.fill: parent
			spacing: vpx(5)

			GridLayout {
			id: keyboardGrid
				columns: 6
				rows: 6
				anchors.horizontalCenter: parent.horizontalCenter
				columnSpacing: (parent.width - vpx((6 * 40))) / 7
				rowSpacing: (parent.height - vpx((6 * 40))) / 7

				Repeater {
					model: 26 + 10
					Rectangle {
						width: vpx(40)
						height: vpx(40)
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
						border.width: vpx(0.5)
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
		
		function isLeftBoundary(v) {
			//return v in [0, 6, 12, 18, 24, 30];
			return v % 6 === 0;
		}

		function isRightBoundary(v) {
			//return v in [5, 11, 17, 23, 29, 35];
			return v % 6 === 5;
		}

		function isTopBoundary(v) {
			return v >= 0 && v <= 5;
		}

		function isBottomBoundary(v) {
			return v >= 30 && v <= 35;
		}

		function gotoButtonKey(index) {
			buttonKeyContainer.selectedIndex = (index % 30 < 3) ? 0 : 1;
			buttonKeyContainer.focus = true
		}

		function onKeyPressed(event) {
			switch (event.key) {
				case Qt.Key_Left: {
					if (isLeftBoundary(virtualKeyboardIndex)) {
						virtualKeyboardIndex += 5;
					} else {
						virtualKeyboardIndex--;
					}
				}
				break;
				case Qt.Key_Right: {
					if (isRightBoundary(virtualKeyboardIndex)) {
						changeFocus();
						if (root.focus) {
							virtualKeyboardIndex -= 5;
						}
					} else {
						virtualKeyboardIndex++;
					}
				}
				break;
				case Qt.Key_Up: {
					if (virtualKeyboardIndex >= 6) {
						virtualKeyboardIndex -= 6;
					} else {
						gotoButtonKey(virtualKeyboardIndex);
					}
				}
				break;
				case Qt.Key_Down: {
					if (!isBottomBoundary(virtualKeyboardIndex)) {
						virtualKeyboardIndex += 6;
					} else {
						gotoButtonKey(virtualKeyboardIndex);
					}
				}
				break;
				default: {
					if (!event.isAutoRepeat && api.keys.isAccept(event)) {
						if (virtualKeyboardIndex < 26) {
							searchText += String.fromCharCode(97 + virtualKeyboardIndex);
						} else {
							searchText += virtualKeyboardIndex - 26;
						}
					}
				}
				break;
			}
		}
	}

	Keys.onPressed: {

        if (api.keys.isCancel(event) && !event.isAutoRepeat) {
			if (searchText.length > 0) {
				sfxNav.play();
				searchText = searchText.slice(0, -1);
				event.accepted = true;
			} else {
				event.accepted = false;
			}
		} else {
			sfxNav.play();
			if (buttonKeyContainer.focus) {
				buttonKeyContainer.onKeyPressed(event);
			} else {
				virtualKeyboardContainer.onKeyPressed(event);
			}
		}
	}

}










