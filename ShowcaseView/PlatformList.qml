import QtQuick 2.3
import QtGraphicalEffects 1.0
import "../utils.js" as Utils

FocusScope {
id: root

    property var collection
	property var gameList: collection.search
    property alias currentIndex: platformList.currentIndex

    signal activateSelected
    signal listHighlighted


	ListView {
	id: platformList

		focus: root.focus
		anchors.fill: parent
		width: parent.width
		spacing: vpx(12)
		snapMode: ListView.SnapOneItem
		orientation: ListView.Horizontal
		preferredHighlightBegin: globalMargin
		preferredHighlightEnd: parent.width - globalMargin
		highlightRangeMode: ListView.StrictlyEnforceRange
		highlightMoveDuration: 200
		keyNavigationWraps: false

		onFocusChanged: {
			if (focus)
                currentIndex = collection.index;
			else {
                collection.index = currentIndex;
			}
		}

		Component.onDestruction: {
			collection.index = currentIndex;
		}

		Component.onCompleted: {
			currentIndex = collection.index
			positionViewAtIndex(currentIndex, ListView.Visible)
		}

		model: gameList.games
		delegate: Item {
			signal activate
			signal highlighted
			property bool selected:		ListView.isCurrentItem && ListView.view.focus
			width:						(root.width - globalMargin * 2) / 7.0
			height:						width *	0.5
			scale:						selected ? 1.1 : 1
			z:							selected ? 10 : 1
			Behavior on scale { NumberAnimation { duration: 100 } }

			onActivate: {
				if (selected) {
					activateSelected();
				} else {
					ListView.view.currentIndex = index;
				}
			}

			onHighlighted: {
				listHighlighted();
				ListView.view.currentIndex = index;
			}

			Rectangle {
			id: platform

				anchors.fill: parent
				radius: vpx(4)
				color: selected ? theme.accent : theme.secondary

				Image {
				id: collectionlogo

					anchors.fill: parent
					anchors.centerIn: parent
					anchors.margins: vpx(15)
					//source: "../assets/images/logospng/" + Utils.processPlatformName(modelData.shortName) + ".png"
					source: "../assets/icons/" + Utils.processPlatformName(modelData.shortName) + ".png"
					sourceSize { width: 256; height: 128 }
					fillMode: Image.PreserveAspectFit
					asynchronous: true
					smooth: true
					opacity: selected ? 1 : 0.5
					scale: selected ? 1.1 : 1
					Behavior on scale { NumberAnimation { duration: 100 } }
				}

				Text {
				id: platformname

					text: modelData.name
					anchors { fill: parent; margins: vpx(10) }
					color: theme.text
					opacity: selected ? 1 : 0.5
					Behavior on opacity { NumberAnimation { duration: 100 } }
					scale: selected ? 1.1 : 1
					Behavior on scale { NumberAnimation { duration: 100 } }
					font.pixelSize: vpx(18)
					font.family: subtitleFont.name
					font.bold: true
					style: Text.Outline; styleColor: theme.primary
					visible: collectionlogo.status == Image.Error
					anchors.centerIn: parent
					elide: Text.ElideRight
					wrapMode: Text.WordWrap
					lineHeight: 0.8
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
				}

				Rectangle {
				id: regborder
					anchors.fill: parent
					color: "transparent"
					border.width: vpx(1)
					border.color: "white"
					opacity: 0.2
					radius: vpx(4)
				}

			}

			DropShadow {
				source: platform
				anchors.fill: platform
				horizontalOffset: selected ? vpx(2) : vpx(1)
				verticalOffset: horizontalOffset
				radius: 8.0
				samples: 12
				color: "#000000"
			}

			Keys.onPressed: {
				// Accept
				if (api.keys.isAccept(event) && !event.isAutoRepeat) {
					event.accepted = true;
					activate();
				}
			}

			// Mouse/touch functionality
			MouseArea {
				anchors.fill: parent
				hoverEnabled: settings.MouseHover == "Yes"
				onEntered: { sfxNav.play(); highlighted(); }
				onClicked: { sfxNav.play(); activate(); }
			}
		}

		Keys.onLeftPressed: { sfxNav.play(); decrementCurrentIndex() }
		Keys.onRightPressed: { sfxNav.play(); incrementCurrentIndex() }

	}

}
