import QtQuick 2.15

FocusScope {
id: root

	property bool showTitle: settings.AlwaysShowTitles === "Yes"
	property bool showHighlightTitle: showTitle
	property int verticalSpacing: (showTitle || showHighlightTitle) ? vpx(40) : vpx(12)
	property int horizontalSpacing: vpx(12)
	property int numColumns: settings.GridColumns ? settings.GridColumns : 6
	property bool showBoxes: settings.GridThumbnail === "Box Art"
	property real cellHeightRatio: fakebox.paintedHeight / fakebox.paintedWidth
	property var gameList
	property alias currentIndex: gridview.currentIndex
	
	GridSpacer {
	id: fakebox
		width: vpx(100); height: vpx(100)
		games: gameList.games
	}

	GridView {
	id: gridview

		focus: parent.focus
		anchors.fill: parent
		cellWidth: width / numColumns
		cellHeight: (cellWidth - horizontalSpacing) * cellHeightRatio + verticalSpacing
		preferredHighlightBegin: 0
		preferredHighlightEnd: height
		highlightRangeMode: GridView.StrictlyEnforceRange
		highlightMoveDuration: 200
		highlight: highlightComponent
		keyNavigationWraps: false
		displayMarginBeginning: cellHeight * 2
		displayMarginEnd: cellHeight * 2

		Component.onCompleted: {
			currentIndex = 0;//storedCollectionGameIndex;
			positionViewAtIndex(currentIndex, GridView.Visible);
		}

		model: gameList.games
        delegate: (showBoxes) ? boxartDelegate : dynamicDelegate

        Component {
        id: boxartDelegate
			BoxArtGridItem {
				selected:				GridView.isCurrentItem && GridView.view.focus
				width:					GridView.view.cellWidth
				height:					GridView.view.cellHeight
				verticalSpacing:		root.verticalSpacing
				horizontalSpacing:		root.horizontalSpacing
				showTitle:				root.showTitle
				showHighlightTitle:		root.showHighlightTitle
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
					if (api.keys.isFilters(event) && !event.isAutoRepeat) {
						event.accepted = true;
						sfxToggle.play();
						modelData.favorite = !modelData.favorite;
					} else {
						sfxNav.play();
					}
				}
			}
		}

		Component {
		id: dynamicDelegate
			DynamicGridItem {
				selected:				GridView.isCurrentItem && GridView.view.focus
				width:					GridView.view.cellWidth
				height:					GridView.view.cellHeight
				verticalSpacing:		root.verticalSpacing
				horizontalSpacing:		root.horizontalSpacing
				showTitle:				root.showTitle
				showHighlightTitle:		root.showHighlightTitle
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

		Component {
		id: highlightComponent

			ItemHighlight {
				width: GridView.view.cellWidth
				height: GridView.view.cellHeight
				selected: GridView.view.focus
				game: gameList.currentGame(GridView.view.currentIndex)
				boxArt: true
			}
		}

	}

}
