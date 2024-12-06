import QtQuick 2.3
import "../Global"
import "../Lists"

FocusScope {
id: root

	//ListView model传入的数据
	property var collection

	property bool selected: ListView.isCurrentItem

    // 动态加载器
    Loader {
        id: dynamicLoader
		anchors.fill: parent
		focus: parent.selected
		asynchronous: true

		// 根据条件切换子组件
		sourceComponent: { 
			if (collection instanceof ListFavorites) { 
				parent.height = vpx(480) //vpx(410)
				return featuredComponent
			} else if (collection instanceof ListPlatforms) {
				parent.height = vpx(120)
				return platformComponent
			}
			parent.height = collection.height 
			return collectionComponent  
		}

    }

	// 主页的收藏列表，播放视频
	Component {
	id: featuredComponent

		FeaturedList {
			focus: root.selected
			collection: root.collection
            height: root.height
			modelIndex: index
		}
	}

	//平台列表
	Component {
	id: platformComponent

		PlatformList {
			focus: root.selected
			collection: root.collection
            height: root.height
			modelIndex: index
		}
	}


	// 各种过滤后的游戏列表
	Component {
	id: collectionComponent
		
		HorizontalCollection {
		id: horizontalCollection

			anchors.fill: parent
            focus: root.selected
            collection: root.collection
            enabled: collection.enabled
            visible: collection.enabled
            height: collection.height
            itemWidth: collection.itemWidth
            itemHeight: collection.itemHeight
            title: collection.title
            search: collection.search
            showBoxes: collection.showBoxes
			onActivateSelected: {
				storedHomeSecondaryIndex = currentIndex;
				gameDetails(search.currentGame(currentIndex));
				console.log("onActivateSelected, storedHomeSecondaryIndex: " + storedHomeSecondaryIndex);
			}
			onListHighlighted: {
				mainList.currentIndex = index;
			}
		}
	}

}
