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

		ListView {
		id: headerMenu
			
			width: searchButton.width + settingsButton.width + spacing
			height: vpx(30)
            anchors { 
			    verticalCenter: parent.verticalCenter
				verticalCenterOffset: -vpx(4)
			    right: sysTime.left; rightMargin: vpx(15)
			}
			orientation: ListView.Horizontal
			spacing: vpx(10)
			keyNavigationWraps: true

			Component.onDestruction: {
				if (focus) {
					showcaseHeaderMenuIndex = currentIndex;
				} else {
					showcaseHeaderMenuIndex = -1;
				}
			}

			Component.onCompleted: {
				if (showcaseHeaderMenuIndex != -1) {
					currentIndex = showcaseHeaderMenuIndex
					focus = true
				}
			}

            onFocusChanged: {
                //sfxNav.play()
                if (focus) {
                    mainList.currentIndex = -1;
				} else {
                    mainList.currentIndex = 0;
				}
            }
	
			model: ObjectModel {

				IconButton {
				id: searchButton
					property bool selected: ListView.isCurrentItem && headerMenu.focus
					icon: "../assets/images/searchicon.svg"
					color: selected ? theme.accent : "transparent"
					opacity: root.focus ? 0.8 : 0.5
					onHighlighted: { headerMenu.currentIndex = ObjectModel.index; }
					onActivate: {
						if (selected) {
							sfxAccept.play();
							searchScreen();
						} else {
							sfxNav.play();
							headerMenu.currentIndex = ObjectModel.index;
						}
					}
				}

				IconButton {
				id: settingsButton
					property bool selected: ListView.isCurrentItem && headerMenu.focus
					icon: "../assets/images/settingsicon.svg"
					color: selected ? theme.accent : "transparent"
					opacity: root.focus ? 0.8 : 0.5
					onHighlighted: { headerMenu.currentIndex = ObjectModel.index; }
					onActivate: {
						if (selected) {
							sfxAccept.play();
							settingsScreen();
						} else {
							sfxNav.play();
							headerMenu.currentIndex = ObjectModel.index;
						}
					}
				}
			}

            Keys.onDownPressed: mainList.focus = true;
			Keys.onLeftPressed: { sfxNav.play(); decrementCurrentIndex() }
			Keys.onRightPressed: { sfxNav.play(); incrementCurrentIndex() }
            Keys.onPressed: {
				if (api.keys.isCancel(event) && !event.isAutoRepeat) {
					// Back
                    event.accepted = true;
                    mainList.focus = true;
                }
            }
		}

        Text {
        id: sysTime

            Timer {
                id: textTimer
                interval: 60000 // Run the timer every minute
                repeat: true
                running: true
                triggeredOnStart: true
                onTriggered: {
					sysTime.text = Qt.formatTime(new Date(), "hh:mm AP")
				}
            }
			
            anchors {
				verticalCenter: parent.verticalCenter
                right: parent.right; rightMargin: vpx(25)
			}
            color: "white"
            font.pixelSize: vpx(22)
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

		Component.onCompleted: {
			positionViewAtIndex(currentIndex, ListView.Visible)
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
