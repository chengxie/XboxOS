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

import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
id: root
	
	property bool showBorder: settings.BorderHighlight === "Yes"
	property bool showHighlightedTitles: settings.AlwaysShowHighlightedTitles === "Yes"

    anchors.fill: parent
	visible: selected
	
	Item {
	id: border
		anchors.fill: parent
		visible: showBorder

		Image {
		id: borderImage
			anchors.fill: parent
			source: "../assets/images/" + settings.ColorLayout + ".png"
			asynchronous: true
			visible: false        
		}

		BorderImage {
		id: mask
			anchors.fill: parent
			source: "../assets/images/borderimage.gif"
			border { left: vpx(5); right: vpx(5); top: vpx(5); bottom: vpx(5);}
			smooth: false
			visible: false
			asynchronous: true
		}

		OpacityMask {
			anchors.fill: borderImage
			source: borderImage
			maskSource: mask
		}
	}

	Text {
	id: bubbletitle
		visible: showHighlightedTitles
		anchors { top: border.bottom; topMargin: vpx(2) }
		text: modelData.title
		color: theme.text
		font {
			family: titleFont.name
			pixelSize: vpx(16)
			bold: true
		}
		anchors.horizontalCenter: parent.horizontalCenter
	}
}
