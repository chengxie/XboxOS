import QtQuick 2.15

FocusScope {
id: root

	property alias currentIndex: gridview.currentIndex	// Expose the current index to the outside
	property bool showTitles: settings.AlwaysShowTitles === "Yes"
	property bool showHighlightedTitles: showTitles
	property int titleHeight: (showTitles || showHighlightedTitles) ? vpx(36) : 0
	property int numColumns: settings.GridColumns ? settings.GridColumns : 6
	property var gameList
	
	GridSpacer { id: fakebox; collection: gameList.collection }

	GridView {
	id: gridview

		property int horizontalSpacing: cellWidth * 0.09
		property int verticalSpacing: horizontalSpacing + titleHeight

		focus: parent.focus
		anchors.fill: parent
		anchors.rightMargin: - horizontalSpacing
		cellWidth: parent.width / numColumns
		cellHeight: (cellWidth - horizontalSpacing) * fakebox.ratio + verticalSpacing
		preferredHighlightBegin: 0
		preferredHighlightEnd: height
		highlightRangeMode: GridView.StrictlyEnforceRange
		highlightMoveDuration: 200
		keyNavigationWraps: false
		displayMarginBeginning: cellHeight * 2
		displayMarginEnd: cellHeight * 2

		Component.onCompleted: {
			currentIndex = 0;//storedCollectionGameIndex;
            //currentIndex = storedCollectionGameIndex;
			positionViewAtIndex(currentIndex, GridView.Visible);
		}

		model: gameList.games
        delegate: boxartDelegate

        Component {
        id: boxartDelegate
			BoxArtGridItem {
				selected:				GridView.isCurrentItem && GridView.view.focus
				width:					GridView.view.cellWidth
				height:					GridView.view.cellHeight
				verticalSpacing:		GridView.view.verticalSpacing
				horizontalSpacing:		GridView.view.horizontalSpacing
				showTitles:				root.showTitles
				showHighlightedTitles:	root.showHighlightedTitles
				onActivate: {
					if (selected) {
						storedCollectionGameIndex = GridView.view.currentIndex
						gameDetails(modelData);
					} else {
						GridView.view.currentIndex = index;
					}
				}
				onHighlighted: {
					GridView.view.currentIndex = index;
				}
				Keys.onPressed: {
					// Toggle favorite
					if (api.keys.isDetails(event) && !event.isAutoRepeat) {
						event.accepted = true;
						sfxToggle.play();
						modelData.favorite = !modelData.favorite;
					} else {
						sfxNav.play();
					}
				}
			}
		}
	}
}
