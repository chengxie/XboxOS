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

import QtQuick 2.12
import QtQuick.Layouts 1.11
import QtGraphicalEffects 1.10
import QtQml.Models 2.1
import "../utils.js" as Utils

FocusScope {
id: root

    property bool searchActive

    onFocusChanged: buttonbar.currentIndex = 0;

    function toggleSearch() {
        searchActive = !searchActive;
    }

    Item {
    id: container

        anchors.fill: parent

        // Platform logo
        Image {
        id: logobg

            anchors.fill: platformlogo
            source: "../assets/images/blank.png"
            asynchronous: true
            visible: false
        }

        Image {
        id: platformlogo

            anchors {
                top: parent.top; topMargin: vpx(20)
                bottom: parent.bottom; bottomMargin: vpx(20)
                left: parent.left; leftMargin: globalMargin
            }
            fillMode: Image.PreserveAspectFit
            source: "../assets/images/logospng/" + Utils.processPlatformName(currentCollection.shortName) + ".png"
            sourceSize: Qt.size(parent.width, parent.height)
            smooth: true
            visible: false
            asynchronous: true           
        }

        OpacityMask {
            anchors.fill: logobg
            source: logobg
            maskSource: platformlogo
            // Mouse/touch functionality
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: previousScreen();
            }
        }

        // Platform title
        Text {
        id: softwareplatformtitle
            
            text: currentCollection.name
            
            anchors {
                top:    parent.top;
                left:   parent.left;    leftMargin: globalMargin
                right:  parent.right
                bottom: parent.bottom
            }
            
            color: theme.text
            font.family: titleFont.name
            font.pixelSize: vpx(30)
            font.bold: true
            horizontalAlignment: Text.AlignHLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            visible: platformlogo.status == Image.Error

            // Mouse/touch functionality
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: previousScreen();
            }
        }

        ObjectModel {
        id: headermodel

			IconButton {
			id: searchButton
				property bool selected: ListView.isCurrentItem && root.focus
				icon: "../assets/images/searchicon.svg"
				color: selected ? theme.accent : "transparent"
				opacity: 0.8
                Keys.onPressed: {
                    // Accept
                    if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                        event.accepted = true;
						searchAllGames = false;
						searchScreen();
                    }
                }
			}

            // Ascending/descending
            Item {
            id: directionbutton

                property bool selected: ListView.isCurrentItem && root.focus
                width: directiontitle.contentWidth + vpx(30)
                height: vpx(40)

                Rectangle { 
                    anchors.fill: parent
                    radius: height/2
                    color: theme.accent
                    visible: directionbutton.selected
                }

                Text {
                id: directiontitle
                    
                    text: (orderBy === Qt.AscendingOrder) ? "Ascending" : "Descending"
                                    
                    color: theme.text
                    font.family: subtitleFont.name
                    font.pixelSize: vpx(18)
                    anchors.centerIn: parent
                    elide: Text.ElideRight
                }

                Keys.onPressed: {
                    // Accept
                    if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                        event.accepted = true;
                        toggleOrderBy();
                    }
                }
            }

            // Order by title
            Item {
            id: titlebutton

                property bool selected: ListView.isCurrentItem && root.focus
                width: ordertitle.contentWidth + vpx(30)
                height: vpx(40)

                Rectangle { 
                    anchors.fill: parent
                    radius: height/2
                    color: theme.accent
                    visible: titlebutton.selected
                }

                Text {
                id: ordertitle
                    
                    text: "By " + sortByFilter[sortByIndex]
                                    
                    color: theme.text
                    font.family: subtitleFont.name
                    font.pixelSize: vpx(18)
                    anchors.centerIn: parent
                    elide: Text.ElideRight
                }

                Keys.onPressed: {
                    // Accept
                    if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                        event.accepted = true;
                        cycleSort();
                    }
                }
            }
            
            // Filters menu
            Item {
            id: filterbutton

                property bool selected: ListView.isCurrentItem && root.focus
                width: filtertitle.contentWidth + vpx(30)
                height: vpx(40)

                Rectangle { 
                    anchors.fill: parent
                    radius: height/2
                    color: theme.accent
                    visible: filterbutton.selected
                }
                
                // Filter title
                Text {
                id: filtertitle
                    
                    text: (showFavs) ? "Favorites" : "All games"
                                    
                    color: theme.text
                    font.family: subtitleFont.name
                    font.pixelSize: vpx(18)
                    anchors.centerIn: parent
                    elide: Text.ElideRight
                }

                Keys.onPressed: {
                    // Accept
                    if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                        event.accepted = true;
                        toggleFavs();
                    }
                }
            }

        }

        // Buttons
        ListView {
        id: buttonbar

            focus: true
            model: headermodel
            spacing: vpx(10)
            orientation: ListView.Horizontal
            layoutDirection: Qt.RightToLeft
            anchors {
                right: parent.right; rightMargin: globalMargin
                left: parent.left; top: parent.top; topMargin: vpx(15)
            }
            
        }
        
    }

}
