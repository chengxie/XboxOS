import QtQuick 2.3
import "../utils.js" as Utils

FocusScope {
id: root

    property var collection
	property int modelIndex: 0

	//anchors.fill: parent

    signal activateSelected

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
		highlightMoveDuration: 100

		keyNavigationWraps: true

		property int savedIndex: currentCollectionIndex
		onFocusChanged: {
			if (focus)
				currentIndex = savedIndex;
			else {
				savedIndex = currentIndex;
				//currentIndex = -1;
			}
		}
		cacheBuffer: 100
        //currentIndex: focus ? savedIndex : -1
		Component.onCompleted: positionViewAtIndex(savedIndex, ListView.Visible)

		model: collection.platforms
		delegate: Rectangle {
			property bool selected: ListView.isCurrentItem && platformList.focus
			width: (root.width - globalMargin * 2) / 7.0
			height: width *	0.5 //	settings.WideRatio
			radius: vpx(4)
			color: selected ? theme.accent : theme.secondary
			scale: selected ? 1.1 : 1
			Behavior on scale { NumberAnimation { duration: 100 } }

			//anchors.verticalCenter: parent.verticalCenter

			Image {
			id: collectionlogo

				anchors.fill: parent
				anchors.centerIn: parent
				anchors.margins: vpx(15)
				source: "../assets/images/logospng/" + Utils.processPlatformName(modelData.shortName) + ".png"
				//source: "../assets/icons/" + Utils.processPlatformName(modelData.shortName) + ".png"
				sourceSize { width: 256; height: 128 }
				fillMode: Image.PreserveAspectFit
				asynchronous: true
				smooth: true
				opacity: selected ? 1 : 0.5//0.2
				scale: selected ? 1.1 : 1
				Behavior on scale { NumberAnimation { duration: 100 } }
			}

			Text {
			id: platformname

				text: modelData.name
				anchors { fill: parent; margins: vpx(10) }
				color: theme.text
				opacity: selected ? 1 : 0.5//0.2
				scale: selected ? 1.1 : 1
				Behavior on opacity { NumberAnimation { duration: 100 } }
				font.pixelSize: vpx(18)
				font.family: subtitleFont.name
				font.bold: true
				style: Text.Outline; styleColor: theme.main
				visible: collectionlogo.status == Image.Error
				anchors.centerIn: parent
				elide: Text.ElideRight
				wrapMode: Text.WordWrap
				lineHeight: 0.8
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				Behavior on scale { NumberAnimation { duration: 100 } }
			}

			Rectangle {
			id: regborder

				anchors.fill: parent
				color: "transparent"
				border.width: vpx(1)
				border.color: "white"
				opacity: 0.1
				radius: vpx(4)
			}

			// Mouse/touch functionality
			MouseArea {
				anchors.fill: parent
				hoverEnabled: settings.MouseHover == "Yes"
				onEntered: { sfxNav.play(); mainList.currentIndex = platformList.ObjectModel.index; platformList.savedIndex = index; platformList.currentIndex = index; }
				onExited: {}
				onClicked: {
					if (selected)
					{
						currentCollectionIndex = index;
						softwareScreen();
					} else {
						mainList.currentIndex = platformList.ObjectModel.index;
						platformList.currentIndex = index;
					}

				}
			}
		}

		// List specific input
		Keys.onLeftPressed: { sfxNav.play(); decrementCurrentIndex() }
		Keys.onRightPressed: { sfxNav.play(); incrementCurrentIndex() }
		Keys.onPressed: {
			// Accept
			if (api.keys.isAccept(event) && !event.isAutoRepeat) {
				event.accepted = true;
				currentCollectionIndex = platformList.currentIndex;
                activateSelected();
				softwareScreen();            
			}
		}

	}

}
