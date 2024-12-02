import QtQuick 2.3
import "../Global"
import "../Lists"

FocusScope {
id: root

	property var collection
	property var objModel
	property bool selected: ListView.isCurrentItem

    // 动态加载器
    Loader {
        id: dynamicLoader
		anchors.fill: parent
		focus: parent.selected

		// 根据条件切换子组件
		sourceComponent: { 
			if (collection instanceof ListFavorites) { 
				parent.height = vpx(530) //vpx(410)
				return featuredComponent
			} else if (collection instanceof ListPlatforms) {
				parent.height = vpx(140)
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
			componentHeight: root.height
			componentBottom: root.bottom
		}
	}

	//平台列表
	Component {
	id: platformComponent

		PlatformList {
			focus: root.selected
			collection: root.collection
			componentHeight: root.height
			componentBottom: root.bottom
		}
	}

	// 各种过滤后的游戏列表
	Component {
	id: collectionComponent
		
		HorizontalCollection {
		id: horizontalCollection

			property var currentList: collectionList
			property var selected: root.selected
			anchors.fill: parent
            focus: selected
            collectionData: root.collection
            collection: root.collection
            enabled: collection.enabled
            visible: collection.enabled
            height: collection.height
            itemWidth: collection.itemWidth
            itemHeight: collection.itemHeight
            title: collection.title
            search: collection.search
            showBoxes: collection.showBoxes
			savedIndex: (storedHomePrimaryIndex === root.objModel.index) ? storedHomeSecondaryIndex : 0
			onActivateSelected: storedHomeSecondaryIndex = currentIndex;
			onActivate: { if (!selected) { mainList.currentIndex = root.objModel.index; } }
			onListHighlighted: { sfxNav.play(); mainList.currentIndex = root.objModel.index; }

		}
	}

}
