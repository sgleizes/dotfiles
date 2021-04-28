/***************************************************************************
 *   Copyright (C) 2014-2015 by Eike Hein <hein@kde.org>                   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 2.8
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0

import org.kde.plasma.plasmoid 2.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0

Item {
    id: main

    property int index: model.index
    property string name: model.blank ? "" : model.display
    property bool blank: model.blank
    property bool isDir: loader.item ? loader.item.isDir : false
    property QtObject popupDialog: loader.item ? loader.item.popupDialog : null
    property Item iconArea: loader.item ? loader.item.iconArea : null
    property Item label: loader.item ? loader.item.label : null
    property Item labelArea: loader.item ? loader.item.labelArea : null
    property Item actionsOverlay: loader.item ? loader.item.actionsOverlay : null
    property Item hoverArea: loader.item ? loader.item.hoverArea : null
    property Item frame: loader.item ? loader.item.frame : null
    property Item toolTip: loader.item ? loader.item.toolTip : null
    Accessible.name: name
    Accessible.role: Accessible.Canvas

    MouseArea { anchors.fill: parent } // This MouseArea exists to intercept press and hold;
                                       // preventing edit mode from being triggered
                                       // when pressing and holding on an icon

    function openPopup() {
        if (isDir) {
            loader.item.openPopup();
        }
    }

    function closePopup() {
        if (popupDialog) {
            popupDialog.requestDestroy();
            loader.item.popupDialog = null;
        }
    }

    Loader {
        id: loader

        // On the desktop we pad our cellSize to avoid a gap at the right/bottom of the screen.
        // The padding per item is quite small and causes the delegate to be positioned on fractional pixels
        // leading to blurry rendering. The Loader is offset to account for this.
        x: -main.x % 1
        y: -main.y % 1
        width: parent.width
        height: parent.height

        visible: status === Loader.Ready

        active: !model.blank

        sourceComponent: delegateImplementation

        asynchronous: true
    }

    Component {
        id: delegateImplementation

        Item {
            id: impl

            anchors.fill: parent

            property bool blank: model.blank
            property bool selected: model.blank ? false : model.selected
            property bool isDir: model.blank ? false : model.isDir
            property bool hovered: (main.GridView.view.hoveredItem === main)
            property QtObject popupDialog: null
            property Item iconArea: icon
            property Item label: label
            property Item labelArea: frameLoader.textShadow || label
            property Item actionsOverlay: actions
            property Item hoverArea: toolTip
            property Item frame: frameLoader
            property Item toolTip: toolTip
            property Item selectionButton: null
            property Item popupButton: null

            onSelectedChanged: {
                if (selected && !blank) {
                    frameLoader.grabToImage(function(result) {
                        dir.addItemDragImage(positioner.map(index), main.x + frameLoader.x, main.y + frameLoader.y, frameLoader.width, frameLoader.height, result.image);
                    });
                }
            }

            onHoveredChanged: {
                if (hovered) {
                    if (plasmoid.configuration.selectionMarkers && Qt.styleHints.singleClickActivation) {
                        selectionButton = selectionButtonComponent.createObject(actions);
                    }

                    if (model.isDir) {
                        if (!main.GridView.view.isRootView || root.containsDrag) {
                            hoverActivateTimer.restart();
                        }

                        if (plasmoid.configuration.popups && !root.useListViewMode) {
                            popupButton = popupButtonComponent.createObject(actions);
                        }
                    }
                } else if (!hovered) {
                    if (popupDialog != null) {
                        closePopup();
                    }

                    if (selectionButton) {
                        selectionButton.destroy();
                        selectionButton = null;
                    }

                    if (popupButton) {
                        popupButton.destroy();
                        popupButton = null;
                    }
                }
            }

            function openPopup() {
                if (folderViewDialogComponent.status == Component.Ready) {
                    impl.popupDialog = folderViewDialogComponent.createObject(impl);
                    impl.popupDialog.visualParent = icon;
                    impl.popupDialog.url = model.linkDestinationUrl;
                    impl.popupDialog.visible = true;
                }
            }

            PlasmaCore.ToolTipArea {
                id: toolTip

                active: (plasmoid.configuration.toolTips && popupDialog == null && !model.blank)
                interactive: false
                location: root.useListViewMode ? (plasmoid.location === PlasmaCore.Types.LeftEdge ? PlasmaCore.Types.LeftEdge : PlasmaCore.Types.RightEdge) : plasmoid.location

                onContainsMouseChanged:  {
                    if (containsMouse && !model.blank) {
                        if (toolTip.active) {
                            toolTip.icon = model.decoration;
                            toolTip.mainText = model.display;

                            if (model.size !== undefined) {
                                    toolTip.subText = model.type + "\n" + model.size;
                            } else {
                                toolTip.subText = model.type;
                            }
                        }

                        main.GridView.view.hoveredItem = main;
                    }
                }

                states: [
                    State { // icon view
                        when: !root.useListViewMode

                        AnchorChanges {
                            target: toolTip
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        PropertyChanges {
                            target: toolTip
                            y: frameLoader.y + icon.y
                            width: Math.max(icon.paintedWidth, label.paintedWidth)
                            height: (label.y + label.paintedHeight) - y
                        }
                    },
                    State { // list view
                        when: root.useListViewMode

                        AnchorChanges {
                            target: toolTip
                            anchors.horizontalCenter: undefined
                        }

                        PropertyChanges {
                            target: toolTip
                            x: frameLoader.x
                            y: frameLoader.y
                            width: frameLoader.width
                            height: frameLoader.height
                        }
                    }
                ]
            }

            Loader {
                id: frameLoader

                x: root.useListViewMode ? 0 : units.smallSpacing
                y: root.useListViewMode ? 0 : units.smallSpacing

                property Item textShadow: null
                property Item iconShadow: null
                property string prefix: ""

                sourceComponent: frameComponent
                active: state !== ""
                asynchronous: true

                width: {
                    if (root.useListViewMode) {
                        if (main.GridView.view.overflowing) {
                            return parent.width - units.smallSpacing;
                        } else {
                            return parent.width;
                        }
                    }

                    return parent.width - (units.smallSpacing * 2);
                }

                height: {
                    if (root.useListViewMode) {
                        return parent.height;
                    }

                    // Note: frameLoader.y = units.smallSpacing (acts as top margin)
                    return (units.smallSpacing // icon.anchors.topMargin (acts as top padding)
                        + icon.height
                        + units.smallSpacing // label.anchors.topMargin (acts as spacing between icon and label)
                        + (label.lineCount * theme.mSize(theme.defaultFont).height)
                        + units.smallSpacing); // leftover (acts as bottom padding)
                }

                PlasmaCore.IconItem {
                    id: icon

                    z: 2

                    states: [
                        State { // icon view
                            when: !root.useListViewMode

                            AnchorChanges {
                                target: icon
                                anchors.top: parent.top
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        },
                        State { // list view
                            when: root.useListViewMode

                            AnchorChanges {
                                target: icon
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    ]

                    anchors {
                        topMargin: units.smallSpacing
                        leftMargin: units.smallSpacing
                    }

                    width: root.useListViewMode ? main.GridView.view.iconSize : (parent.width - 2 * units.smallSpacing)
                    height: main.GridView.view.iconSize

                    opacity: {
                        if (root.useListViewMode && selectionButton) {
                            return 0.3;
                        }

                        if (model.isHidden) {
                            return 0.6;
                        }

                        return 1.0;
                    }

                    animated: false
                    usesPlasmaTheme: false

                    smooth: true

                    source: model.decoration
                    overlays: model.overlays
                }

                    Rectangle {
                        id: fallbackRectangleBackground
                        visible: GraphicsInfo.api === GraphicsInfo.Software && !model.selected
                        anchors {
                            fill: label
                            margins: -units.smallSpacing
                        }

                        color: "black"
                        radius: units.smallSpacing
                        opacity: 0.45
                    }

                PlasmaComponents.Label {
                    id: label

                    z: 2 // So we can position a textShadowComponent below if needed.

                    states: [
                        State { // icon view
                            when: !root.useListViewMode

                            AnchorChanges {
                                target: label
                                anchors.top: icon.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            PropertyChanges {
                                target: label
                                anchors.topMargin: units.smallSpacing
                                width: Math.round(Math.min(label.implicitWidth + units.smallSpacing, parent.width - units.smallSpacing))
                                maximumLineCount: plasmoid.configuration.textLines
                                horizontalAlignment: Text.AlignHCenter
                            }
                        },
                        State { // list view
                            when: root.useListViewMode

                            AnchorChanges {
                                target: label
                                anchors.left: icon.right
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            PropertyChanges {
                                target: label
                                anchors.leftMargin: units.smallSpacing * 2
                                anchors.rightMargin: units.smallSpacing * 2
                                width: parent.width - icon.width - (units.smallSpacing * 4)
                                maximumLineCount: 1
                                horizontalAlignment: Text.AlignLeft
                            }
                        }
                    ]

                    height: undefined // Unset PlasmaComponents.Label's default.

                    textFormat: Text.PlainText

                    wrapMode: (maximumLineCount == 1) ? Text.NoWrap : Text.Wrap
                    elide: Text.ElideRight

                    color: {
                        if ((frameLoader.textShadow && frameLoader.textShadow.visible) || fallbackRectangleBackground.visible) {
                            return "#fff";
                        } else if (model.selected) {
                            return PlasmaCore.ColorScope.highlightedTextColor;
                        } else {
                            return PlasmaCore.ColorScope.textColor
                        }
                    }

                    opacity: model.isHidden ? 0.6 : 1

                    text: model.blank ? "" : model.display

                    font.italic: model.isLink

                    visible: {
                        if (editor && editor.targetItem === main) {
                            return false;
                        }

                        // DropShadow renders the Label already.
                        if (frameLoader.textShadow && frameLoader.textShadow.visible) {
                            return false;
                        }

                        return true;
                    }
                }

                Component {
                    id: frameComponent

                    PlasmaCore.FrameSvgItem {
                        prefix: frameLoader.prefix

                        imagePath: "widgets/viewitem"

                        // Use inactive highlight effect when something else has focus
                        opacity: Window.active ? 1 : 0.4
                    }
                }

                Component {
                    id: selectionButtonComponent

                    FolderItemActionButton {
                        element: model.selected ? "remove" : "add"

                        onClicked: dir.toggleSelected(positioner.map(index))
                    }
                }

                Component {
                    id: popupButtonComponent

                    FolderItemActionButton {
                        visible: main.GridView.view.isRootView && (popupDialog == null)

                        element: "open"

                        onClicked: {
                            dir.setSelected(positioner.map(index))
                            openPopup();
                        }
                    }
                }

                Component {
                    id: iconShadowComponent

                    DropShadow {
                        anchors.fill: icon

                        z: 1

                        verticalOffset: 1

                        radius: Math.round(5 * units.devicePixelRatio)
                        samples: radius * 2 + 1
                        spread: 0.05

                        color: "black"

                        opacity: model.isHidden ? 0.3 : 0.6

                        source: icon

                        visible: !editor || editor.targetItem != main
                    }
                }

                Component {
                    id: textShadowComponent

                    DropShadow {
                        anchors.fill: label

                        z: 1

                        horizontalOffset: 1
                        verticalOffset: 1

                        radius: Math.round(4 * units.devicePixelRatio)
                        samples: radius * 2 + 1
                        spread: 0.35

                        color: "black"

                        opacity: model.isHidden ? 0.6 : 1

                        source: label

                        visible: !editor || editor.targetItem != main
                    }
                }

                states: [
                    State {
                        name: "selected"
                        when: model.selected

                        PropertyChanges {
                            target: frameLoader
                            prefix: "selected"
                        }
                    },
                    State {
                        name: "hover"
                        when: hovered && !model.selected && plasmoid.configuration.iconHoverEffect

                        PropertyChanges {
                            target: frameLoader
                            prefix: "hover"
                        }
                    },
                    State {
                        name: "selected+hover"
                        when: hovered && model.selected && plasmoid.configuration.iconHoverEffect

                        PropertyChanges {
                            target: frameLoader
                            prefix: "selected+hover"
                        }
                    }
                ]
            }

            Column {
                id: actions

                visible: {
                    if (main.GridView.view.isRootView && root.containsDrag) {
                        return false;
                    }

                    if (!main.GridView.view.isRootView && main.GridView.view.dialog.containsDrag) {
                        return false;
                    }

                    if (popupDialog) {
                        return false;
                    }

                    return true;
                }

                anchors {
                    left: frameLoader.left
                    top: frameLoader.top
                    leftMargin: root.useListViewMode ? (icon.x + (icon.width / 2)) - (width / 2) : 0
                    topMargin: root.useListViewMode ? (icon.y + (icon.height / 2)) - (height / 2)  : 0
                }

                width: implicitWidth
                height: implicitHeight
            }

            Component.onCompleted: {
                if (root.isContainment && main.GridView.view.isRootView && root.GraphicsInfo.api === GraphicsInfo.OpenGL) {
                    frameLoader.textShadow = textShadowComponent.createObject(frameLoader);
                    frameLoader.iconShadow = iconShadowComponent.createObject(frameLoader);
                }
            }
        }
    }
}
