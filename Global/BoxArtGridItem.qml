// gameOS theme
// Copyright (C) 2018-2020 Seth Powell 
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

import QtQuick 2.8
import QtGraphicalEffects 1.12
import "../utils.js" as Utils

Item {
id: root

	property bool showTitles: settings.AlwaysShowTitles === "Yes"
	property bool showHighlightedTitles: settings.AlwaysShowHighlightedTitles === "Yes"
	property int verticalSpacing: 0
	property int horizontalSpacing: 0
    property bool selected
    property var gameData: modelData

    scale: selected ? 1.1 : 1
    z: selected ? 10 : 1

    signal activate
    signal highlighted

    Behavior on scale { NumberAnimation { duration: 100 } }

    Item {
    id: container

		anchors {
			top: parent.top 
			left: parent.left
			right: parent.right; rightMargin: horizontalSpacing
			bottom: parent.bottom; bottomMargin: verticalSpacing
		}
              
        Image {
        id: screenshot
            anchors.fill: parent

            asynchronous: true
            source: Utils.boxArt(gameData)
            sourceSize { width: root.width; height: root.height }
            fillMode: Image.PreserveAspectCrop
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
            id: favicon

                anchors { 
                    right: parent.right; rightMargin: parent.width * 0.05
                    top: parent.top; topMargin: parent.width * 0.05 
                }
				width: parent.width * 0.15
                height: width
                radius: width / 2
                color: theme.accent
                visible: gameData.favorite
                Image {
                    source: "../assets/images/favicon.svg"
                    asynchronous: true
                    anchors.fill: parent
                    anchors.margins: parent.width * 0.2       
                }
            }
        }

        Rectangle {
        id: regborder
            anchors.fill: parent
            color: "transparent"
            border.width: vpx(1)
            border.color: "white"
            opacity: 0.2
        }

        Rectangle {
        id: overlay
            anchors.fill: parent
            color: screenshot.source == "" ? theme.secondary : "black"
            opacity: screenshot.source == "" ? 1 : selected ? 0.0 : 0.2
        }
 
    }

	DropShadow {
		source: container
		anchors.fill: container
		horizontalOffset: selected ? vpx(2) : vpx(1)
		verticalOffset: horizontalOffset
		radius: 8.0
		samples: 12
		color: "#000000"
	}

	ItemBorder { 
		anchors.fill: container
		showHighlightedTitles: root.showHighlightedTitles
	}

    Text {
    id: title
        anchors {
            top: container.bottom; topMargin: vpx(5)
            left: parent.left; right: parent.right
        }
        visible: showTitles && !selected
        text: modelData ? modelData.title : ''
        color: theme.text
        font {
            family: subtitleFont.name
            pixelSize: vpx(16)
            bold: false
        }
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Text {
    id: platformname

        text: modelData.title
        anchors { fill: parent; margins: vpx(10) }
        color: "white"
        scale: selected ? 1.1 : 1
        Behavior on opacity { NumberAnimation { duration: 100 } }
        font.pixelSize: vpx(18)
        font.family: subtitleFont.name
        font.bold: true
        style: Text.Outline; styleColor: theme.primary
        visible: screenshot.status === Image.Null || screenshot.status === Image.Error
        anchors.centerIn: parent
        elide: Text.ElideRight
        wrapMode: Text.WordWrap
        lineHeight: 0.8
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Loader {
    id: spinnerloader

        anchors.centerIn: parent
        active: screenshot.status === Image.Loading
        sourceComponent: loaderspinner
    }

    Component {
    id: loaderspinner
    
        Image {
            source: "../assets/images/loading.png"
            width: vpx(50)
            height: vpx(50)
            asynchronous: true
            sourceSize { width: vpx(50); height: vpx(50) }
            RotationAnimator on rotation {
                loops: Animator.Infinite;
                from: 0;
                to: 360;
                duration: 500
            }
        }
    }

    // List specific input
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
        onClicked: {
            sfxNav.play();
            activate();
        }
    }
    
}
