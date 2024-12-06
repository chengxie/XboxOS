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

import QtQuick 2.3
import QtQuick.Layouts 1.11
import SortFilterProxyModel 0.2
import QtGraphicalEffects 1.0
import QtMultimedia 5.9
import QtQml.Models 2.10
import "../Global"
import "../GridView"
import "../GameDetails"
import "../utils.js" as Utils
import "qrc:/qmlutils" as PegasusUtils

FocusScope {
id: root

    function storeIndices(secondary) {
        storedHomePrimaryIndex = mainList.currentIndex;
        if (secondary)
            storedHomeSecondaryIndex = secondary;
    }

    Component.onDestruction: storeIndices();
    
    anchors.fill: parent

    Item {
    id: header

        width: parent.width
        height: vpx(70)
        z: 10

        LinearGradient {
			visible: false
            width: parent.width
            height: parent.height * 0.8
            anchors.left: parent.left
            start: Qt.point(0, 0)
            end: Qt.point(0, height)
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#FF000000" }
                GradientStop { position: 1.0; color: "#00000000" }
            }
        } 

        Image {
        id: logo

            width: vpx(150)
            anchors { left: parent.left; leftMargin: globalMargin }
            source: "../assets/images/gameOS-logo.png"
            sourceSize { width: 150; height: 100}
            fillMode: Image.PreserveAspectFit
            smooth: true
            asynchronous: true
            anchors.verticalCenter: parent.verticalCenter
            visible: false //!ftueContainer.visible
        }

        Rectangle {
        id: settingsbutton

            width: vpx(30)
            height: vpx(30)
            anchors { 
			    verticalCenter: parent.verticalCenter
			    right: sysTime.left; rightMargin: vpx(10)
			}
            color: focus ? theme.accent : "transparent"
            radius: height/2
            opacity: focus ? 1 : 0.2

            onFocusChanged: {
                sfxNav.play()
                if (focus)
                    mainList.currentIndex = -1;
                else
                    mainList.currentIndex = 0;
            }

            Keys.onDownPressed: mainList.focus = true;
            Keys.onPressed: {
                // Accept
                if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                    event.accepted = true;
                    settingsScreen();            
                }
                // Back
                if (api.keys.isCancel(event) && !event.isAutoRepeat) {
                    event.accepted = true;
                    mainList.focus = true;
                }
            }
            // Mouse/touch functionality
            MouseArea {
                anchors.fill: parent
                hoverEnabled: settings.MouseHover == "Yes"
                onEntered: settingsbutton.focus = true;
                onExited: settingsbutton.focus = false;
                onClicked: settingsScreen();
            }
        }

        Image {
        id: settingsicon

            width: height
            height: vpx(20)
            anchors.centerIn: settingsbutton
            smooth: true
            asynchronous: true
            source: "../assets/images/settingsicon.svg"
            opacity: root.focus ? 0.8 : 0.5
        }
		
        Text {
        id: sysTime

            function set() {
                sysTime.text = Qt.formatTime(new Date(), "hh:mm AP")
            }

            Timer {
                id: textTimer
                interval: 60000 // Run the timer every minute
                repeat: true
                running: true
                triggeredOnStart: true
                onTriggered: sysTime.set()
            }

            anchors {
                top: parent.top; bottom: parent.bottom
                right: parent.right; rightMargin: vpx(25)
            }
            color: "white"
            font.pixelSize: vpx(18)
            font.family: subtitleFont.name
            horizontalAlignment: Text.Right
            verticalAlignment: Text.AlignVCenter
        }

    }


    ListView {
    id: mainList

        anchors.fill: parent
        focus: true
		highlightMoveDuration: 200
		highlightRangeMode: ListView.StrictlyEnforceRange 
		preferredHighlightBegin: header.height
		preferredHighlightEnd: parent.height - (helpMargin * 2)
		snapMode: ListView.SnapOneItem
        keyNavigationWraps: false
        currentIndex: storedHomePrimaryIndex
		spacing: vpx(10)
        
        footer: Item { height: helpMargin }

        model: modelList
		delegate: ShowcaseViewItem {
			collection: modelList[index]
			width: root.width
		}

		//cacheBuffer: 100
		Component.onCompleted: {
			positionViewAtIndex(currentIndex, ListView.Visible)
			//console.log("currentIndex: " + currentIndex);
		}

        Keys.onUpPressed: {
            sfxNav.play();
            do {
                decrementCurrentIndex();
            } while (!currentItem.enabled);
        }

        Keys.onDownPressed: {
            sfxNav.play();
            do {
                incrementCurrentIndex();
            } while (!currentItem.enabled);
        }

    }

    // Global input handling for the screen
    Keys.onPressed: {
        // Settings
        if (api.keys.isFilters(event) && !event.isAutoRepeat) {
            event.accepted = true;
            settingsScreen();
        }
    }

    // Helpbar buttons
    ListModel {
        id: gridviewHelpModel

        ListElement {
            name: "Settings"
            button: "filters"
        }
        ListElement {
            name: "Select"
            button: "accept"
        }
    }

    onFocusChanged: { 
        if (focus)
            currentHelpbarModel = gridviewHelpModel;
    }

}
